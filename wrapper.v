`default_nettype none
`ifdef FORMAL
	`define MPRJ_IO_PADS 38    
`endif
module wrapped_quad_pwm_fet_drivers (
`ifdef USE_POWER_PINS
	inout vdda1,	// User area 1 3.3V supply
	inout vdda2,	// User area 2 3.3V supply
	inout vssa1,	// User area 1 analog ground
	inout vssa2,	// User area 2 analog ground
	inout vccd1,	// User area 1 1.8V supply
	inout vccd2,	// User area 2 1.8v supply
	inout vssd1,	// User area 1 digital ground
	inout vssd2,	// User area 2 digital ground
`endif

	// Wishbone Slave ports (WB MI A)
	input wb_clk_i,
	input wb_rst_i,
	input wbs_stb_i,
	input wbs_cyc_i,
	input wbs_we_i,
	input [3:0] wbs_sel_i,
	input [31:0] wbs_dat_i,
	input [31:0] wbs_adr_i,
	output wbs_ack_o,
	output [31:0] wbs_dat_o,

	// Logic Analyzer Signals
	// only provide first 32 bits to reduce wiring congestion
	input  wire [31:0] la_data_in,
	output wire [31:0] la_data_out,
	input  wire [31:0] la_oen,

	// IRQ
	output wire [2:0] irq,          // interrupt from project to PicoRV32

	// IOs
	input  wire [`MPRJ_IO_PADS-1:0] io_in,
	output wire [`MPRJ_IO_PADS-1:0] io_out,
	output wire [`MPRJ_IO_PADS-1:0] io_oeb,
	
	// active input, only connect tristated outputs if this is high
	input wire active
);

	// all outputs must be tristated before being passed onto the project
	wire buf_wbs_ack_o;
	wire [31:0] buf_wbs_dat_o;
	wire [31:0] buf_la_data_out;
	wire [`MPRJ_IO_PADS-1:0] buf_io_out;
	wire [`MPRJ_IO_PADS-1:0] buf_io_oeb;
	wire [2:0] buf_irq;

	`ifdef FORMAL
	// formal can't deal with z, so set all outputs to 0 if not active
	assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'b0;
	assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'b0;
	assign la_data_out  = active ? buf_la_data_out  : 32'b0;
	assign io_out       = active ? buf_io_out       : `MPRJ_IO_PADS'b0;
	assign io_oeb       = active ? buf_io_oeb       : `MPRJ_IO_PADS'b0;
	assign irq          = active ? buf_irq          : 3'b0;
	`include "properties.v"
	`else
	// tristate buffers
	assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
	assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
	assign la_data_out  = active ? buf_la_data_out  : 32'bz;
	assign io_out       = active ? buf_io_out       : `MPRJ_IO_PADS'bz;
	assign io_oeb       = active ? buf_io_oeb       : `MPRJ_IO_PADS'bz;
	assign irq          = active ? buf_irq          : 3'bz;
	`endif

	quad_pwm_fet_drivers quad_pwm_fet_drivers (
		.wb_clk_i(wb_clk_i),
		.wb_rst_i(wb_rst_i),
		.wbs_stb_i(wbs_stb_i),
		.wbs_cyc_i(wbs_cyc_i),
		.wbs_we_i(wbs_we_i),
		.wbs_sel_i(wbs_sel_i),
		.wbs_dat_i(wbs_dat_i),
		.wbs_adr_i(wbs_adr_i),
		.io_in(io_in),
		.active(active),
		.buf_wbs_ack_o(buf_wbs_ack_o),
		.buf_wbs_dat_o(buf_wbs_dat_o),
		.buf_la_data_out(buf_la_data_out),
		.buf_io_out(buf_io_out),
		.buf_io_oeb(buf_io_oeb),
		.buf_irq(buf_irq)
	);
endmodule 
`default_nettype wire
