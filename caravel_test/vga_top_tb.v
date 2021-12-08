// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"

module vga_top_tb;
	reg clock;
	reg RSTB;

	reg power1, power2;

	wire gpio;
	wire [37:0] mprj_io;

	wire check_vgahs;
	wire check_vgavs;
	wire [11:0] check_rgb;

	assign check_vgahs = mprj_io[25];
	assign check_vgavs = mprj_io[24];
	assign check_rgb = mprj_io[23:12];

	always #12.5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		$dumpfile("vga_top.vcd");
		$dumpvars(0, vga_top_tb);

		// Repeat cycles of 1000 clock edges as needed to complete testbench
		repeat (30) begin
			repeat (1000) @(posedge clock);
			$display("+1000 cycles");
		end
		$display("%c[1;31m",27);
		`ifdef GL
			$display ("Monitor: Timeout, Test Mega-Project IO (GL) Failed");
		`else
			$display ("Monitor: Timeout, Test Mega-Project IO (RTL) Failed");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	initial begin
		wait(check_vgahs && check_vgavs);
		$display("Monitor: Got HS & VS High");
		wait(check_vgahs == 1'b0);
		$display("Monitor: Got VS Low");
		wait(check_vgahs == 1'b1);
		$display("Monitor: Got VS High");
		wait(uut.mprj.fbless_graphics_core_10.vga_top_0.vga_core_0.vga_h_active && uut.mprj.fbless_graphics_core_10.vga_top_0.vga_core_0.vga_v_active);
		$display("Monitor: Got H & V Active");
		wait(check_rgb == 12'b111100000000);
		$display("Monitor: Got BG Color");
		wait(uut.mprj.fbless_graphics_core_10.vga_top_0.vga_core_0.vga_h_active == 1'b0);
		$display("Monitor: Got H Active Low");
		wait(uut.mprj.fbless_graphics_core_10.vga_top_0.vga_core_0.collision_bits == 12'b001100110010);
		$display("Monitor: Passed!");
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		#2000;
		RSTB <= 1'b1;	    	// Release reset
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		#200;
		power1 <= 1'b1;
		#200;
		power2 <= 1'b1;
	end

	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
	wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	assign VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (VDD3V3),
		.vdda2    (VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (VDD1V8),
		.vccd2	  (VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clock),
		.gpio     (gpio),
		.mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("vga_top.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),
		.io3()
	);

endmodule
`default_nettype wire
