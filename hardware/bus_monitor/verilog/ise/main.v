`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:07:54 06/25/2012 
// Design Name: 
// Module Name:    main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
// NOTE : DO lAMP TEST OR BLANKING OF DISPLAYS ON RESET
// 		 MAKE SURE MUXER NEVER STOPS ON RESET ETC. -> OVERLOADING DISPLAY SEMENTS

`define hardware_rev_1_1;

//////////////////////////////////////////////////////////////////////////////////
module main(
    input [15:0] A_CPU,
    inout [7:0] D_CPU,
    input WR_CPU,
    input RD_CPU,
    input IO_REQ_CPU,
    input MEM_REQ_CPU,
	 
    //output reg BUS_REQ_CPU,
	 inout BUS_REQ_CPU,

    input BUS_ACK_CPU,
 
	 //output reg INT_CPU,
	 inout INT_CPU,

    //output reg NMI_CPU,
	 inout NMI_CPU,
	 
    input M1_CPU,
    input CLK_CPU,
    input RFSH_CPU,
    input HALT_CPU,

    //output reg WAIT_CPU,
	 inout WAIT_CPU,

    input IEI_CPU,

    output reg [15:0] A_EX,
    inout [7:0] D_EX,
    output reg WR_EX,
    output reg RD_EX,
    output reg IO_REQ_EX,
    output reg MEM_REQ_EX,
    input BUS_REQ_EX,
    output reg BUS_ACK_EX,
    input INT_EX,
    input NMI_EX,
    output reg M1_EX,
    output CLK_EX,
    output reg RFSH_EX,
    output reg HALT_EX,
    input WAIT_EX,
    output reg IEI_EX,
 
	 input RESET_EX, 
	 output RESET_CPU, 

	 output [6:0] SEG_OUT,
	 output [5:0] AC_SEL,
	 input [2:0] SWITCH,
	 input rsv_300,
	 inout [7:0] PIO,
	 
	 input CLK_OSC,
	 input RSV_GCK2,
	 
	 output DEBUG_0,
	 output DEBUG_1,
	 output DEBUG_2,
	 output DEBUG_3,
	 output DEBUG_4,
	 output DEBUG_5,
	 output DEBUG_6,
	 output DEBUG_7,
	 output DEBUG_8,
	 output DEBUG_9,	 
	 output DEBUG_10,
	 output DEBUG_11	 
    );

	prescaler ps (
		.clk(CLK_OSC),
		.qe(clk_ed),
		//.qe(clk_debouncer),
		.qc(clk_digit)
	);
	assign clk_debouncer = clk_ed;


	// switch debouncer
	wire [3:0] switch_db; /* synthesis keep = 1 */
	
	debouncer db0 (
		.out(switch_db[0]),  // L-active  // updated on negedge of clk 
		//.in(SWITCH[0]),  		// L-active
		.in(rsv_300),  		// L-active  // S4.7
		.clk(clk_debouncer)  
	);
	assign mode = switch_db[0]; // L - bus monitor mode, H - pio mode
	
	debouncer db1 (
		.out(switch_db[1]),  // L-active  // updated on negedge of clk // 
		.in(SWITCH[1]),  		// L-active // S2
		.clk(clk_debouncer)  
	);
	wire go_step = switch_db[1]; // go step

	debouncer db2 (
		.out(switch_db[2]),  // L-active  // updated on negedge of clk  // reset
		.in(SWITCH[2]),  		// L-active // S1
		.clk(clk_debouncer)  
	);
	assign reset_on_board = switch_db[2]; // reset on board
	
	debouncer db3 (
		.out(switch_db[3]),  // L-active  // updated on negedge of clk 
		//.in(SWITCH[0]),  		// L-active
		.in(SWITCH[0]),  		// L-active // S3
		.clk(clk_debouncer)  
	);
	assign stepper_on = switch_db[3]; // L -> free run mode / H -> step mode
	
	
	// route internal pio signals out to PIO 
	wire [23:0] pio_int;
	assign PIO[7:0] = pio_int[7:0];
	
	// reset and clk passed right through
`ifdef hardware_rev_1_1
	assign RESET_CPU = ~RESET_EX | ~reset_on_board; // because of transistor T100
	assign reset_cpu_int = ~RESET_CPU;
`else	
	assign RESET_CPU = (!RESET_EX | ~reset_on_board) ? 1'b0 : 1'bz;
	assign reset_cpu_int = RESET_CPU;	
`endif

	
	assign CLK_EX = CLK_CPU;
	
	reg int_cpu_pre = 1;
	reg nmi_cpu_pre = 1;
	reg bus_req_cpu_pre = 1;
	reg wait_cpu_pre = 1;
	
	always @*
		begin
			if (!reset_cpu_int) 
				begin
					A_EX 			<= 16'hzzzz;
					WR_EX 		<= 1;
					RD_EX			<= 1;
					IO_REQ_EX	<= 1;
					MEM_REQ_EX	<= 1;
					BUS_ACK_EX	<= 1'bz;
					M1_EX			<= 1;
					RFSH_EX		<= 1;
					HALT_EX		<= 1;
					IEI_EX		<= 1'bz;
					
					//WAIT_CPU		<= 1'bz;
					wait_cpu_pre <= 1'b1;
					
					//INT_CPU		<= 1'bz;
					int_cpu_pre <= 1'b1;
					
					//NMI_CPU		<= 1'bz;
					nmi_cpu_pre <= 1'b1;
					
					//BUS_REQ_CPU	<= 1'bz;					
					bus_req_cpu_pre <= 1'b1;
				end
			else
				begin
					A_EX			<= A_CPU;
					WR_EX 		<= WR_CPU;
					RD_EX			<= RD_CPU;
					IO_REQ_EX	<= IO_REQ_CPU;
					MEM_REQ_EX	<= MEM_REQ_CPU;
					BUS_ACK_EX	<= BUS_ACK_CPU;
					M1_EX			<= M1_CPU;
					RFSH_EX		<= RFSH_CPU;
					HALT_EX		<= HALT_CPU;
					IEI_EX		<= IEI_CPU;
					
					//WAIT_CPU		<= (!WAIT_EX) 		? 0 : 1'bz;
					wait_cpu_pre	<= WAIT_EX;
					
					//INT_CPU	<= (!INT_EX) 		? 0 : 1'bz;
					int_cpu_pre		<= INT_EX;
					
					//NMI_CPU		<= (!NMI_EX) 		? 0 : 1'bz;
					nmi_cpu_pre		<= NMI_EX;
					
					//BUS_REQ_CPU	<= (!BUS_REQ_EX) 	? 0 : 1'bz;
					bus_req_cpu_pre	<= BUS_REQ_EX;
				end
			end
	
	wire wait_stepper;
	assign WAIT_CPU	= (!wait_cpu_pre)	? 0 : 1'bz;
	assign WAIT_CPU	= (stepper_on & !wait_stepper)	? 0 : 1'bz;
	assign INT_CPU 	= (!int_cpu_pre) 	? 0 : 1'bz;
	assign NMI_CPU 	= (!nmi_cpu_pre) 	? 0 : 1'bz;	
	assign BUS_REQ_CPU = (!bus_req_cpu_pre) ? 0 : 1'bz;
	
	// CPU write 
	assign D_EX = (!WR_CPU & RD_CPU & reset_cpu_int) ? D_CPU : 8'hzz;
	
	// CPU read
	reg cpu_io_read_access = 1;
	assign D_CPU = (!cpu_io_read_access) ? D_EX : 8'hzz;
	
	always @*
		begin
			if (A_CPU[7:0] > 8'h7F) 
				begin
					if (!RD_CPU & !IO_REQ_CPU & reset_cpu_int) cpu_io_read_access <= 0;
					else cpu_io_read_access <= 1;
				end
			else cpu_io_read_access <= 1;			
		end
	
	
	reg [2:0] digit;
	always @(posedge clk_digit)
		begin
			digit <= digit + 1;
		end
			
			
	// muxer
	reg [3:0] dec_in;
	always @(negedge clk_digit)
		begin
			if (!mode) // BUS monitor mode
				case (digit)
					0	:	dec_in <= D_CPU[3:0];
					1	:	dec_in <= D_CPU[7:4];
					2	:	dec_in <= A_CPU[3:0];
					3	:	dec_in <= A_CPU[7:4];				
					4	:	dec_in <= A_CPU[11:8]; 
					5	:	dec_in <= A_CPU[15:12]; 
					default	:	dec_in <= 0;
				endcase
			else // PIO mode
				case (digit)
					5	:	dec_in <= pio_int[23:20]; // MS Digit
					4	:	dec_in <= pio_int[19:16];
					3	:	dec_in <= pio_int[15:12];
					2	:	dec_in <= pio_int[11:8];				
					1	:	dec_in <= pio_int[7:4];
					0	:	dec_in <= pio_int[3:0]; // LS Digit
					default	:	dec_in <= 0;
				endcase
		end	
	
	
	// common anode/cathode decoder
	reg [5:0] ac_sel_pre;
	always @(negedge clk_digit)
		begin
				case (digit)
					0	:	ac_sel_pre <= 6'h01;
					1	:	ac_sel_pre <= 6'h02;
					2	:	ac_sel_pre <= 6'h10;
					3	:	ac_sel_pre <= 6'h20;
					4	:	ac_sel_pre <= 6'h04;
					5	:	ac_sel_pre <= 6'h08;					
					default	:	ac_sel_pre <= 0;	
				endcase
		end
		
	assign AC_SEL = ~ac_sel_pre; // selected digit outputs L
		
		
		
		
		
// 7-segment encoding
//      0
//     ---
//  5 |   | 1
//     --- <--6
//  4 |   | 2
//     ---
//      3

	reg [6:0] seg_out_pre;
   always @*
      case (dec_in)
          4'b0001 : seg_out_pre <= 7'b1111001;   // 1
          4'b0010 : seg_out_pre <= 7'b0100100;   // 2
          4'b0011 : seg_out_pre <= 7'b0110000;   // 3
          4'b0100 : seg_out_pre <= 7'b0011001;   // 4
          4'b0101 : seg_out_pre <= 7'b0010010;   // 5
          4'b0110 : seg_out_pre <= 7'b0000010;   // 6
          4'b0111 : seg_out_pre <= 7'b1111000;   // 7
          4'b1000 : seg_out_pre <= 7'b0000000;   // 8
          4'b1001 : seg_out_pre <= 7'b0010000;   // 9
          4'b1010 : seg_out_pre <= 7'b0001000;   // A
          4'b1011 : seg_out_pre <= 7'b0000011;   // b
          4'b1100 : seg_out_pre <= 7'b1000110;   // C
          4'b1101 : seg_out_pre <= 7'b0100001;   // d
          4'b1110 : seg_out_pre <= 7'b0000110;   // E
          4'b1111 : seg_out_pre <= 7'b0001110;   // F
          default : seg_out_pre <= 7'b1000000;   // 0
      endcase
		
	assign SEG_OUT[6:0] = ~seg_out_pre[6:0]; // invert segments for common anode display
	
	
	// PIO
	reg_file_z80 rf (
		.a_cpu(A_CPU[7:0]), 
		.d_cpu(D_CPU), 
		.wr_cpu(WR_CPU), 
		.rd_cpu(RD_CPU),
		.io_req_cpu(IO_REQ_CPU), 
		.reset_cpu(reset_cpu_int),
		.clk_cpu(CLK_CPU),
		.pio(pio_int[23:0])
	);	


	// edge detectors for CPU control signals
	// WR_CPU
	edge_detector ed0 (
		.out(edge_wr),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(WR_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_WR = !edge_wr; // LED has anode on VCC
	
	// RD_CPU
	edge_detector ed1 (
		.out(edge_rd),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(RD_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_RD = !edge_rd; // LED has anode on VCC	

	// IO_REQ_CPU
	edge_detector ed2 (
		.out(edge_ioreq),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(IO_REQ_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_IOREQ = !edge_ioreq; // LED has anode on VCC	

	// MEM_REQ_CPU
	edge_detector ed3 (
		.out(edge_memreq),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(MEM_REQ_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_MEMREQ = !edge_memreq; // LED has anode on VCC	

	// M1_CPU
	edge_detector ed4 (
		.out(edge_m1),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(M1_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_M1 = !edge_m1; // LED has anode on VCC	

	// INT_CPU
	edge_detector ed5 (
		.out(edge_int),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(INT_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_INT = !edge_int; // LED has anode on VCC	

	// NMI_CPU
	edge_detector ed6 (
		.out(edge_nmi),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(NMI_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_NMI = !edge_nmi; // LED has anode on VCC	

	// IEI_CPU
	edge_detector ed7 (
		.out(edge_iei),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(IEI_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_IEI = !edge_iei; // LED has anode on VCC	

	// HALT_CPU
	edge_detector ed8 (
		.out(edge_halt),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(HALT_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_HALT = !edge_halt; // LED has anode on VCC	

	// WAIT_CPU
	edge_detector ed9 (
		.out(edge_wait),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(WAIT_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_WAIT = !edge_wait; // LED has anode on VCC	

	// BUSACK_CPU
	edge_detector ed10 (
		.out(edge_busack),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(BUS_ACK_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_BUSACK = !edge_busack; // LED has anode on VCC	

	// BUSREQ_CPU
	edge_detector ed11 (
		.out(edge_busreq),	// outputs L on edge detection
		.clk(clk_ed),	
		.in(BUS_REQ_CPU),			// input signal
		.edge_sel(1'b0),		// H posedge detection mode, L negedge detection mode
		.ext_rst_en(1'b0),	// H= manual reset, L= auto reset
		.reset(1'b1)			// L resets detector in manual reset mode - don't care here
		);
	assign LED_BUSREQ = !edge_busreq; // LED has anode on VCC	

	assign DEBUG_6 = LED_WR; // ok
	assign DEBUG_7 = LED_RD; // ok
	assign DEBUG_4 = LED_IOREQ; // ok
	assign DEBUG_5 = LED_MEMREQ; // ok
	assign DEBUG_3 = LED_M1; // ok
	assign DEBUG_2 = LED_INT ? 1'bz : 1'b0; // ok
	assign DEBUG_1 = LED_NMI ? 1'bz : 1'b0; // ok
	assign DEBUG_0 = LED_IEI ? 1'bz : 1'b0; // ok
	assign DEBUG_8 = LED_HALT; // ok
	assign DEBUG_9 = LED_WAIT; // ok
	assign DEBUG_10 = LED_BUSACK; // ok
	assign DEBUG_11 = LED_BUSREQ; // ok


	///// CYCLE STEPPER ////////////////
	assign CLR_FF2 = ~((M1_CPU & IO_REQ_CPU) & ~(~MEM_REQ_CPU & RFSH_CPU));
//	assign CLR_FF2 = ~((M1_CPU & IO_REQ_CPU) & MEM_REQ_CPU);		
		
   FDCPE #(
      .INIT(1'b1) // Initial value of register (1'b0 or 1'b1)
		) FDCPE_inst (
      .Q(wait_stepper),      // Data output
      .C(~go_step),      // Clock input
      .CE(1'b1),    // Clock enable input
      .CLR(~CLR_FF2),  // Asynchronous clear input
      .D(1'b1),      // Data input
      .PRE(~reset_on_board)   // Asynchronous set input
   );		
		
endmodule
