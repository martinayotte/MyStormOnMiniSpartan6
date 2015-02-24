This project is related to my work getting STORM Core SoftCpu working on MiniSpartan6+ board.

Unfortunately, it is only a PlayGround for now ...

Give it a try :

- Load MyStorm.xise into Xilinx ISE and compile it, it should give you the STORM_SoC_basic.bit file.
- Upload this design on your MiniSpartan6+ board using the following commands :
	xc3sprog -c ftdi ~/minispartan6/spiflasherLX9.bit
	xc3sprog -c ftdi -I ~/git-work/MyStormOnMiniSpartan6/STORM_SoC_basic.bit
- Then, start a Serial Terminal such as picocom, and reset your MiniSpartan6+ board, it should give you the Storm BootLoader, press '1' to Upload 'demo_program' ...
	picocom --send-cmd "cat ~/git-work/MyStormOnMiniSpartan6/demo_program/main.bin" -b 115200 /dev/ttyUSB3
- Play with the 'demo_program', look at the source, modify it, etc. 

