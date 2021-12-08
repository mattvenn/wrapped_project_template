`default_nettype none
`ifdef FORMAL
    `define MPRJ_IO_PADS 38    
`endif
// update this to the name of your module
module wrapped_memLCDdriver(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    // wishbone interface
    input wire wb_clk_i,            // clock, runs at system clock
    input wire wb_rst_i,            // main system reset
    input wire wbs_stb_i,           // wishbone write strobe
    input wire wbs_cyc_i,           // wishbone cycle
    input wire wbs_we_i,            // wishbone write enable
    input wire [3:0] wbs_sel_i,     // wishbone write word select
    input wire [31:0] wbs_dat_i,    // wishbone data in
    input wire [31:0] wbs_adr_i,    // wishbone address
    output wire wbs_ack_o,          // wishbone ack
    output wire [31:0] wbs_dat_o,   // wishbone data out

    // Logic Analyzer Signals
    // only provide first 32 bits to reduce wiring congestion
    input  wire [31:0] la_data_in,  // from PicoRV32 to your project
    output wire [31:0] la_data_out, // from your project to PicoRV32
    input  wire [31:0] la_oenb,     // output enable bar (low for active)

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,  // in to your project
    output wire [`MPRJ_IO_PADS-1:0] io_out, // out fro your project
    output wire [`MPRJ_IO_PADS-1:0] io_oeb, // out enable bar (low active)

    // IRQ
    output wire [2:0] irq,          // interrupt from project to PicoRV32

    // extra user clock
    input wire user_clock2,
    
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
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}};
    assign irq          = active ? buf_irq          : 3'b0;
    `include "properties.v"
    `else
    // tristate buffers
    assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
    assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
    assign la_data_out  = active ? buf_la_data_out  : 32'bz;
    assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'bz}};
    assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'bz}};
    assign irq          = active ? buf_irq          : 3'bz;
    `endif

    memLCDdriver memLCDdriver (
        // System Control Signals
        .i_clk(wb_clk_i), // 100MHz
        .i_reset(io_in[8]),
        .i_vcom_start(io_in[32]),
        .o_wfull(buf_io_out[12]),
        .o_wfull_almost(buf_io_out[13]),
        .o_rempty(buf_io_out[14]),
        .o_rempty_almost(buf_io_out[15]),
        // SPI RX Port
        .i_spi_mosi(io_in[9]),
        .i_spi_cs_n(io_in[10]),
        .i_spi_clk(io_in[11]),
        .o_spi_cts(buf_io_out[31]),
        // Memory LCD signals
        .o_va(buf_io_out[16]),
        .o_vb(buf_io_out[17]),
        .o_vcom(buf_io_out[18]),
        .o_gsp(buf_io_out[19]),
        .o_gck(buf_io_out[20]),
        .o_gen(buf_io_out[21]),
        .o_intb(buf_io_out[22]),
        .o_bsp(buf_io_out[23]),
        .o_bck(buf_io_out[24]),
        .o_rgb(buf_io_out[30:25]),
        .o_oeb(buf_io_oeb[31:12])
    );

endmodule 
`default_nettype wire
