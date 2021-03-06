//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_test.v                                                 ////
////                                                              ////
////                                                              ////
////  This file is part of the "UART 16550 compatible" project    ////
////  http://www.opencores.org/cores/uart16550/                   ////
////                                                              ////
////  Documentation related to this project:                      ////
////  - http://www.opencores.org/cores/uart16550/                 ////
////                                                              ////
////  Projects compatibility:                                     ////
////  - WISHBONE                                                  ////
////  RS232 Protocol                                              ////
////  16550D uart (mostly supported)                              ////
////                                                              ////
////  Overview (main Features):                                   ////
////  UART core test bench                                        ////
////                                                              ////
////  Known problems (limits):                                    ////
////  A very simple test bench. Creates two UARTS and sends       ////
////  data on to the other.                                       ////
////                                                              ////
////  To Do:                                                      ////
////  More complete testing should be done!!!                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - gorban@opencores.org                                  ////
////      - Jacob Gorban                                          ////
////                                                              ////
////  Created:        2001/05/12                                  ////
////  Last Updated:   2001/05/17                                  ////
////                  (See log for the revision history)          ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Jacob Gorban, gorban@opencores.org        ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: uart_test.v,v $
// Revision 1.3  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//

`include "timescale.v"
module uart_test ();

`include "uart_defines.v"

reg				clkr;
reg				wb_rst_ir;
reg	[`UART_ADDR_WIDTH-1:0]	wb_addr_ir;
reg	[7:0]			wb_dat_ir;
wire	[7:0]			wb_dat_o;
reg				wb_we_ir;
reg				wb_stb_ir;
reg				wb_cyc_ir;
wire				wb_ack_o;
wire				int_o;
wire				pad_stx_o;
reg				pad_srx_ir;
wire				rts_o;
reg				cts_ir;
wire				dtr_o;
reg				dsr_ir;
reg				ri_ir;
reg				dcd_ir;
wire	[2:0]			wb_addr_i;
wire	[7:0]			wb_dat_i;




uart_top	uart_snd(
	clk, 
	
	// Wishbone signals
	wb_rst_i, wb_addr_i, wb_dat_i, wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o,	
	int_o, // interrupt request

	// UART	signals
	// serial input/output
	pad_stx_o, pad_srx_i,

	// modem signals
	rts_o, cts_i, dtr_o, dsr_i, ri_i, dcd_i

	);


// All the signals and regs named with a 1 are receiver fifo signals

reg	[`UART_ADDR_WIDTH-1:0]	wb1_addr_ir;
reg	[7:0]			wb1_dat_ir;
wire	[7:0]			wb1_dat_o;
reg				wb1_we_ir;
reg				wb1_stb_ir;
reg				wb1_cyc_ir;
wire				wb1_ack_o;
wire				int1_o;
wire				stx1_o;
reg				srx1_ir;
wire				rts1_o;
reg				cts1_ir;
wire				dtr1_o;
reg				dsr1_ir;
reg				ri1_ir;
reg				dcd1_ir;
wire	[2:0]			wb1_addr_i;
wire	[7:0]			wb1_dat_i;


uart_top	uart_rcv(
	clk, 
	
	// Wishbone signals
	wb_rst_i, wb1_addr_i, wb1_dat_i, wb1_dat_o, wb1_we_i, wb1_stb_i, wb1_cyc_i, wb1_ack_o,	
	int1_o, // interrupt request

	// UART	signals
	// serial input/output
	stx1_o, srx1_i,

	// modem signals
	rts1_o, cts1_i, dtr1_o, dsr1_i, ri1_i, dcd1_i

	);

assign clk = clkr;
assign wb_dat_i = wb_dat_ir;
assign wb_we_i = wb_we_ir;
assign wb_rst_i = wb_rst_ir;
assign wb_addr_i = wb_addr_ir;
assign wb_stb_i = wb_stb_ir;
assign wb_cyc_i = wb_cyc_ir;
assign pad_srx_i = pad_srx_ir;
assign cts_i = cts_ir;
assign dsr_i = dsr_ir;
assign ri_i = ri_ir;
assign dcd_i = dcd_ir;

assign wb1_dat_i = wb1_dat_ir;
assign wb1_we_i = wb1_we_ir;
assign wb1_addr_i = wb1_addr_ir;
assign wb1_stb_i = wb1_stb_ir;
assign wb1_cyc_i = wb1_cyc_ir;
assign srx1_i = srx1_ir;
assign cts1_i = cts1_ir;
assign dsr1_i = dsr1_ir;
assign ri1_i = ri1_ir;
assign dcd1_i = dcd1_ir;

/////////// CONNECT THE UARTS
always @(pad_stx_o)
begin
	srx1_ir = pad_stx_o;	
end

initial
begin
	clkr = 0;
	#20000 $finish;
end

task cycle;    // transmitter
input		we;
input	[2:0]	addr;
input	[7:0]	dat;		
begin
	@(negedge clk)
	wb_addr_ir <= #1 addr;
	wb_we_ir <= #1 we;
	wb_dat_ir <= #1 dat;
	wb_stb_ir <= #1 1;
	wb_cyc_ir <= #1 1;
	wait (wb_ack_o==1)
	@(posedge clk);
	wb_we_ir <= #1 0;
	wb_stb_ir<= #1 0;
	wb_cyc_ir<= #1 0;
end
endtask

task cycle1;   // receiver
input		we;
input	[2:0]	addr;
input	[7:0]	dat;		
begin
	@(negedge clk)
	wb1_addr_ir <= #1 addr;
	wb1_we_ir <= #1 we;
	wb1_dat_ir <= #1 dat;
	wb1_stb_ir <= #1 1;
	wb1_cyc_ir <= #1 1;
	wait (wb1_ack_o==1)
	@(posedge clk);
	wb1_we_ir <= #1 0;
	wb1_stb_ir<= #1 0;
	wb1_cyc_ir<= #1 0;
end
endtask

// The test sequence
initial
begin
	#1 wb_rst_ir = 1;
	#10 wb_rst_ir = 0;
	wb_stb_ir = 0;
	wb_cyc_ir = 0;
	wb_we_ir = 0;
	
	//write to lcr. set bit 7
	//wb_cyc_ir = 1;
	cycle(1, `UART_REG_LC, 8'b10011011);
	// set dl to divide by 3
	cycle(1, `UART_REG_DL1, 8'd2);
	@(posedge clk);
	@(posedge clk);
	// restore normal registers
	cycle(1, `UART_REG_LC, 8'b00011011);
	$display("%m : %t : sending : %b", $time, 8'b01101011);
	cycle(1, 0, 8'b01101011);
	@(posedge clk);
	@(posedge clk);
	$display("%m : %t : sending : %b", $time, 8'b01000101);
	cycle(1, 0, 8'b01000101);
	#100;
	wait (uart_snd.regs.state==0 && uart_snd.regs.transmitter.tf_count==0);
end

// receiver side
initial
begin
	#11;
	wb1_stb_ir = 0;
	wb1_cyc_ir = 0;
	wb1_we_ir = 0;
	
	//write to lcr. set bit 7
	//wb_cyc_ir = 1;
	cycle1(1, `UART_REG_LC, 8'b10011011);
	// set dl to divide by 3
	cycle1(1, `UART_REG_DL1, 8'd2);
	@(posedge clk);
	@(posedge clk);
	// restore normal registers
	cycle1(1, `UART_REG_LC, 8'b00011011);
	wait(uart_rcv.regs.receiver.rf_count == 2);
	cycle1(0, 0, 0);
	$display("%m : %t : Data out: %b", $time, wb1_dat_o);
	@(posedge clk);
	cycle1(0, 0, 0);
	$display("%m : %t : Data out: %b", $time, wb1_dat_o);
	$display("%m : Finish");
	$finish;
end

//always @(uart_rcv.regs.rstate)
//begin
//	$display($time,": Receiver state changed to: ", uart_rcv.regs.rstate);
//end

always
begin
	#5 clkr = ~clk;
end

endmodule
