set DESIGN_NAME = $1
set VT = $2
set MARGIN = $3
set UNGROUP = $4
set QRCDEF = $5
set NOTE = $6

if ($DESIGN_NAME == "ASIC") then
    set SDC_FILE=ASIC.sdc 
    echo "<<<<<<<<<<<<<<<<<<<set SDC=ASIC.sdc>>>>>>>>>>>>>>>>>>>>>>"
else 
    set SDC_FILE=module.sdc 
    echo "<<<<<<<<<<<<<<<<<<<set SDC=module.sdc>>>>>>>>>>>>>>>>>>>>>>"
endif

if ($VT == "3vt") then
    set TECH_SETTING=tech_settings.tcl
else if($VT == "rvt") then
    set TECH_SETTING=tech_settings_rvt.tcl  
else 
    echo "<<<<<<<<<<<<<<<<<<<error VT>>>>>>>>>>>>>>>>>>>>>>"
    exit  
endif 

if($MARGIN == "") then 
    echo "<<<<<<<<<<<<<<<<<<<empty MARGIN>>>>>>>>>>>>>>>>>>>>>>"
    exit
endif

set DATE_VALUE = `date "+%y%m%d" ` 

mkdir -p $DESIGN_NAME $DESIGN_NAME/${DATE_VALUE}_Margin_${MARGIN}_${UNGROUP}_Track_${VT}_Note_${NOTE}

cd ./$DESIGN_NAME/${DATE_VALUE}_Margin_${MARGIN}_${UNGROUP}_Track_${VT}_Note_${NOTE}
mkdir -p TS3D/zhoucc

cp -r ../../../source/ TS3D/zhoucc/
cp -r ../../script/ TS3D/zhoucc/
cp -r ../../../../liumin TS3D/
cp -r ../../../../qiusy TS3D/
mkdir ../source
cp -r ../../../source/include ../source/

rm ./config_temp.tcl
rm ./synthesize.tcl
echo "set DESIGN_NAME $DESIGN_NAME" >> ./config_temp.tcl
echo "set MARGIN $MARGIN" >> ./config_temp.tcl
echo "set DATE_VALUE $DATE_VALUE" >> ./config_temp.tcl
echo "set TECH_SETTING $TECH_SETTING" >> ./config_temp.tcl
echo "set SDC_FILE $SDC_FILE" >> ./config_temp.tcl
# if ($DESIGN_NAME == "ASIC") then
#     echo "set SDC_FILE $SDC_FILE" >> ./config_temp.tcl
#     set_attribute preserve true [find / -instance *PAD*]
if( $UNGROUP == "group") then 
  echo "set UNGROUP none" >> ./config_temp.tcl
else if( $UNGROUP == "ungroup") then 
  echo "set UNGROUP both" >> ./config_temp.tcl
else
    echo "<<<<<<<<<<<<<<<<<<<error UNGROUP>>>>>>>>>>>>>>>>>>>>>>"
    exit  
endif 

rm -rf work
rm -rf WORK

if ( $QRCDEF == "QRCDEF") then 
    echo "###### Adding Physical Synthesis Script ######                                                                " >> ./synthesize.tcl
    echo "set_attribute qrc_tech_file /workspace/technology/umc/55nm_201908/pdk/FDK/calibre/LPE/QRC/Cmax/qrcTechFile /  " >> ./synthesize.tcl
    echo "set_attribute enc_temp_dir rc_enc /                                                                           " >> ./synthesize.tcl
    echo "report ple                                                                                                    " >> ./synthesize.tcl
    echo "read_def /workspace/home/caoxg/PKU_VLSI_202008/ASIC.def                                                       " >> ./synthesize.tcl
    echo "###### Synthesis ######                                                                                       " >> ./synthesize.tcl
    echo "# synthesize -to_generic -effort medium                                                                       " >> ./synthesize.tcl
    echo "synthesize -to_placed                                                                                         " >> ./synthesize.tcl
    echo "synthesize -to_placed -incremental                                                                            " >> ./synthesize.tcl
else 
    echo "synthesize -to_mapped -eff high -no_incremental" >> ./synthesize.tcl
endif

echo "<<<<<<<<<<<<<<<<<<<rc syn>>>>>>>>>>>>>>>>>>>>>>"
rc  -overwrite -f ../../script/syn_RISC.scr -log ./$DESIGN_NAME.log
