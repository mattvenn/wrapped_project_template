`default_nettype none
`timescale 1 ns / 1 ps

`include "uprj_netlists.v"
`include "caravel_netlists.v"
`include "spiflash.v"
`include "rom_23LC1024.v"

module wrapped_hack_soc_test_2_tb;
	reg clock;
	reg RSTB;
	reg CSB;

	reg power1, power2;
	reg power3, power4;

    wire gpio;
    wire [37:0] mprj_io;
	
	
	// HACK GPIO_I
	// Same somple input data on GPIO_I
	assign mprj_io[33:30] = 4'b1101; 

	
	wire ram_cs_n;
	wire ram_sck;
	wire rom_cs_n;
	wire rom_sck;
	wire vram_cs_n;
	wire vram_sck;

	assign ram_cs_n = mprj_io[8];
	assign ram_sck = mprj_io[9];
	assign rom_cs_n = mprj_io[14];
	assign rom_sck = mprj_io[15];
	assign vram_cs_n = mprj_io[20];
	assign vram_sck = mprj_io[21];
	
	
    wire flash_csb;
	wire flash_clk;
	wire flash_io0;
	wire flash_io1;

	wire VDD1V8;
	wire VDD3V3;
	wire VSS;
    
	assign VDD3V3 = power1;
	assign VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	assign VSS = 1'b0;

	
    initial begin
        $dumpfile ("wrapped_hack_soc_test_2_tb.vcd");
        $dumpvars (0, wrapped_hack_soc_test_2_tb);
        #1;
    end




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
		.FILENAME("wrapped_hack_soc_test_2.hex")
	) spiflash (
		.csb(flash_csb),
		.clk(flash_clk),
		.io0(flash_io0),
		.io1(flash_io1),
		.io2(),
		.io3()
	);



	wire reset_rams = ~RSTB;

	rom_M23LC1024 ram (
		.SI_SIO0(mprj_io[10]), 
		.SO_SIO1(mprj_io[11]), 
		.SCK(ram_sck), 
		.CS_N(ram_cs_n), 
		.SIO2(mprj_io[12]), 
		.HOLD_N_SIO3(mprj_io[13]), 
		.RESET(reset_rams));

	

	// rom_M23LC1024 #(.ROM_FILE("hack_programs/test_assignment_and_jump.hack")) rom (
	rom_M23LC1024 rom (
		.SI_SIO0(mprj_io[16]), 
		.SO_SIO1(mprj_io[17]), 
		.SCK(rom_sck), 
		.CS_N(rom_cs_n), 
		.SIO2(mprj_io[18]), 
		.HOLD_N_SIO3(mprj_io[19]), 
		.RESET(reset_rams));

	rom_M23LC1024 vram (
		.SI_SIO0(mprj_io[22]), 
		.SO_SIO1(mprj_io[23]), 
		.SCK(vram_sck), 
		.CS_N(vram_cs_n), 
		.SIO2(mprj_io[24]), 
		.HOLD_N_SIO3(mprj_io[25]), 
		.RESET(reset_rams));





	// wire debug_a = uut.mprj.mprj.io_in[16] == uut.mprj_io[16]; 

endmodule
`default_nettype wire
