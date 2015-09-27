`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:18:56 11/09/2009 

// 
// V1.0 initial

//////////////////////////////////////////////////////////////////////////////////

module reg_file_z80(a_cpu,d_cpu,wr_cpu,rd_cpu,io_req_cpu,clk_cpu,pio,
					reset_cpu);

	input [7:0] a_cpu;
	inout [7:0] d_cpu;
	input wr_cpu;
	input rd_cpu;	 
	input io_req_cpu;
	input reset_cpu;
	input clk_cpu;
	 
	inout [23:0] pio; 
	// synthesis attribute PULLUP of pio[7:0] is true;
	
	parameter BASE_ADR = 8'h50;
	parameter reg_0 = BASE_ADR+0;
	parameter reg_1 = BASE_ADR+1;
	parameter reg_2 = BASE_ADR+2;
	
	// writing to register file related
	wire ioreq_or_wr;
	assign ioreq_or_wr = io_req_cpu | wr_cpu;	// io write access when io_req and wr_cpu are low

	// reading from register file related
	wire ioreq_or_rd;
	assign ioreq_or_rd = io_req_cpu | rd_cpu;	//  io read access when ioreq and rd are low
	reg [2:0] read_en = -1;
	reg [23:0] out_reg = -1;

	always @(posedge clk_cpu)
			begin
				
				casex ({reset_cpu,ioreq_or_wr,ioreq_or_rd})
					3'b0xx :	begin
									out_reg[23:0] <= -1;
									read_en [2:0] <= -1;
								end 
								
					3'b101 :	begin				//	writing to register file
									if (a_cpu == reg_0) out_reg [7:0] <= d_cpu;
									if (a_cpu == reg_1) out_reg [15:8] <= d_cpu;
									if (a_cpu == reg_2) out_reg [23:16] <= d_cpu;
								end
					
					3'b110 : begin 			//	reading from register file
									case(a_cpu)
										reg_0: read_en[0] <= 0;
										reg_1: read_en[1] <= 0;
										reg_2: read_en[2] <= 0;
									endcase
								end

					default : 
								begin
									read_en <= -1;
								end 
				endcase
			end


	// selected register content is placed on cpu data bus on io read access, otherwise place high-z
	assign d_cpu = read_en[0] ? 8'hzz : pio [7:0];
	assign d_cpu = read_en[1] ? 8'hzz : pio [15:8];
	assign d_cpu = read_en[2] ? 8'hzz : pio [23:16];


	assign pio[0] = out_reg[0] ? 1'bz : 0;
	assign pio[1] = out_reg[1] ? 1'bz : 0;
	assign pio[2] = out_reg[2] ? 1'bz : 0;
	assign pio[3] = out_reg[3] ? 1'bz : 0;
	assign pio[4] = out_reg[4] ? 1'bz : 0;
	assign pio[5] = out_reg[5] ? 1'bz : 0;
	assign pio[6] = out_reg[6] ? 1'bz : 0;
	assign pio[7] = out_reg[7] ? 1'bz : 0;

	assign pio[8] = out_reg[8];
	assign pio[9] = out_reg[9];
	assign pio[10] = out_reg[10];	
	assign pio[11] = out_reg[11];	
	assign pio[12] = out_reg[12];	
	assign pio[13] = out_reg[13];	
	assign pio[14] = out_reg[14];	
	assign pio[15] = out_reg[15];	

	assign pio[16] = out_reg[16];	
	assign pio[17] = out_reg[17];	
	assign pio[18] = out_reg[18];	
	assign pio[19] = out_reg[19];		
	assign pio[20] = out_reg[20];	
	assign pio[21] = out_reg[21];	
	assign pio[22] = out_reg[22];	
	assign pio[23] = out_reg[23];		
	//assign pio[23:20] = 4'h3;
endmodule

