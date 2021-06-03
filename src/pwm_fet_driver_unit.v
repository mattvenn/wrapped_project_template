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

`timescale 1ns / 100ps
module PWM_FET_DRIVER_UNIT(
	input CLK,
	input RESET_n,
	input [7:0] PWM,
	input [3:0] BREAK_BEFORE_MAKE,
	input [2:0] PRESCALER,
	input FAULT,
	input V_LIMIT,
	input I_LIMIT,

	output reg FAULT_DETECT,
	output HI_SIDE_FET,
	output LOW_SIDE_FET,
	output reg CYCLE,
	output reg PWM_CLOCK,
	output reg [7:0] LIMIT_PWM
);
	reg [8:0] LATCH_PWM;
	reg [3:0] LATCH_BREAK_BEFORE_MAKE;
	
	reg Q_HI_SIDE_FET;
	reg Q_LOW_SIDE_FET;
	
	reg Q1,Q2,Q3,Q4;
	reg LIMIT_DETECT;
	reg [3:0] Q3_START;
	reg [8:0] COUNT;

	reg [2:0] SYNC_FAULT;
	reg [2:0] SYNC_IV_LIMIT;
	
	reg [7:0] DIV;
	reg [6:0] DIV_COUNT;
	reg PRESCALER_SELECT;
	
	assign HI_SIDE_FET = (Q_LOW_SIDE_FET == 1) ? 0 : Q_HI_SIDE_FET;
	assign LOW_SIDE_FET = (Q_HI_SIDE_FET == 1) ? 0 : Q_LOW_SIDE_FET;
	
	always @(posedge CLK)
	begin

		if (RESET_n == 0)
			begin
				COUNT <= 9'hFF;
				Q_HI_SIDE_FET <= 0;
				Q_LOW_SIDE_FET <= 0;
				FAULT_DETECT <= 0;
				CYCLE <= 0;
				DIV <= 0;
				DIV_COUNT <= 0;
				LATCH_BREAK_BEFORE_MAKE <= 4'hF;
				LATCH_PWM <= 0;
				LIMIT_PWM <= 8'hFF;
				SYNC_FAULT <= 0;
				SYNC_IV_LIMIT <= 0;
				PWM_CLOCK <= 0;
				PRESCALER_SELECT <= 0;
				LIMIT_DETECT <= 0;
				Q1 <= 0;
				Q2 <= 0;
				Q3 <= 0;
				Q4 <= 0;
				Q3_START <= 0;
			end
		else
			begin
				SYNC_FAULT <= {SYNC_FAULT[1]|SYNC_FAULT[2],SYNC_FAULT[0],FAULT};
				SYNC_IV_LIMIT <= {SYNC_IV_LIMIT[1]|SYNC_IV_LIMIT[2],SYNC_IV_LIMIT[0],V_LIMIT | I_LIMIT};
				
				if (DIV_COUNT == 7'b111_1111)
					DIV_COUNT <= 0;
				else
					DIV_COUNT <= DIV_COUNT + 7'd1;
				DIV[0] <= 1;
				if (DIV_COUNT[0] == 0)   DIV[1] <= 1; else DIV[1] <= 0;
				if (DIV_COUNT[1:0] == 0) DIV[2] <= 1; else DIV[2] <= 0;
				if (DIV_COUNT[2:0] == 0) DIV[3] <= 1; else DIV[3] <= 0;
				if (DIV_COUNT[3:0] == 0) DIV[4] <= 1; else DIV[4] <= 0;
				if (DIV_COUNT[4:0] == 0) DIV[5] <= 1; else DIV[5] <= 0;
				if (DIV_COUNT[5:0] == 0) DIV[6] <= 1; else DIV[6] <= 0;
				if (DIV_COUNT[6:0] == 0) DIV[7] <= 1; else DIV[7] <= 0;
				
				case(PRESCALER)
					3'b000: PRESCALER_SELECT <= DIV[0];
					3'b001: PRESCALER_SELECT <= DIV[1];
					3'b010: PRESCALER_SELECT <= DIV[2];
					3'b011: PRESCALER_SELECT <= DIV[3];
					3'b100: PRESCALER_SELECT <= DIV[4];
					3'b101: PRESCALER_SELECT <= DIV[5];
					3'b110: PRESCALER_SELECT <= DIV[6];
					3'b111: PRESCALER_SELECT <= DIV[7];
				endcase
				
				if (SYNC_FAULT[2] == 0)
					begin
						if ((Q1 == 1) && (Q2 == 0) && (Q3 == 0) && (Q4 ==1))
							Q_HI_SIDE_FET <= 1;
						else
							Q_HI_SIDE_FET <= 0;
						if ((Q1 == 0) && (Q2 == 1) && (Q3 == 1) && (Q4 ==1))
							Q_LOW_SIDE_FET <= 1;
						else
							Q_LOW_SIDE_FET <= 0;
					end
				else
					begin
						Q_LOW_SIDE_FET <= 0;
						Q_HI_SIDE_FET <= 0;
						FAULT_DETECT <= 1;
					end
				
				if (((PRESCALER_SELECT == 1) && (COUNT == (LATCH_PWM-1))) || (SYNC_IV_LIMIT[2] == 1))
					begin
						Q1 <= 0;
						Q2 <= 1;
						if (LATCH_BREAK_BEFORE_MAKE == 0) Q3 <= 1;
						if ((SYNC_IV_LIMIT[2] == 1) && (LIMIT_DETECT == 0))
						begin
							LIMIT_PWM <= COUNT[7:0];
							LIMIT_DETECT <= 1;
						end
					end
				
				if (PRESCALER_SELECT == 1)
					begin
						PWM_CLOCK <= ~PWM_CLOCK;
						
						if (COUNT == 9'hFE)
							CYCLE <= 1;
						else
							CYCLE <= 0;
						
						if (Q2 == 1)
							if (Q3_START == (LATCH_BREAK_BEFORE_MAKE-1))
								Q3 <= 1;
							else
								Q3_START <= Q3_START + 4'd1;
						
						if (COUNT == (9'hFF-LATCH_BREAK_BEFORE_MAKE))
							Q4 <= 0;
							
						if (COUNT == 9'hFF)
							begin
								Q4 <= 1;
								if (PWM != 0)
									begin
										Q1 <= 1;
										Q2 <= 0;
										Q3 <= 0;
									end
								else
									begin
										Q1 <= 0;
										Q2 <= 1;
										Q3 <= 1;
									end
								COUNT <= 0;
								LATCH_PWM <= PWM;
								LATCH_BREAK_BEFORE_MAKE <= BREAK_BEFORE_MAKE;
								SYNC_IV_LIMIT <= 0;
								LIMIT_DETECT <= 0;
								Q3_START <= 0;
							end
							
						else
							COUNT <= COUNT + 4'd1;
					end
			end
	end

	// Make sure that both FETs cannot be on at the same time.
	`ifdef FORMAL
		always @(*)
			_fet_test_ : assert(~(HI_SIDE_FET & LOW_SIDE_FET));
	`endif

endmodule
