//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_top.v                                                  ////
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
////  UART core top level.                                        ////
////                                                              ////
////  Known problems (limits):                                    ////
////  Note that transmitter and receiver instances are inside     ////
////  the uart_regs.v file.                                       ////
////                                                              ////
////  To Do:                                                      ////
////  Nothing so far.                                             ////
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
// $Log: not supported by cvs2svn $
// Revision 1.4  2001/05/31 20:08:01  gorban
// FIFO changes and other corrections.
//
// Revision 1.3  2001/05/21 19:12:02  gorban
// Corrected some Linter messages.
//
// Revision 1.2  2001/05/17 18:34:18  gorban
// First 'stable' release. Should be sythesizable now. Also added new header.
//
// Revision 1.0  2001-05-17 21:27:12+02  jacob
// Initial revision
//
//

`include "timescale.v"
`include "uart_defines.v"

module uart_top	(
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

parameter 							 uart_data_width = 8;
parameter 							 uart_addr_width = `UART_ADDR_WIDTH;

input 								 clk;

// WISHBONE interface
input 								 wb_rst_i;
input [uart_addr_width-1:0] 	 wb_addr_i;
input [uart_data_width-1:0] 	 wb_dat_i;
output [uart_data_width-1:0] 	 wb_dat_o;
input 								 wb_we_i;
input 								 wb_stb_i;
input 								 wb_cyc_i;
output 								 wb_ack_o;
output 								 int_o;

// UART	signals
input 								 pad_srx_i;
output 								 pad_stx_o;
output 								 rts_o;
input 								 cts_i;
output 								 dtr_o;
input 								 dsr_i;
input 								 ri_i;
input 								 dcd_i;

wire 									 pad_stx_o;
wire 									 rts_o;
wire 									 dtr_o;

wire [uart_addr_width-1:0] 	 wb_addr_i;
wire [uart_data_width-1:0] 	 wb_dat_i;
wire [uart_data_width-1:0] 	 wb_dat_o;

wire 									 we_o;	// Write enable for registers

//
// MODULE INSTANCES
//

////  WISHBONE interface module
uart_wb		wb_interface(
		.clk(		clk		),
		.wb_rst_i(	wb_rst_i	),
		.wb_we_i(	wb_we_i		),
		.wb_stb_i(	wb_stb_i	),
		.wb_cyc_i(	wb_cyc_i	),
		.wb_ack_o(	wb_ack_o	),
		.we_o(		we_o		)
		);

// Registers
uart_regs	regs(
		.clk(		clk		),
		.wb_rst_i(	wb_rst_i	),
		.wb_addr_i(	wb_addr_i	),
		.wb_dat_i(	wb_dat_i	),
		.wb_dat_o(	wb_dat_o	),
		.wb_we_i(	we_o		),
		.modem_inputs(	{cts_i, dsr_i,
				 ri_i,  dcd_i}	),
		.pad_stx_o(		pad_stx_o		),
		.pad_srx_i(		pad_srx_i		),
		.enable(	enable		),
		.rts_o(		rts_o		),
		.dtr_o(		dtr_o		),
		.int_o(		int_o		)
		);

endmodule
