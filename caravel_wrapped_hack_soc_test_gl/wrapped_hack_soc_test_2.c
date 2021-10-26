/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "verilog/dv/caravel/defs.h"

#include <stdint.h> 

#define ARRAY_LENGTH(x) (sizeof(x) / sizeof((x)[0]))

#include "caravel_test_hack_program.c"

#define MULTIPROJECT_ID					6

#define RESET__LA1_BIT					0
#define KEYCODE__LA1_BIT				1
#define KEYCODE__LA1_LENGTH				8
#define ROM_LOADER_SCK__LA1_BIT			9
#define ROM_LOADER_LOAD__LA1_BIT		10
#define ROM_LOADER_DATA__LA1_BIT		11
#define ROM_LOADER_DATA__LA1_LENGTH		16
#define ROM_LOADER_ACK__LA1_BIT			27
#define HACK_EXTERNAL_RESET__LA1_BIT	28



struct logic_analyzer_t {
	// Outputs from Pico
	uint8_t reset;
	uint8_t keycode;
	uint8_t rom_loader_sck;
	uint8_t rom_loader_load;
	uint16_t rom_loader_data;
	// Inputs to Pico
	uint8_t rom_loader_ack;	
	uint8_t hack_external_reset;
} logic_analyzer;





void main()
{
	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |

	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |

	*/



// ** HACK GPIO ** //
	// gpio_o
	reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;

	// gpio_i
	reg_mprj_io_33 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_32 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_31 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_30 = GPIO_MODE_USER_STD_INPUT_NOPULL;




// ** DISPLAY VSYNC< HSYNC, RGB ** //
	// rgb
	reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
	// hsync
	reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
	// vsync
	reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;


//	** HACK_EXTERNAL_RESET ** //
	reg_mprj_io_26 = GPIO_MODE_USER_STD_INPUT_NOPULL;


//	** VRAM ** //    

	// SPI VRAM SIO
	reg_mprj_io_25 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_24 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_23 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_22 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	// SPI VRAM_SCK
	reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
	// SPI VRAM_CS_N
	reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
	


// 	** ROM ** //    

	// SPI ROM SIO
	reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_18 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_17 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_16 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	// SPI ROM_SCK
	reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
	// SPI ROM_CS_N
	reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
	

//	** RAM ** //

	// SPI RAM SIO
	reg_mprj_io_13 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL;	
	// SPI RAM_SCK
	reg_mprj_io_9  = GPIO_MODE_USER_STD_OUTPUT;	
	// SPI RAM_CS_N
	reg_mprj_io_8  = GPIO_MODE_USER_STD_OUTPUT;



	
    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);




	// Default value for LA[31:0] = OUTPUT
	reg_la1_oenb = 0;
	reg_la1_iena = 0;

	// rom_loader_ack is input 
	reg_la1_oenb = reg_la1_oenb | ( 1<< ROM_LOADER_ACK__LA1_BIT );
	reg_la1_iena = reg_la1_iena | ( 1<< ROM_LOADER_ACK__LA1_BIT );

	

	uint32_t tmp_la1_data;

	// system reset
	logic_analyzer.reset = 1;
	logic_analyzer.keycode = 97;
	logic_analyzer.rom_loader_load = 0;
	// hack_cpu reset
	logic_analyzer.hack_external_reset = 1;
	// logic_analyzer.rom_loader_sck = 0;
	// logic_analyzer.rom_loader_data = 0;

	// Set initial output values
	tmp_la1_data = 	(logic_analyzer.reset << RESET__LA1_BIT) |
					(logic_analyzer.keycode << KEYCODE__LA1_BIT) |
					(logic_analyzer.rom_loader_load << ROM_LOADER_LOAD__LA1_BIT) |
					(logic_analyzer.hack_external_reset << HACK_EXTERNAL_RESET__LA1_BIT) ;
					;
					// (logic_analyzer.rom_loader_sck << 9) |
					// (logic_analyzer.rom_loader_data << 11);
	reg_la1_data = tmp_la1_data;




    // activate the project by setting the [project ID] bit of 2nd bank of LA
    reg_la0_iena = 0; // input enable off
    reg_la0_oenb = 0; // output enable on
    reg_la0_data = 1 << MULTIPROJECT_ID;


	// Release system reset
	logic_analyzer.reset = 0;
	tmp_la1_data = (tmp_la1_data & ~(1<<RESET__LA1_BIT)) | (logic_analyzer.reset << RESET__LA1_BIT);
	reg_la1_data = tmp_la1_data;


	uint8_t program_size = ARRAY_LENGTH(hack_program);



	// Start ROM LOADING
	logic_analyzer.rom_loader_load = 1;
	tmp_la1_data = (tmp_la1_data & ~(1<<ROM_LOADER_LOAD__LA1_BIT)) | (logic_analyzer.rom_loader_load << ROM_LOADER_LOAD__LA1_BIT);

	
	for (int i = 0; i < program_size; ++i) {
		
		logic_analyzer.rom_loader_data = hack_program[i];				
		tmp_la1_data = (tmp_la1_data & ~(0xffff<<ROM_LOADER_DATA__LA1_BIT)) | (logic_analyzer.rom_loader_data << ROM_LOADER_DATA__LA1_BIT);
		logic_analyzer.rom_loader_sck = 1;
		tmp_la1_data = (tmp_la1_data & ~(1<<ROM_LOADER_SCK__LA1_BIT)) | (logic_analyzer.rom_loader_sck << ROM_LOADER_SCK__LA1_BIT);
		reg_la1_data = tmp_la1_data;

		logic_analyzer.rom_loader_sck = 0;
		tmp_la1_data = (tmp_la1_data & ~(1<<ROM_LOADER_SCK__LA1_BIT)) | (logic_analyzer.rom_loader_sck << ROM_LOADER_SCK__LA1_BIT);
		reg_la1_data = tmp_la1_data;		
		
	}


	// Finished ROM LOADING
	logic_analyzer.rom_loader_load = 0;
	tmp_la1_data = (tmp_la1_data & ~(1<<ROM_LOADER_LOAD__LA1_BIT)) | (logic_analyzer.rom_loader_load << ROM_LOADER_LOAD__LA1_BIT);
	reg_la1_data = tmp_la1_data;		



	logic_analyzer.hack_external_reset = 0;
	tmp_la1_data = (tmp_la1_data & ~(1<<HACK_EXTERNAL_RESET__LA1_BIT)) | (logic_analyzer.hack_external_reset << HACK_EXTERNAL_RESET__LA1_BIT);
	reg_la1_data = tmp_la1_data;		
	

    // // do something with the logic analyser
    // reg_la1_iena = 0;
    // reg_la1_oenb = 0;
    // reg_la1_data |= 100;
}

