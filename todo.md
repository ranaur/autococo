add command
	run (autococo file)
		1) Reads the file
		2) Check URL
		3) executes autococo using the zipfile

Use local variables and general shell cleanup
	Test database.sh
Test ./process.sh colorcomputerarchive.com/repo/Disks/Pictures
Make other packages for multi disk zip
	setup:
		floppy0: disk1.dsk
		command: RUN"BOOT
	setup1:
		floppy0: disk2.dsk
		command: RUN"MENU
	...
