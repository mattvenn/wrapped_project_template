`timescale 1ns/1ns
`ifdef GATE_LEVEL
	`define UNIT_DELAY #1
	`define FUNCTIONAL
	`define USE_POWER_PINS
	`include "libs.ref/sky130_fd_sc_hd/verilog/primitives.v"
	`include "libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v"
`endif
module testbench (
	input wire wb_clk_i,
	input wire wb_rst_i,
	input wire wbs_stb_i,
	input wire wbs_cyc_i,
	input wire wbs_we_i,
	input wire [3:0] wbs_sel_i,
	input wire [31:0] wbs_dat_i,
	input wire [31:0] wbs_adr_i,
	output wire wbs_ack_o,
	output wire [31:0] wbs_dat_o,
	input  wire [31:0] la_data_in,
	output wire [31:0] la_data_out,
	input  wire [31:0] la_oenb,
	output wire [2:0] irq,
	input  wire [`MPRJ_IO_PADS-1:0] io_in,
	output wire [`MPRJ_IO_PADS-1:0] io_out,
	output wire [`MPRJ_IO_PADS-1:0] io_oeb,
	input wire active
);

	wrapped_quad_pwm_fet_drivers wrapped_quad_pwm_fet_drivers(
	`ifdef GATE_LEVEL
		.vdda1(1'b1),
		.vdda2(1'b1),
		.vccd1(1'b1),
		.vccd2(1'b1),
		.vssa1(1'b0),
		.vssa2(1'b0),
		.vssd1(1'b0),
		.vssd2(1'b0),
	`endif /* GATE_LEVEL */
		.wb_clk_i(wb_clk_i),
		.wb_rst_i(wb_rst_i),
		.wbs_stb_i(wbs_stb_i),
		.wbs_cyc_i(wbs_cyc_i),
		.wbs_we_i(wbs_we_i),
		.wbs_sel_i(wbs_sel_i),
		.wbs_dat_i(wbs_dat_i),
		.wbs_adr_i(wbs_adr_i),
		.wbs_ack_o(wbs_ack_o),
		.wbs_dat_o(wbs_dat_o),
		.la_data_in(la_data_in),
		.la_data_out(la_data_out),
		.la_oenb(la_oenb),
		.irq(irq),
		.io_in(io_in),
		.io_out(io_out),
		.io_oeb(io_oeb),
		.active(active)
	);
	
	initial begin
		$dumpfile ("wrapper.vcd");
		$dumpvars (0, testbench);
		#1;
	end

endmodule
