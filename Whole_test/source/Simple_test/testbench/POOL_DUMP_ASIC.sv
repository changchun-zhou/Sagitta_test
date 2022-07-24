//======================================================
// Copyright (C) 2020 By 
// All Rights Reserved
//======================================================
// Module : 
// Author : 
// Contact : 
// Date : 
//=======================================================
// Description :
//========================================================
`ifndef POOL_DUMP
  `define POOL_DUMP
`include "../source/include/dw_params_presim.vh"
module POOL_DUMP( // dump output
  // input   Clk,
  
  input   DumpStart,
  input   DumpEnd
);
  integer fp_CFGPOOL_data;
  integer fp_GBPOOL_data;
  
  integer fp_POOLGB_addr;
  integer fp_BF_addr  ;  
  integer fp_BF_data    ;
  integer fp_BF_flg_data;
string fp_num_ftrgrp;

wire POOLStart;


// initial begin
//     // fp_CFGPOOL_data = $fopen("../sim_TS3D/dump_rtl/POOL/CFGPOOL_data.txt", "wb");
//     // fp_GBPOOL_data  = $fopen("../sim_TS3D/dump_rtl/POOL/GBPOOL_data.txt", "wb");
//     // fp_POOLGB_addr  = $fopen("../sim_TS3D/dump_rtl/POOL/POOLGB_addr_rtl.txt", "w");
//     // fp_BF_addr      = $fopen("../sim_TS3D/dump_rtl/POOL/BF_addr.txt", "w");
//     // fp_BF_data      = $fopen("../sim_TS3D/dump_rtl/POOL/BF_data.txt", "w");
//     // fp_BF_flg_data  = $fopen("../sim_TS3D/dump_rtl/POOL/BF_flg_data.txt", "w");
// end
wire Clk = top.ASIC_U.clk;

string cmd;
always @ ( posedge Clk ) begin
    if ( top.ASIC_U.TS3D.inst_CCU.counter_FtrGrp.INC ) begin
        $system("echo '<<<<<< run POOL.py Reference Model >>>>>>>'");
        // $system("cd ../scripts/POOL");
        cmd = $psprintf("python ../scripts/POOL/POOL.py --layer %02d --patch %02d --ftrgrp %02d --num_frame %02d",                          
                        top.ASIC_U.TS3D.inst_CCU.cnt_layer, 
                        top.ASIC_U.TS3D.inst_CCU.cnt_patch, 
                        top.ASIC_U.TS3D.inst_CCU.cnt_ftrgrp,
                        top.ASIC_U.TS3D.inst_CCU.CFGCCU_num_frame+1+1);// num_frame + 1: padding hold + first frame
        $system( {"echo ", cmd} );
        $system(cmd);
        // $system("cd ../../sim_TS3D");
        $system("echo <<<<<<<<< POOL.py Reference Model done >>>>>>>>");
    end
end

assign POOLStart = top.ASIC_U.TS3D.inst_CCU.start_cmp || 
        ( top.ASIC_U.TS3D.inst_CCU.Delay_inc_ftrgrp_d.DOUT && ~top.ASIC_U.TS3D.inst_CCU.wait_inc_layer || top.ASIC_U.TS3D.inst_CCU.inc_layer_d);

always @ ( posedge Clk ) begin
    if ( POOLStart ) begin
        fp_num_ftrgrp = $psprintf("_L%02d_P%02d_F%02d", 
                 top.ASIC_U.TS3D.inst_CCU.cnt_layer, 
                 top.ASIC_U.TS3D.inst_CCU.cnt_patch, 
                 top.ASIC_U.TS3D.inst_CCU.cnt_ftrgrp);
        fp_CFGPOOL_data= $fopen({"./dump_rtl/POOL/CFGPOOL_data",fp_num_ftrgrp,".txt"}, "wb");
        fp_GBPOOL_data = $fopen({"./dump_rtl/POOL/GBPOOL_data",fp_num_ftrgrp,".txt"}, "wb");
        fp_POOLGB_addr = $fopen({"./dump_rtl/POOL/POOLGB_addr",fp_num_ftrgrp,".txt"}, "wb");
        fp_BF_addr     = $fopen({"./dump_rtl/POOL/BF_addr",fp_num_ftrgrp,".txt"}, "wb");
        fp_BF_data     = $fopen({"./dump_rtl/POOL/BF_data",fp_num_ftrgrp,".txt"}, "wb");
        fp_BF_flg_data = $fopen({"./dump_rtl/POOL/BF_flg_data",fp_num_ftrgrp,".txt"}, "wb");
    end
end


always @ ( posedge Clk )begin
    if(top.ASIC_U.TS3D.inst_POOL.POOLCFG_rdy && top.ASIC_U.TS3D.inst_POOL.CFGPOOL_val ) begin
        @( posedge Clk )
        $fwrite(fp_CFGPOOL_data, "Scale_y=%12d Bias_y=%4d CFGPOOL_valpool=%1d CFGPOOL_valfrmpool=%1d Stride=%1d", 
            top.ASIC_U.TS3D.inst_POOL.Scale_y, top.ASIC_U.TS3D.inst_POOL.Bias_y, top.ASIC_U.TS3D.inst_POOL.CFGPOOL_valpool, 
            top.ASIC_U.TS3D.inst_POOL.CFGPOOL_valfrmpool, top.ASIC_U.TS3D.inst_POOL.Stride);
        $fwrite(fp_CFGPOOL_data,"\n");
    end 
end

always @ ( posedge Clk )begin
    if(top.ASIC_U.TS3D.inst_POOL.POOLGB_rdy && top.ASIC_U.TS3D.inst_POOL.GBPOOL_val ) begin
        for(int j=0; j<16 ; j=j+1)
            $fwrite(fp_GBPOOL_data, "%12d", $signed(top.ASIC_U.TS3D.inst_POOL.GBPOOL_data[`PSUM_WIDTH*j +: `PSUM_WIDTH]));
        $fwrite(fp_GBPOOL_data, "\n");//16B
        $fwrite(fp_POOLGB_addr, "%4d", top.ASIC_U.TS3D.inst_POOL.POOLGB_addr);
        $fwrite(fp_POOLGB_addr,"\n");
    end 
end


always @ ( posedge Clk )begin
  if( top.ASIC_U.TS3D.inst_POOL.BF_rdy && top.ASIC_U.TS3D.inst_POOL.BF_val )begin
      $fwrite(fp_BF_addr, "%4d", top.ASIC_U.TS3D.inst_POOL.BF_addr);
      $fwrite(fp_BF_data, "%4d", $signed(top.ASIC_U.TS3D.inst_POOL.BF_data));

    $fwrite(fp_BF_addr,"\n");
    $fwrite(fp_BF_data,"\n");
  end

end

always @ ( posedge Clk )begin
  if( top.ASIC_U.TS3D.inst_POOL.BF_flg_rdy && top.ASIC_U.TS3D.inst_POOL.BF_flg_val )begin
    // for(integer i = 0; i < 16; i = i + 1 )begin
      $fwrite(fp_BF_flg_data, "%b", top.ASIC_U.TS3D.inst_POOL.BF_flg_data);
    // end
    $fwrite(fp_BF_flg_data,"\n");
  end

end

endmodule

`endif
