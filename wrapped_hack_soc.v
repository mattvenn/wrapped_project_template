`default_nettype none
`ifdef FORMAL
    `define MPRJ_IO_PADS 38    
`endif

//`define USE_WB  0
`define USE_LA  1
`define USE_IO  1
//`define USE_MEM 0
//`define USE_IRQ 0
//`define USE_CLK2 0


module wrapped_hack_soc(
`ifdef USE_POWER_PINS
    // inout vdda1,	// User area 1 3.3V supply
    // inout vdda2,	// User area 2 3.3V supply
    // inout vssa1,	// User area 1 analog ground
    // inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    // inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    // inout vssd2,	// User area 2 digital ground
`endif
    // wishbone interface
    input wire wb_clk_i,            // clock, runs at system clock

`ifdef USE_WB
    input wire wb_rst_i,            // main system reset
    input wire wbs_stb_i,           // wishbone write strobe
    input wire wbs_cyc_i,           // wishbone cycle
    input wire wbs_we_i,            // wishbone write enable
    input wire [3:0] wbs_sel_i,     // wishbone write word select
    input wire [31:0] wbs_dat_i,    // wishbone data in
    input wire [31:0] wbs_adr_i,    // wishbone address
    output wire wbs_ack_o,          // wishbone ack
    output wire [31:0] wbs_dat_o,   // wishbone data out
`endif

    // Logic Analyzer Signals
    // only provide first 32 bits to reduce wiring congestion
    input  wire [31:0] la1_data_in,  // from PicoRV32 to your project
    output wire [31:0] la1_data_out, // from your project to PicoRV32
    input  wire [31:0] la1_oenb,     // output enable bar (low for active)


    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,  // in to your project
    output wire [`MPRJ_IO_PADS-1:0] io_out, // out fro your project
    output wire [`MPRJ_IO_PADS-1:0] io_oeb, // out enable bar (low active)

    // IRQ
`ifdef USE_IRQ
    output wire [2:0] irq,          // interrupt from project to PicoRV32
`endif 


    // extra user clock
`ifdef USE_CLK2
    input wire user_clock2,
`endif
    
    // active input, only connect tristated outputs if this is high
    input wire active
);

    // all outputs must be tristated before being passed onto the project
    wire buf_wbs_ack_o;
    wire [31:0] buf_wbs_dat_o;
    wire [31:0] buf_la1_data_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_out;
    wire [`MPRJ_IO_PADS-1:0] buf_io_oeb;
    wire [2:0] buf_irq;

    `ifdef FORMAL
        // formal can't deal with z, so set all outputs to 0 if not active
        `ifdef USE_WB
        assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'b0;
        assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'b0;
        `endif

        assign la1_data_out  = active ? buf_la1_data_out  : 32'b0;
        
        assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'b0}};
        assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'b0}};
        
        `ifdef USE_IRQ
        assign irq          = active ? buf_irq          : 3'b0;
        `endif

        `include "properties.v"
    `else
        // tristate buffers
        `ifdef USE_WB
        assign wbs_ack_o    = active ? buf_wbs_ack_o    : 1'bz;
        assign wbs_dat_o    = active ? buf_wbs_dat_o    : 32'bz;
        `endif

        assign la1_data_out  = active ? buf_la1_data_out  : 32'bz;
        assign io_out       = active ? buf_io_out       : {`MPRJ_IO_PADS{1'bz}};
        assign io_oeb       = active ? buf_io_oeb       : {`MPRJ_IO_PADS{1'bz}};

        `ifdef USE_IRQ
        assign irq          = active ? buf_irq          : 3'bz;
        `endif

    `endif

    

    // Instantiate your module here, 
    // connecting what you need of the above signals. 
    // Use the buffered outputs for your module's outputs.

    // IO
    // permanently set oeb so that outputs are always enabled: 0 is output, 1 is high-impedance
    assign buf_io_oeb[`MPRJ_IO_PADS-1:30] = {(`MPRJ_IO_PADS-20){1'b0}}; //{(`MPRJ_IO_PADS-20){rst}};
    assign buf_io_oeb[7:0] = {(8){1'b0}};
    


    wire clk = wb_clk_i;

    // Logic Analyzer    
    wire hack_soc_reset = la1_data_in[0];
    wire [7:0] keycode = la1_data_in[8:1];
    wire rom_loader_sck = la1_data_in[9];
    wire rom_loader_load = la1_data_in[10];
    wire [15:0] rom_loader_data = la1_data_in[26:11];
    wire rom_loader_ack;
    assign buf_la1_data_out[27] = rom_loader_ack;
    wire hack_external_reset_from_la = la1_data_in[28];
    


    // ram
    wire ram_cs_n;
    wire ram_sck;
    wire ram_sio_oe;
    wire ram_sio0_o;
    wire ram_sio1_o;
    wire ram_sio2_o;
    wire ram_sio3_o;
    wire ram_sio0_i;
    wire ram_sio1_i;
    wire ram_sio2_i;
    wire ram_sio3_i;
    
    assign buf_io_oeb[8] = 1'b0;
    assign buf_io_out[8] = ram_cs_n;    
    assign buf_io_oeb[9] = 1'b0;
    assign buf_io_out[9] = ram_sck;     
    assign buf_io_oeb[13:10] = {~ram_sio_oe, ~ram_sio_oe, ~ram_sio_oe, ~ram_sio_oe};
    assign buf_io_out[13:10] = {ram_sio3_o, ram_sio2_o, ram_sio1_o, ram_sio0_o};
    assign {ram_sio3_i, ram_sio2_i, ram_sio1_i, ram_sio0_i} = io_in[13:10];

    // rom
    wire rom_cs_n;
    wire rom_sck;
    wire rom_sio_oe;
    wire rom_sio0_o;
    wire rom_sio1_o;
    wire rom_sio2_o;
    wire rom_sio3_o;
    wire rom_sio0_i;
    wire rom_sio1_i;
    wire rom_sio2_i;
    wire rom_sio3_i;

    assign buf_io_oeb[14] = 1'b0;
    assign buf_io_out[14] = rom_cs_n;    
    assign buf_io_oeb[15] = 1'b0;
    assign buf_io_out[15] = rom_sck;     
    assign buf_io_oeb[19:16] = {~rom_sio_oe, ~rom_sio_oe, ~rom_sio_oe, ~rom_sio_oe};
    assign buf_io_out[19:16] = {rom_sio3_o, rom_sio2_o, rom_sio1_o, rom_sio0_o};
    assign {rom_sio3_i, rom_sio2_i, rom_sio1_i, rom_sio0_i} = io_in[19:16];


    // vram
    wire vram_cs_n;
    wire vram_sck;
    wire vram_sio_oe;
    wire vram_sio0_o;
    wire vram_sio1_o;
    wire vram_sio2_o;
    wire vram_sio3_o;
    wire vram_sio0_i;
    wire vram_sio1_i;
    wire vram_sio2_i;
    wire vram_sio3_i;
    
    assign buf_io_oeb[20] = 1'b0;
    assign buf_io_out[20] = vram_cs_n;    
    assign buf_io_oeb[21] = 1'b0;
    assign buf_io_out[21] = vram_sck;     
    assign buf_io_oeb[25:22] = {~vram_sio_oe, ~vram_sio_oe, ~vram_sio_oe, ~vram_sio_oe};
    assign buf_io_out[25:22] = {vram_sio3_o, vram_sio2_o, vram_sio1_o, vram_sio0_o};
    assign {vram_sio3_i, vram_sio2_i, vram_sio1_i, vram_sio0_i} = io_in[25:22];


    wire hack_external_reset_from_io;
    assign buf_io_oeb[26] = 1'b1;
    assign hack_external_reset_from_io = io_in[26];

    // hack_external_reset
    wire hack_external_reset;
    assign hack_external_reset = hack_external_reset_from_la | hack_external_reset_from_io;


    // display
    wire display_vsync;
    wire display_hsync;
    wire display_rgb;

    assign buf_io_oeb[27] = 1'b0;
    assign buf_io_out[27] = display_vsync;
    assign buf_io_oeb[28] = 1'b0;
    assign buf_io_out[28] = display_hsync;
    assign buf_io_oeb[29] = 1'b0;
    assign buf_io_out[29] = display_rgb;
    

    // GPIO
    wire [3:0] gpio_i;
    wire [3:0] gpio_o;
	assign buf_io_oeb[33:30] = 4'b1111;
    assign gpio_i = io_in[33:30];
	assign buf_io_oeb[37:34] = 4'b0000;
	assign buf_io_out[37:34] = gpio_o;

    hack_soc soc(
        .clk(clk),
        .display_clk(clk),
        .reset(hack_soc_reset),

        .hack_external_reset(hack_external_reset),


        /** RAM: qspi serial sram **/
        .ram_cs_n(ram_cs_n),
        .ram_sck(ram_sck),
        .ram_sio_oe(ram_sio_oe), // output enable the SIO lines
        // SIO as inputs from SRAM	
        .ram_sio0_i(ram_sio0_i), // sram_si_sio0 
        .ram_sio1_i(ram_sio1_i), // sram_so_sio1
        .ram_sio2_i(ram_sio2_i), // sram_sio2
        .ram_sio3_i(ram_sio3_i), // sram_hold_n_sio3
        // SIO as outputs to SRAM
        .ram_sio0_o(ram_sio0_o), // sram_si_sio0
        .ram_sio1_o(ram_sio1_o), // sram_so_sio1
        .ram_sio2_o(ram_sio2_o), // sram_sio2
        .ram_sio3_o(ram_sio3_o), // sram_hold_n_sio3

        /** ROM: qspi serial sram **/
        .rom_cs_n(rom_cs_n),
        .rom_sck(rom_sck),
        .rom_sio_oe(rom_sio_oe), // output enable the SIO lines
        // SIO as inputs from SRAM	
        .rom_sio0_i(rom_sio0_i), // sram_si_sio0 
        .rom_sio1_i(rom_sio1_i), // sram_so_sio1
        .rom_sio2_i(rom_sio2_i), // sram_sio2
        .rom_sio3_i(rom_sio3_i), // sram_hold_n_sio3
        // SIO as outputs to SRAM
        .rom_sio0_o(rom_sio0_o), // sram_si_sio0
        .rom_sio1_o(rom_sio1_o), // sram_so_sio1
        .rom_sio2_o(rom_sio2_o), // sram_sio2
        .rom_sio3_o(rom_sio3_o), // sram_hold_n_sio3


        /** VRAM: qspi serial sram **/
        .vram_cs_n(vram_cs_n),
        .vram_sck(vram_sck),
        .vram_sio_oe(vram_sio_oe), // output enable the SIO lines
        // SIO as inputs from SRAM	
        .vram_sio0_i(vram_sio0_i), // sram_si_sio0 
        .vram_sio1_i(vram_sio1_i), // sram_so_sio1
        .vram_sio2_i(vram_sio2_i), // sram_sio2
        .vram_sio3_i(vram_sio3_i), // sram_hold_n_sio3
        // SIO as outputs to SRAM
        .vram_sio0_o(vram_sio0_o), // sram_si_sio0
        .vram_sio1_o(vram_sio1_o), // sram_so_sio1
        .vram_sio2_o(vram_sio2_o), // sram_sio2
        .vram_sio3_o(vram_sio3_o), // sram_hold_n_sio3

        // ** DISPLAY ** //
        .display_hsync(display_hsync),
        .display_vsync(display_vsync),
        .display_rgb(display_rgb),



        // ROM LOADING LINES
        // inputs
        .rom_loader_load(rom_loader_load),
        .rom_loader_sck(rom_loader_sck),
        .rom_loader_data(rom_loader_data),
        // outputs
        .rom_loader_ack(rom_loader_ack),
        

        // Keyboard
        .keycode(keycode),

        // GPIO
        .gpio_i(gpio_i),
		.gpio_o(gpio_o)


    );




endmodule 
`default_nettype wire
