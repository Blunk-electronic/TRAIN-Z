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
	}


#communication error routine
define close_connection {
	close
	echo
	echo { F A I L }
	echo {---------}
	echo
	echo
	echo S P A N N U N G  A U S !
	echo
	EXIT 1
	}

	
#################################################


	run clear

	set_if

#copying boot rom into IC201
	echo
	echo >>> copying boot loader into IC201

	output \13
	wait
	output \13
	wait
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

	echo
	echo
	echo
	echo P A S S
	echo
	echo
	echo S P A N N U N G   A U S S C H A L T E N !
	echo
exit

