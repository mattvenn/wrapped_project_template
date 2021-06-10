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

/*
	IO Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Observes counter value through the MPRJ lower 8 IO pins (in the testbench)
*/


struct logic_analyzer_t {
	// Outputs from Pico
	uint8_t reset;
	uint8_t keycode;
	uint8_t rom_loader_reset;
	uint8_t rom_loader_load;
	uint16_t rom_loader_data;
	// Inputs to Pico
	uint8_t rom_loader_ack;
	uint8_t rom_loader_load_received;
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

    // activate the project by setting the [project ID] bit of 2nd bank of LA
    reg_la1_iena = 0; // input enable off
    reg_la1_oenb = 0; // output enable on
    reg_la1_data = 1 << 6;



	// Default value for LA[31:0] = OUTPUT
	reg_la0_oenb = 0;
	reg_la0_iena = 0;

	reg_la0_data = 1;
	reg_la0_data = 0;

/*
	// rom_loader_reset is input 
	reg_la0_oenb = reg_la0_oenb | ~( 1<< 27 );
	reg_la0_iena = reg_la0_iena | ~( 1<< 27 );

	// rom_loader_load_received is input
	reg_la0_oenb = reg_la0_oenb | ~( 1<< 28 );
	reg_la0_iena = reg_la0_iena | ~( 1<< 28 );



	logic_analyzer.reset = 1;
	logic_analyzer.keycode = 0;
	logic_analyzer.rom_loader_reset = 1;
	logic_analyzer.rom_loader_load = 0;
	logic_analyzer.rom_loader_data = 0;


	// Set initial output values
	reg_la0_data = 	(logic_analyzer.reset << 0) |
					(logic_analyzer.keycode << 1) |
					(logic_analyzer.rom_loader_reset << 9) |
					(logic_analyzer.rom_loader_load << 10) |
					(logic_analyzer.rom_loader_data << 11);


	// RESET design 
	logic_analyzer.reset = 0;
	logic_analyzer.rom_loader_reset = 0;
	reg_la0_data = (reg_la0_data & ~(1<<0)) | (logic_analyzer.reset << 0);
	reg_la0_data = (reg_la0_data & ~(1<<9)) | (logic_analyzer.rom_loader_reset << 9);
	
	logic_analyzer.reset = 0;
	logic_analyzer.rom_loader_reset = 0;
	reg_la0_data = (reg_la0_data & ~(1<<0)) | (logic_analyzer.reset << 0);
	reg_la0_data = (reg_la0_data & ~(1<<9)) | (logic_analyzer.rom_loader_reset << 9);
*/	

    // // do something with the logic analyser
    // reg_la0_iena = 0;
    // reg_la0_oenb = 0;
    // reg_la0_data |= 100;
}

