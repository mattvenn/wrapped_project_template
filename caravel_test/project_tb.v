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

module check_width #(
	parameter WIDTH=10,
	parameter TOLERANCE = 0.5
) (
	input SIGNAL,
	output reg PASS
);

	time RE;

	initial
	begin
		PASS = 0;
		RE = $time;
	end
	
	always @(posedge SIGNAL or negedge SIGNAL)
		begin
			if (SIGNAL == 1)
				RE <= $time;
			if (SIGNAL == 0)
				if (RE != 0)
					if (((WIDTH-TOLERANCE) >= ($time-RE)) || (($time-RE) >= (WIDTH+TOLERANCE)))
						begin
							$write("%c[1;31m",27);
							$write("%m:Signal Width Fail (MEASURE=%0t",($time-RE)," vs SPEC=%0t",WIDTH,")");
							$display("%c[0m",27);
							$finish;
						end
		end

endmodule


module check_period #(
	parameter PERIOD=10,
	parameter TOLERANCE = 0.5
) (
	input SIGNAL,
	output reg PASS
);

	time RE;

	initial
	begin
		PASS = 0;
		RE = $time;
	end
	
	always @(posedge SIGNAL)
		if (SIGNAL == 1)
			begin
				if (RE != 0)
					if (((PERIOD-TOLERANCE) >= ($time-RE)) || (($time-RE) >= (PERIOD+TOLERANCE)))
						begin
							$write("%c[1;31m",27);
							$write("%m:Signal Period Fail (MEASURE=%0t",($time-RE)," vs SPEC=%0t",PERIOD,")");
							$display("%c[0m",27);
							$finish;
						end
				RE <= $time;
			end

endmodule

module la_test2_tb;
	reg clock;
	reg RSTB;
	reg CSB;

	reg power1, power2;

	wire gpio;
 	wire [37:0] mprj_io;
	wire [15:0] checkbits;

	assign checkbits = mprj_io[31:16];
	assign mprj_io[3] = (CSB == 1'b1) ? 1'b1 : 1'bz;

	always #12.5 clock <= (clock === 1'b0);

	wire [3:0] LOW_SIDE,HI_SIDE,FAULT_DETECT,CYCLE,I_LIMIT,V_LIMIT;
	assign LOW_SIDE        = {mprj_io[32],mprj_io[24],mprj_io[16],mprj_io[ 8]};
	assign HI_SIDE         = {mprj_io[33],mprj_io[25],mprj_io[17],mprj_io[ 9]};
	assign FAULT_DETECT    = {mprj_io[34],mprj_io[26],mprj_io[18],mprj_io[10]};
	assign CYCLE           = {mprj_io[35],mprj_io[27],mprj_io[19],mprj_io[11]};
	assign I_LIMIT         = {mprj_io[36],mprj_io[28],mprj_io[20],mprj_io[12]};
	pulldown (mprj_io[36]);
	pulldown (mprj_io[28]);
	pulldown (mprj_io[20]);
	pulldown (mprj_io[12]);
	assign V_LIMIT         = {mprj_io[37],mprj_io[29],mprj_io[21],mprj_io[13]};
	pulldown (mprj_io[37]);
	pulldown (mprj_io[29]);
	pulldown (mprj_io[21]);
	pulldown (mprj_io[13]);
	wire [3:0] FAULT,CHANNEL_CLOCK;
	assign FAULT           = {mprj_io[30],mprj_io[22],mprj_io[14]};
	pulldown (mprj_io[30]);
	pulldown (mprj_io[22]);
	pulldown (mprj_io[14]);
	assign CHANNEL_CLOCK   = {mprj_io[31],mprj_io[23],mprj_io[15]};

	initial begin
		clock = 0;
	end
	
	integer i;
	
	initial begin
		$dumpfile("project.vcd");
		$dumpvars(0, la_test2_tb);

		for(i=0;i<4;i=i+1)
			#100000 $display($time);

		$display("%c[1;32m",27);
		`ifdef GL
			$display ("Monitor: Test (GL) Complete");
		`else
			$display ("Monitor: Test (RTL) Complete");
		`endif
		$display("%c[0m",27);
		$finish;
	end

	wire [3:0] HI_SIDE_OK;
	check_width #(12.5*2*'h10) check_width_hi_0 (HI_SIDE[0],HI_SIDE_OK[0]);
	check_width #(12.5*2*'h20) check_width_hi_1 (HI_SIDE[1],HI_SIDE_OK[1]);
	check_width #(12.5*2*'h30) check_width_hi_2 (HI_SIDE[2],HI_SIDE_OK[2]);
	check_width #(12.5*2*'h40) check_width_hi_3 (HI_SIDE[3],HI_SIDE_OK[3]);

	wire [3:0] LOW_SIDE_OK;
	check_width #(12.5*2*(256-'h10-0*2)) check_width_low_0 (LOW_SIDE[0],LOW_SIDE_OK[0]);
	check_width #(12.5*2*(256-'h20-1*2)) check_width_low_1 (LOW_SIDE[1],LOW_SIDE_OK[1]);
	check_width #(12.5*2*(256-'h30-2*2)) check_width_low_2 (LOW_SIDE[2],LOW_SIDE_OK[2]);
	check_width #(12.5*2*(256-'h40-3*2)) check_width_low_3 (LOW_SIDE[3],LOW_SIDE_OK[3]);

	wire [3:0] CYCLE_OK;
	check_width #(12.5*2) check_width_cycle_0_hi (CYCLE[0],CYCLE_OK[0]);
	check_width #(12.5*2) check_width_cycle_1_hi (CYCLE[1],CYCLE_OK[1]);
	check_width #(12.5*2) check_width_cycle_2_hi (CYCLE[2],CYCLE_OK[2]);
	check_width #(12.5*2) check_width_cycle_3_hi (CYCLE[3],CYCLE_OK[3]);

	wire [3:0] CYCLE_OK_PERIOD;
	check_period #(12.5*2*256) check_period_cycle_0_low (CYCLE[0],CYCLE_OK_PERIOD[0]);
	check_period #(12.5*2*256) check_period_cycle_1_low (CYCLE[1],CYCLE_OK_PERIOD[1]);
	check_period #(12.5*2*256) check_period_cycle_2_low (CYCLE[2],CYCLE_OK_PERIOD[2]);
	check_period #(12.5*2*256) check_period_cycle_3_low (CYCLE[3],CYCLE_OK_PERIOD[3]);

	// Reset Sequence
	initial begin
		RSTB <= 1'b0;
		CSB  <= 1'b1; // Force CSB high
		#2000;
		RSTB <= 1'b1; // Release reset
		#170000;
		CSB = 1'b0;   // CSB can be released
	end

	// Power-up sequence
	initial begin
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
		.FILENAME("project.hex")
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
