#!/usr/bin/kermit +

define set_if {
	set exit warning on
	set modem type none
	set line /dev/ttyS5
	set speed 9600
	#set speed 19200
	#set speed 38400
	set flow rts/cts
	set carrier-watch off
	set protocol xmodem
	set duplex full
	set output pacing 30
	set input echo on
	#set input echo off
	
	output \13
	wait
	output \13
	wait
	}


#communication error routine
define close_connection {
	close
	echo
	echo { F A I L }
	echo {---------}
	echo
	echo
	echo P O W E R   O F F  !!!
	echo
	EXIT 1
	}


define ram_error_1 {
	echo \v(input)
	echo check FLASH IC201
	close_connection
	}

define ram_error_2 {
	echo \v(input)
	echo check SRAM IC203
	close_connection
	}

define ram_error_3 {
	echo \v(input)
	echo check SRAM IC202, IC203
	close_connection
	}


define clear_user_ram_small {
	echo
	echo >>> clearing lower user ram
	output testmem\13
	set input buffer-length
	input 7 7FFF
		IF FAIL ram_error_1
	wait
	output fill\13
	input 2 dat:
		IF FAIL close_connection
	output 00\13
	input 2 bytes:
		IF FAIL close_connection
	output 6000\13
	input 1 adr:
		IF FAIL close_connection
	output 2000\13
	input 3 cmd>
		IF FAIL close_connection
	}


define clear_ram_full {
	echo
	echo >>> clearing ram
	output testmem\13
	set input buffer-length
	input 7 FFFF
		IF FAIL ram_error_3
	wait
	output fill\13
	input 2 dat:
		IF FAIL close_connection
	output 00\13
	input 2 bytes:
		IF FAIL close_connection
	output E000\13
	input 1 adr:
		IF FAIL close_connection
	output 2000\13
	input 4 cmd>
		IF FAIL close_connection
	}


define test_display {
	echo
	echo >>> test display
	echo
	echo set S904-1 to ON
	echo set S904-7 to OFF
	echo
	echo hit any key when ready
	run read

	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 50\13
	input 2 {io_data: }
		if fail close_connection
	output 88\13
	input 2 {cmd> }
		if fail close_connection

	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 51\13
	input 2 {io_data: }
		if fail close_connection
	output 88\13
	input 2 {cmd> }
		if fail close_connection

	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 52\13
	input 2 {io_data: }
		if fail close_connection
	output 88\13
	input 2 {cmd> }
		if fail close_connection

	echo
	echo all displays show 88
	echo
	echo hit any key when ok
	run read
	}


define test_pio_ab {
#	set_if
	#set input echo on

	echo
	echo >>> writing test data set 1 into PIO A
	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 0A\13
	input 2 {io_data: }
		if fail close_connection
	output CF\13	#bit mode
	input 2 {cmd> }
		if fail close_connection
	output portout\13
	output 0A\13
	input 2 {io_data: }
		if fail close_connection
	output 3C\13	# B0, B1, B6, B7 become output
	input 2 {cmd> }
		if fail close_connection

	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 08\13
	input 2 {io_data: }
		if fail close_connection
	output 41\13
	input 2 {cmd> }
		if fail close_connection


	echo
	echo >>> reading test data set 1 from PIO B
	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 0B\13
	input 2 {io_data: }
		if fail close_connection
	output CF\13	#bit mode
	input 2 {cmd> }
		if fail close_connection
	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 0B\13
	input 2 {io_data: }
		if fail close_connection
	output FF\13	#all become input
	input 2 {cmd> }
		if fail close_connection

	output portin\13
	input 2 {io_addr: }
		if fail close_connection
	output 09\13
	input 2 {io_data: 7D}
		if fail close_connection
	input 2 {cmd> }
		if fail close_connection


	echo
	echo >>> writing test data set 2 into PIO A
	output portout\13
	input 2 {io_addr: }
		if fail close_connection
	output 08\13
	input 2 {io_data: }
		if fail close_connection
	output 82\13
	input 2 {cmd> }
		if fail close_connection


	echo
	echo >>> reading test data set 2 from PIO B
	output portin\13
	input 2 {io_addr: }
		if fail close_connection
	output 09\13
	input 2 {io_data: BE}
		if fail close_connection
	input 2 {cmd> }
		if fail close_connection
	}

define test_i2c {
	set_if
	#connect
	echo
	echo >>> writing test data set 1 into I2C FLASH

	#set input echo on

	output i1f\13
	input 2 {f1_sel: }
		if fail close_connection
	output A0\13
	input 2 {f1_adr: }
		if fail close_connection
	output 00\13
	input 2 {f1_daw: }
		if fail close_connection
	output 55\13
	input 2 {cmd> }
		if fail close_connection

	echo
	echo >>> reading test data set 1 from I2C FLASH

	output i1f\13
	input 2 {f1_sel: }
		if fail close_connection
	output A1\13
	input 2 {f1_adr: }
		if fail close_connection
	output 00\13
	input 2 {f1_dar: 55}
		if fail close_connection
	input 2 {cmd> }
		if fail close_connection


	echo
	echo >>> writing test data set 2 into I2C FLASH

	#set input echo on

	output i1f\13
	input 2 {f1_sel: }
		if fail close_connection
	output A0\13
	input 2 {f1_adr: }
		if fail close_connection
	output 00\13
	input 2 {f1_daw: }
		if fail close_connection
	output 00\13
	input 2 {cmd> }
		if fail close_connection

	echo
	echo >>> reading test data set 2 from I2C FLASH

	output i1f\13
	input 2 {f1_sel: }
		if fail close_connection
	output A1\13
	input 2 {f1_adr: }
		if fail close_connection
	output 00\13
	input 2 {f1_dar: 00}
		if fail close_connection
	input 2 {cmd> }
		if fail close_connection

#	set input echo on

	echo
	echo >>> writing test data set 1 into I2C PIO
	output i1p\13
	input 2 {p1_sel: }
		if fail close_connection
	output 40\13
	input 2 {p1_out: }
		if fail close_connection
	output 55\13
	input 2 {cmd> }
		if fail close_connection
	echo
	echo D7..0 : ON OFF ON OFF ON OFF ON OFF 
	echo
	echo hit any key when ok
	run read

	echo
	echo >>> reading test data set 1 from I2C PIO
	output i1p\13
	input 2 {p1_sel: }
		if fail close_connection
	output 41\13
	input 2 {p1_in:  55}
		if fail close_connection
	input 2 {cmd> }
		if fail close_connection

	echo
	echo >>> writing test data set 2 into I2C PIO
	output i1p\13
	input 2 {p1_sel: }
		if fail close_connection
	output 40\13
	input 2 {p1_out: }
		if fail close_connection
	output AA\13
	input 2 {cmd> }
		if fail close_connection
	echo
	echo D7..0 : OFF ON OFF ON OFF ON OFF ON
	echo
	echo hit any key when ok
	run read

	echo
	echo >>> reading test data set 2 from I2C PIO
	output i1p\13
	input 2 {p1_sel: }
		if fail close_connection
	output 41\13
	input 2 {p1_in:  AA}
		if fail close_connection
	input 2 {cmd> }
		if fail close_connection
	}
	

define test_upload {
	set_if
	echo
	echo >>> uploading test data
	output load\13
	input 1 _adr:
		IF FAIL close_connection
	output 2000\13
	input 2 {xmodem !}
		IF FAIL close_connection
	close
	set line /dev/ttyS5
	send dummy.bin
		IF FAIL close_connection
	}
	
#################################################


	run clear
	set_if
	
	if equal \%1 -i goto I2C_TEST
	if equal \%1 -p goto PIO_TEST
	if equal \%1 -r goto ROM_TEST
	if equal \%1 -u goto upload_test
	if equal \%1 -s goto standard_test


:standard_test
#	set_if
	test_display
	clear_user_ram_small
#exit

:ROM_TEST
#	set_if
#rom test program upload
	echo
	echo >>> uploading ROM-test program
	output load\13
	input 1 _adr:
		IF FAIL close_connection
	output 2000\13
	input 2 {xmodem !}
		IF FAIL close_connection
	close
	set line /dev/ttyS5
	send romtest.bin
		IF FAIL close_connection

#ROM check
	echo
	echo >>> checksumming ROM
	output call\13
	input 2 mem_adr:
		IF FAIL close_connection
	output 2000\13
	input 2 cmd>
		IF FAIL close_connection
	output viewmem\13
	input 1 mem_adr:
		IF FAIL close_connection
	output 2100\13
	input 2 {2100 84}			# enter expected check sum here
		IF FAIL close_connection
	wait 2
	set input buffer-length


#copying boot rom into IC201
	echo
	echo >>> copying boot loader into IC201

	output eraseflash\13
	input 2 {flash-id: 3786}
		if fail close_connection
	input 10 cmd>
		if fail close_connection

	output prgflash\13
	input 2 {source_adr: }
		if fail close_connection
	output 0000\13
	input 2 {number_of_bytes: }
		if fail close_connection
	output 1000\13
	input 2 {destination_adr: }
		if fail close_connection
	output 8000\13
	input 2 {flash-id: 3786}
		if FAIL close_connection
	#input 3 {1F}
	#	if fail close_connection
	input 10 cmd>
		if fail close_connection

	#veryfiying
	output comp\13
	input 2 {source_adr: }
		if fail close_connection
	output 0000\13
	input 2 {number_of_bytes: }
		if fail close_connection
	output 1000\13
	input 2 {destination_adr: }
		if fail close_connection
	output 8000\13
	input 2 read:	# if "read" red, verify has failed
		if success close_connection # for kermit this is a "successful" query


:PIO_TEST
#	test_pio_ab


:I2C_TEST
	test_i2c

:upload_test
#	test_upload

	echo
	echo press S901 for one second
	echo
	echo hit any key when ok
	run read

	echo
	echo all displays show FF
	echo
	echo hit any key when ok
	run read

	echo
	echo
	echo
	echo P A S S
	echo
	echo
	echo POWER OFF
	echo
	echo set S904-1 to ON
	echo set S904-7 to ON

exit

