module Assert (
    input   wire                    clk     ,
    input   wire                    rst_n      
);



// `C_LOG_2(n)
wire [27*16 		-1 : 0] assert_AndFlag;
wire [27*16 		-1 : 0] assert_COUNT1;
wire [16 		-1 : 0] assert_COUNT1_FLGACT;
wire debug = tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.inst_FLGOFFSET.AndFlag;
genvar i, j;
generate
	for(i=0; i<16; i=i+1) begin
		for(j=0; j<27; j=j+1) begin
			assign assert_AndFlag[j + 27*i] = & tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.inst_FLGOFFSET.AndFlag;
			assign assert_COUNT1[j + 27*i] = tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[i].inst_PEB.GEN_ADDRBLOCKWEI[j].COUNT1_WEI.din;
		end	
		assign assert_COUNT1_FLGACT[i] = & tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[i].inst_PEB.COUNT1_FLGACT.din;
	end
endgenerate


always @(posedge clk ) begin
	if(rst_n)begin
		if((|assert_AndFlag) | (|assert_COUNT1) ) begin
			$display("assert happened in %m %t\n", $time);
			$display("assert_AndFlag: %h \n", assert_AndFlag);
			$display("assert_COUNT1: %h \n", assert_COUNT1);
			$display("assert_COUNT1_FLGACT: %h \n", assert_COUNT1_FLGACT);
			// $finish;
		end
	end
end

// assign assert_MACPSUM_empty = !tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].PSUM[0].MACPSUM_empty;
// assign assert_datain_addr = tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].MAC[0].REGARRAY_WEI.datain_addr;
endmodule
