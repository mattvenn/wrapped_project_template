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

module quad_pwm_fet_drivers(
	input wire wb_clk_i,
	input wire wb_rst_i,
	input wire wbs_stb_i,
	input wire wbs_cyc_i,
	input wire wbs_we_i,
	input wire [3:0] wbs_sel_i,
	input wire [31:0] wbs_dat_i,
	input wire [31:0] wbs_adr_i,
	input  wire [37:0] io_in,
	input wire active,
	output reg buf_wbs_ack_o,
	output reg [31:0] buf_wbs_dat_o,
	output [31:0] buf_la_data_out,
	output [37:0] buf_io_out,
	output [37:0] buf_io_oeb,
	output [2:0] buf_irq
);
	wire valid;
	wire [3:0] wstrb;
	assign valid = wbs_cyc_i && wbs_stb_i; 
	assign wstrb = wbs_sel_i & {4{wbs_we_i}};
	reg RESET_n [3:0];
	reg [7:0] PWM [3:0];
	reg [3:0] BREAK_BEFORE_MAKE [3:0];
	reg [2:0] PRESCALER [3:0];
	wire [3:0] FAULT;
	wire [3:0] V_LIMIT;
	wire [3:0] I_LIMIT;
	wire [3:0] FAULT_DETECT;
	wire [3:0] HI_SIDE_FET;
	wire [3:0] LOW_SIDE_FET;
	wire [3:0] CYCLE;
	wire [3:0] PWM_CLOCK;
	wire [7:0] LIMIT_PWM [3:0];

	genvar i;

	generate
		for(i=0;i<4;i=i+1)
			PWM_FET_DRIVER_UNIT PWM_0 (
				.CLK(wb_clk_i),
				.RESET_n(RESET_n[i]),
				.PWM(PWM[i]),
				.BREAK_BEFORE_MAKE(BREAK_BEFORE_MAKE[i]),
				.PRESCALER(PRESCALER[i]),
				.FAULT(FAULT[i]),
				.V_LIMIT(V_LIMIT[i]),
				.I_LIMIT(I_LIMIT[i]),
				.FAULT_DETECT(FAULT_DETECT[i]),
				.HI_SIDE_FET(HI_SIDE_FET[i]),
				.LOW_SIDE_FET(LOW_SIDE_FET[i]),
				.CYCLE(CYCLE[i]),
				.PWM_CLOCK(PWM_CLOCK[i]),
				.LIMIT_PWM(LIMIT_PWM[i])
			);
	endgenerate

	assign buf_la_data_out = {38{1'b0}};

	assign buf_io_oeb[7:0] = {8{1'b1}};
	assign buf_io_out[7:0] = {8{1'b0}};

	assign buf_io_oeb[11:8]  = 4'b0000;
	assign buf_io_oeb[19:16] = 4'b0000;
	assign buf_io_oeb[27:24] = 4'b0000;
	assign buf_io_oeb[35:32] = 4'b0000;

	assign buf_io_out[11:8]  = {CYCLE[0],FAULT_DETECT[0],HI_SIDE_FET[0],LOW_SIDE_FET[0]};
	assign buf_io_out[19:16] = {CYCLE[1],FAULT_DETECT[1],HI_SIDE_FET[1],LOW_SIDE_FET[1]};
	assign buf_io_out[27:24] = {CYCLE[2],FAULT_DETECT[2],HI_SIDE_FET[2],LOW_SIDE_FET[2]};
	assign buf_io_out[35:32] = {CYCLE[3],FAULT_DETECT[3],HI_SIDE_FET[3],LOW_SIDE_FET[3]};

	assign {FAULT[0],V_LIMIT[0],I_LIMIT[0]} = {io_in[14],io_in[13],io_in[12]};
	assign {FAULT[1],V_LIMIT[1],I_LIMIT[1]} = {io_in[22],io_in[21],io_in[20]};
	assign {FAULT[2],V_LIMIT[2],I_LIMIT[2]} = {io_in[30],io_in[29],io_in[28]};
	assign {V_LIMIT[3],I_LIMIT[3]} = {io_in[37],io_in[36]};
	assign FAULT[3] = 0;

	assign {buf_io_oeb[14],buf_io_oeb[13],buf_io_oeb[12]} = 3'b111;
	assign {buf_io_oeb[22],buf_io_oeb[21],buf_io_oeb[20]} = 3'b111;
	assign {buf_io_oeb[30],buf_io_oeb[29],buf_io_oeb[28]} = 3'b111;
	assign {buf_io_oeb[37],buf_io_oeb[36]} = 2'b11;

	assign {buf_io_out[14],buf_io_out[13],buf_io_out[12]} = 3'b000;
	assign {buf_io_out[22],buf_io_out[21],buf_io_out[20]} = 3'b000;
	assign {buf_io_out[30],buf_io_out[29],buf_io_out[28]} = 3'b000;
	assign {buf_io_out[37],buf_io_out[36]} = 2'b00;

	assign {buf_io_out[15],buf_io_out[23],buf_io_out[31]} = {PWM_CLOCK[0],PWM_CLOCK[1],PWM_CLOCK[2]};
	assign {buf_io_oeb[15],buf_io_oeb[23],buf_io_oeb[31]} = {3{1'b0}};

	assign buf_irq[2:0] = {CYCLE[2],CYCLE[1],CYCLE[0]};

	integer j;

	always @(posedge wb_clk_i)
	begin
		if (wb_rst_i == 1)
			begin
				buf_wbs_ack_o <= 1'b 0;
				for(j=0;j<4;j=j+1)
					begin
						RESET_n[j] <= 0;
						BREAK_BEFORE_MAKE[j] <= 4'hF;
						PWM[j] <= 8'h7F;
						PRESCALER[j] <= 0;
					end
			end
		else
			begin
				buf_wbs_ack_o <= valid & ! buf_wbs_ack_o;
				case(wbs_adr_i)
					32'h30_00_00_00:
						begin
							buf_wbs_dat_o[7:0]   <= PWM[0];
							buf_wbs_dat_o[15:8]  <= PWM[1];
							buf_wbs_dat_o[23:16] <= PWM[2];
							buf_wbs_dat_o[31:24] <= PWM[3];
							if (valid)
								begin
									if (wstrb[0]) PWM[0] <= wbs_dat_i[7:0];
									if (wstrb[1]) PWM[1] <= wbs_dat_i[15:8];
									if (wstrb[2]) PWM[2] <= wbs_dat_i[23:16];
									if (wstrb[3]) PWM[3] <= wbs_dat_i[31:24];
								end
						end
					32'h30_00_00_04:
						begin
							buf_wbs_dat_o[7:0]   <= {BREAK_BEFORE_MAKE[0],1'b0,PRESCALER[0]};
							buf_wbs_dat_o[15:8]  <= {BREAK_BEFORE_MAKE[1],1'b0,PRESCALER[1]};
							buf_wbs_dat_o[23:16] <= {BREAK_BEFORE_MAKE[2],1'b0,PRESCALER[2]};
							buf_wbs_dat_o[31:24] <= {BREAK_BEFORE_MAKE[3],1'b0,PRESCALER[3]};
							if (valid)
								begin
									if (wstrb[0]) {BREAK_BEFORE_MAKE[0],PRESCALER[0]} <= {wbs_dat_i[7:4],wbs_dat_i[2:0]};
									if (wstrb[1]) {BREAK_BEFORE_MAKE[1],PRESCALER[1]} <= {wbs_dat_i[15:12],wbs_dat_i[10:8]};
									if (wstrb[2]) {BREAK_BEFORE_MAKE[2],PRESCALER[2]} <= {wbs_dat_i[23:20],wbs_dat_i[18:16]};
									if (wstrb[3]) {BREAK_BEFORE_MAKE[3],PRESCALER[3]} <= {wbs_dat_i[31:28],wbs_dat_i[26:24]};
								end
						end
					32'h30_00_00_08:
						begin
							buf_wbs_dat_o[7:0]   <= {FAULT_DETECT[0],6'h0,RESET_n[0]};
							buf_wbs_dat_o[15:8]  <= {FAULT_DETECT[1],6'h0,RESET_n[1]};
							buf_wbs_dat_o[23:16] <= {FAULT_DETECT[2],6'h0,RESET_n[2]};
							buf_wbs_dat_o[31:24] <= {FAULT_DETECT[3],6'h0,RESET_n[3]};
							if (valid)
								begin
									if (wstrb[0]) RESET_n[0] <= wbs_dat_i[0];
									if (wstrb[1]) RESET_n[1] <= wbs_dat_i[8];
									if (wstrb[2]) RESET_n[2] <= wbs_dat_i[16];
									if (wstrb[3]) RESET_n[3] <= wbs_dat_i[24];
								end
						end
					32'h30_00_00_0C:
						buf_wbs_dat_o <= {LIMIT_PWM[3],LIMIT_PWM[2],LIMIT_PWM[1],LIMIT_PWM[0]};
					32'h30_00_00_10:
						buf_wbs_dat_o <= 32'h12_34_56_78;
				endcase
			end
	end

endmodule

