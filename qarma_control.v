`default_nettype none

module QarmaControl #(
    parameter BITS = 32
)(
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o
);
    reg wbs_ack_o;
    reg [31:0] wbs_dat_o;

    reg [63:0] qarma_in;
    reg [63:0] qarma_tweak;
    reg [127:0] qarma_key;
    wire[63:0] qarma_out;
    wire qarma_rdy;
    reg  qarma_nrst;

    Qarma64 qarma (
        wb_clk_i, // clk
        qarma_nrst,
        qarma_in,
        qarma_tweak,
        qarma_key,
        qarma_out,
        qarma_rdy
    );

    wire[31:0] qarma_status;
    assign qarma_status[0] = qarma_rdy;
    assign qarma_status[1] = qarma_nrst;
    assign qarma_status[31:2] = 0;

    always @(posedge wb_clk_i) begin

        if (wb_rst_i) begin
            qarma_in <= 0;
            qarma_tweak <= 0;
            qarma_key <= 0;
            qarma_nrst <= 0;
        end

        if (wbs_stb_i && wbs_cyc_i && !wbs_we_i) begin
            //$display("Monitor: READ");

            case (wbs_adr_i[31:0])
                32'h30000000: wbs_dat_o <= qarma_status;

                32'h30000020: wbs_dat_o <= qarma_in[ 31: 0];
                32'h30000024: wbs_dat_o <= qarma_in[ 63:32];

                32'h30000030: wbs_dat_o <= qarma_out[ 31: 0];
                32'h30000034: wbs_dat_o <= qarma_out[ 63:32];
            endcase

            wbs_ack_o <= 1;
        end
        else if (wbs_stb_i && wbs_cyc_i && wbs_we_i) begin
            //$display("Monitor: WRITE");

            case (wbs_adr_i[31:0])
                32'h30000004: qarma_nrst <= 0;
                32'h30000008: qarma_nrst <= 1;

                32'h30000010: qarma_key[ 31: 0] <= wbs_dat_i;
                32'h30000014: qarma_key[ 63:32] <= wbs_dat_i;
                32'h30000018: qarma_key[ 95:64] <= wbs_dat_i;
                32'h3000001C: qarma_key[127:96] <= wbs_dat_i;

                32'h30000020: qarma_in[ 31: 0] <= wbs_dat_i;
                32'h30000024: qarma_in[ 63:32] <= wbs_dat_i;

                32'h30000040: qarma_tweak[ 31: 0] <= wbs_dat_i;
                32'h30000044: qarma_tweak[ 63:32] <= wbs_dat_i;
            endcase
            wbs_ack_o <= 1;
        end
        else
            wbs_ack_o <= 0;
    end

endmodule

`default_nettype wire
