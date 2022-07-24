targets:
	@echo "targets: [ synth | power | STA | clean ]"

synth : 	
		rc -nogui -overwrite -f ./script/syn_RISC.scr -log logs/rc.log -cmd logs/rc.cmd

power : 	
		rc -nogui -overwrite -f ./script/syn_RISC_power.scr -log logs/rc_power.log -cmd logs/rc_power.cmd

STA :
		tempus -64 -nowin -overwrite -init script/STA_RISC_setup.scr -log logs/STA_RISC_setup.log -cmd logs/STA_RISC_setup.cmd

clean:
	        rm -f rc* logs/* report/* gate/* ;
		rm -rf  ./fv report/*

