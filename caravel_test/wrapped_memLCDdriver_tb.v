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

`include "uprj_netlists.v" // this file gets created automatically by multi_project_tools from the source section of info.yaml
`include "caravel_netlists.v"
`include "spiflash.v"

module wrapped_memLCDdriver_tb;
    initial begin
        $dumpfile ("wrapped_memLCDdriver_tb.vcd");
        $dumpvars (0, wrapped_memLCDdriver_tb);
        #1;
    end

	reg clk;
    reg RSTB;
	reg power1, power2;
	reg power3, power4;

    wire gpio;
    wire [37:0] mprj_io;

    ///// convenience signals that match what the cocotb test modules are looking for
	wire   i_reset;
	wire   i_vcom_start;
    // For Logic analizer
    wire  o_wfull;
    wire  o_wfull_almost;
    wire  o_rempty;
    wire  o_rempty_almost;
    // SPI RX Port
    wire   i_spi_mosi;
    wire   i_spi_cs_n;
    wire   i_spi_clk;
    wire  	o_spi_cts;
    // Memory LCD signals
    wire  o_va;
    wire  o_vb;
    wire  o_vcom;
    wire  o_gsp;
    wire  o_gck;
    wire  o_gen;
    wire  o_intb;
    wire  o_bsp;
    wire  o_bck;
    wire  [5:0] o_rgb;
    /////


	wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	caravel uut (
		.vddio	  (VDD3V3),
		.vssio	  (VSS),
		.vdda	  (VDD3V3),
		.vssa	  (VSS),
		.vccd	  (VDD1V8),
		.vssd	  (VSS),
		.vdda1    (USER_VDD3V3),
		.vdda2    (USER_VDD3V3),
		.vssa1	  (VSS),
		.vssa2	  (VSS),
		.vccd1	  (USER_VDD1V8),
		.vccd2	  (USER_VDD1V8),
		.vssd1	  (VSS),
		.vssd2	  (VSS),
		.clock	  (clk),
		.gpio     (gpio),
        .mprj_io  (mprj_io),
		.flash_csb(flash_csb),
		.flash_clk(flash_clk),
		.flash_io0(flash_io0),
		.flash_io1(flash_io1),
		.resetb	  (RSTB)
	);

	spiflash #(
		.FILENAME("wrapped_memLCDdriver.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),			// not used
		.io3()			// not used
	);

	assign  mprj_io[8] 		= i_reset;
	assign  mprj_io[32] 	= i_vcom_start;
    // For Logic analizer
    assign  o_wfull 		= mprj_io[12];
    assign  o_wfull_almost 	= mprj_io[13];
    assign  o_rempty 		= mprj_io[14];
    assign  o_rempty_almost = mprj_io[15];
    // SPI RX Port
    assign  mprj_io[9] 		= i_spi_mosi;
    assign  mprj_io[10] 	= i_spi_cs_n;
    assign 	mprj_io[11] 	= i_spi_clk;
    assign 	o_spi_cts 		= mprj_io[31];
    // Memory LCD signals
    assign  o_va 			= mprj_io[16];
    assign  o_vb 			= mprj_io[17];
    assign  o_vcom 			= mprj_io[18];
    assign  o_gsp 			= mprj_io[19];
    assign  o_gck 			= mprj_io[20];
    assign  o_gen 			= mprj_io[21];
    assign  o_intb 			= mprj_io[22];
    assign  o_bsp 			= mprj_io[23];
    assign  o_bck 			= mprj_io[24];
    assign  o_rgb 			= mprj_io[30:25];

endmodule
`default_nettype wire
