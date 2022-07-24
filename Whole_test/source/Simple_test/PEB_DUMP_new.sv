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
`ifndef PEB_DUMP
  `define PEB_DUMP
`include "../source/include/dw_params_presim.vh"
module PEB_DUMP( // dump output
  input   Clk,
  
  input   DumpStart,
  input   DumpEnd
);

  integer fp_GBACT_Data   [0 : 15];
  integer fp_GBFLGACT_data[0 : 15];
  integer fp_GBWEI_Data   [0 : 15];
  integer fp_GBFLGWEI_Data[0 : 15];
  integer fp_GBWEI_IDWei_r[0 : 15];

  integer fp_PSUMGB_data0_r  [0 : 15];
  integer fp_PSUMGB_data1_r  [0 : 15];
  integer fp_PSUMGB_data2_r  [0 : 15];
  integer fp_GBPSUM_data0_r  [0 : 15];
  integer fp_GBPSUM_data1_r  [0 : 15];
  integer fp_GBPSUM_data2_r  [0 : 15];
  integer fp_ACTPEB_data_r   [0 : 15];
  integer fp_FLGACTPEB_data_r[0 : 15];

// initial begin
//     for(int file_i=0; file_i <16; file_i=file_i+1) begin
//         fp_GBACT_Data      [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBACT_Data_"    ,$psprintf("PEB%02d", file_i),".txt"}, "w");
//         fp_GBFLGACT_data   [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBFLGACT_data_" ,$psprintf("PEB%02d", file_i),".txt"}, "w");
//         fp_GBWEI_Data      [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBWEI_Data_"    ,$psprintf("PEB%02d", file_i),".txt"}, "w");
//         fp_GBFLGWEI_Data   [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBFLGWEI_Data_" ,$psprintf("PEB%02d", file_i),".txt"}, "w");
//         fp_GBWEI_IDWei_r   [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBWEI_IDWei_"   ,$psprintf("PEB%02d", file_i),".txt"}, "w");
//         fp_PSUMGB_data0_r  [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/PSUMGB_data"  ,$psprintf("PEB%02d", file_i),"_0.txt"}, "w");
//         fp_PSUMGB_data1_r  [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/PSUMGB_data"  ,$psprintf("PEB%02d", file_i),"_1.txt"}, "w");
//         fp_PSUMGB_data2_r  [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/PSUMGB_data"  ,$psprintf("PEB%02d", file_i),"_2.txt"}, "w");
//         fp_GBPSUM_data0_r  [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBPSUM_data"  ,$psprintf("PEB%02d", file_i),"_0.txt"}, "w");
//         fp_GBPSUM_data1_r  [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBPSUM_data"  ,$psprintf("PEB%02d", file_i),"_1.txt"}, "w");
//         fp_GBPSUM_data2_r  [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/GBPSUM_data"  ,$psprintf("PEB%02d", file_i),"_2.txt"}, "w");
//         fp_ACTPEB_data_r   [file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/ACTPEB_data_"   ,$psprintf("PEB%02d", file_i),".txt"}, "w");
//         fp_FLGACTPEB_data_r[file_i] = $fopen({"../sim_TS3D/dump_rtl/PEB/FLGACTPEB_data_",$psprintf("PEB%02d", file_i),".txt"}, "w");
//     end
// end 

string cmd;
always @ ( posedge Clk ) begin
    if ( top.TS3D_U.inst_CCU.inc_ftrgrp ) begin
        $system("echo '<<<<<< run TS3D.py Reference Model >>>>>>>'");
        // $system("cd ../scripts/TS3D");
        cmd = $psprintf("python ../scripts/TS3D/TS3D.py --layer %02d --patch %02d --ftrgrp %02d --num_frame %02d",                          
                        top.TS3D_U.inst_CCU.cnt_layer, 
                        top.TS3D_U.inst_CCU.cnt_patch, 
                        top.TS3D_U.inst_CCU.cnt_ftrgrp,
                        top.TS3D_U.inst_CCU.CFGCCU_num_frame+1);
        $system( {"echo ", cmd} );
        $system(cmd);
        // $system("cd ../../sim_TS3D");
        $system("echo <<<<<<<<< TS3D.py Reference Model done >>>>>>>>");
    end
end

wire                        Start;
string                      fp_num_ftrgrp;
assign Start = top.TS3D_U.inst_CCU.start_cmp || 
        ( top.TS3D_U.inst_CCU.inc_ftrgrp_d && ~top.TS3D_U.inst_CCU.wait_inc_layer || top.TS3D_U.inst_CCU.inc_layer_d);
    
generate
    genvar gv_i;
    for(gv_i=0; gv_i<16; gv_i=gv_i+1) begin:PEB

        always @ ( posedge Clk ) begin
            if ( Start ) begin
                fp_num_ftrgrp = $psprintf("_L%02d_P%02d_F%02d", 
                         top.TS3D_U.inst_CCU.cnt_layer, 
                         top.TS3D_U.inst_CCU.cnt_patch, 
                         top.TS3D_U.inst_CCU.cnt_ftrgrp);
                fp_GBACT_Data      [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBACT_Data"   , fp_num_ftrgrp ,".txt"}, "w");
                fp_GBFLGACT_data   [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBFLGACT_data", fp_num_ftrgrp ,".txt"}, "w");
                fp_GBWEI_Data      [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBWEI_Data"   , fp_num_ftrgrp ,".txt"}, "w");
                fp_GBFLGWEI_Data   [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBFLGWEI_Data", fp_num_ftrgrp ,".txt"}, "w");
                fp_GBWEI_IDWei_r   [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBWEI_IDWei"  , fp_num_ftrgrp ,".txt"}, "w");
                fp_PSUMGB_data0_r  [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/PSUMGB_data0" , fp_num_ftrgrp ,".txt"}, "w");
                fp_PSUMGB_data1_r  [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/PSUMGB_data1" , fp_num_ftrgrp ,".txt"}, "w");
                fp_PSUMGB_data2_r  [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/PSUMGB_data2" , fp_num_ftrgrp ,".txt"}, "w");
                fp_GBPSUM_data0_r  [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBPSUM_data0" , fp_num_ftrgrp ,".txt"}, "w");
                fp_GBPSUM_data1_r  [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBPSUM_data1" , fp_num_ftrgrp ,".txt"}, "w");
                fp_GBPSUM_data2_r  [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/GBPSUM_data2" , fp_num_ftrgrp ,".txt"}, "w");
                fp_ACTPEB_data_r   [gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/ACTPEB_data"  , fp_num_ftrgrp ,".txt"}, "w");
                fp_FLGACTPEB_data_r[gv_i] = $fopen({"./dump_rtl/PEL/",$psprintf("PEB%02d", gv_i), "/FLGACTPEB_data",fp_num_ftrgrp ,".txt"}, "w");
            end
        end

        always @ ( posedge Clk )begin
            if(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.ACTGB_Rdy && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBACT_Val ) begin
                for(int j=0; j<16 ; j=j+1)
                    $fwrite(fp_GBACT_Data[gv_i], "%4d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBACT_Data[`DATA_WIDTH*j +: `DATA_WIDTH]));
                $fwrite(fp_GBACT_Data[gv_i], "\n");//16B
            end 
        end

        always @ ( posedge Clk )begin
            if(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.FLGACTGB_rdy && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBFLGACT_val ) begin
                // for(int j=0; j<32 ; j=j+1)
                    $fwrite(fp_GBFLGACT_data[gv_i], "%1b", top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBFLGACT_data);
                $fwrite(fp_GBFLGACT_data[gv_i], "\n");//16B
            end 
        end

        always @ ( negedge top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.clk )begin
            if(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.WEIGB_Rdy && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBWEI_Val ) begin
                for(int j=0; j<16 ; j=j+1)
                    $fwrite(fp_GBWEI_Data[gv_i], "%4d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBWEI_Data[ 5 + `DATA_WIDTH*j +: `DATA_WIDTH]));
                $fwrite(fp_GBWEI_Data[gv_i], "\n");//16B
            end 
        end

        always @ ( posedge Clk )begin
            if(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.FLGWEIGB_Rdy && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBFLGWEI_Val ) begin
                // for( in i=0; i < 2; i=i+1) begin
                  // for(int j=0; j<32 ; j=j+1)
                      $fwrite(fp_GBFLGWEI_Data[gv_i], "%b", top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBFLGWEI_Data);
                  $fwrite(fp_GBFLGWEI_Data[gv_i], "\n");//16B
                // end
            end 
        end


        // ************************************************************************************************
        // OUTPUT DUMP
        // 
        always @ ( posedge Clk )begin
            if(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBWEI_Instr_Rdy && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.WEIGB_Instr_Val ) begin
                for(int j=0; j<1 ; j=j+1)
                    $fwrite(fp_GBWEI_IDWei_r[gv_i], "%4d", top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.WEIGB_Instr_Data[0 +: 5]);
                $fwrite(fp_GBWEI_IDWei_r[gv_i], "\n");//16B
            end 
        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_val0 && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_rdy0 )begin
          	for(integer i = 0; i < 16; i = i + 1 )begin
              $fwrite(fp_PSUMGB_data0_r[gv_i], "%12d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_data0[32*i+:32]));
            end
            $fwrite(fp_PSUMGB_data0_r[gv_i],"\n");
          end

        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_val1 && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_rdy1 )begin
            for(integer i = 0; i < 16; i = i + 1 )begin
              $fwrite(fp_PSUMGB_data1_r[gv_i], "%12d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_data1[32*i+:32]));
            end
            $fwrite(fp_PSUMGB_data1_r[gv_i],"\n");
          end

        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_val2 && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_rdy2 )begin
            for(integer i = 0; i < 16; i = i + 1 )begin
              $fwrite(fp_PSUMGB_data2_r[gv_i], "%12d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_data2[32*i+:32]));
            end
            $fwrite(fp_PSUMGB_data2_r[gv_i],"\n");
          end

        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.ACTPEB_val  )begin
            for(integer i = 0; i < 16; i = i + 1 )begin // Only val because pop and !fifo_full
              $fwrite(fp_ACTPEB_data_r[gv_i], "%4d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.ACTPEB_data[8*i+:8]));
            end
            $fwrite(fp_ACTPEB_data_r[gv_i],"\n");
          end

        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.FLGACTPEB_val  )begin
            // for(integer i = 0; i < 32; i = i + 1 )begin
              $fwrite(fp_FLGACTPEB_data_r[gv_i], "%b", top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.FLGACTPEB_data);
            // end
            $fwrite(fp_FLGACTPEB_data_r[gv_i],"\n");
          end

        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_val0 && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_rdy0 )begin
            for(integer i = 0; i < 16; i = i + 1 )begin
              $fwrite(fp_GBPSUM_data0_r[gv_i], "%12d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_data0[32*i+:32]));
            end
            $fwrite(fp_GBPSUM_data0_r[gv_i],"\n");
          end
        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_val1 && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_rdy1 )begin
            for(integer i = 0; i < 16; i = i + 1 )begin
              $fwrite(fp_GBPSUM_data1_r[gv_i], "%12d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_data1[32*i+:32]));
            end
            $fwrite(fp_GBPSUM_data1_r[gv_i],"\n");
          end
        end

        always @ ( posedge Clk )begin
          if( top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_val2 && top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.PSUMGB_rdy2 )begin
            for(integer i = 0; i < 16; i = i + 1 )begin
              $fwrite(fp_GBPSUM_data2_r[gv_i], "%12d", $signed(top.TS3D_U.inst_PEL.PEB[gv_i].inst_PEB.GBPSUM_data2[32*i+:32]));
            end
            $fwrite(fp_GBPSUM_data2_r[gv_i],"\n");
          end
        end
    end
endgenerate

endmodule

`endif
