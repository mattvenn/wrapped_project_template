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

// This include is relative to $CARAVEL_PATH (see Makefile)
#include "verilog/dv/caravel/defs.h"
#include "verilog/dv/caravel/stub.c"


#define vga_collision_reg (*(volatile uint32_t*)0x30000000)
#define vga_buttons_reg (*(volatile uint32_t*)0x30000004)
#define vga_h_reg (*(volatile uint32_t*)0x30000000)
#define vga_v_reg (*(volatile uint32_t*)0x30000004)
#define vga_m_reg (*(volatile uint32_t*)0x30000008)
#define vga_bg0_reg (*(volatile uint32_t*)0x3000000c)
#define vga_bg1_reg (*(volatile uint32_t*)0x30000010)
#define vga_bgs_reg (*(volatile uint32_t*)0x30000014)
#define vga_wait_reg (*(volatile uint32_t*)0x30000018)
#define vga_bg_color_10_reg (*(volatile uint32_t*)0x3000001c)
#define vga_bg_color_32_reg (*(volatile uint32_t*)0x30000020)
#define vga_sprite_0_start_reg (*(volatile uint32_t*)0x30000024)
#define vga_sprite_0_pixels_reg (*(volatile uint32_t*)0x30000028)
#define vga_sprite_0_size_color_1_reg (*(volatile uint32_t*)0x3000002c)
#define vga_sprite_0_color_32_reg (*(volatile uint32_t*)0x30000030)
#define vga_sprite_1_start_reg (*(volatile uint32_t*)0x30000034)
#define vga_sprite_1_pixels_reg (*(volatile uint32_t*)0x30000038)
#define vga_sprite_1_size_color_1_reg (*(volatile uint32_t*)0x3000003c)
#define vga_sprite_1_color_32_reg (*(volatile uint32_t*)0x30000040)
#define vga_sprite_2_start_reg (*(volatile uint32_t*)0x30000044)
#define vga_sprite_2_pixels_reg (*(volatile uint32_t*)0x30000048)
#define vga_sprite_2_size_color_1_reg (*(volatile uint32_t*)0x3000004c)
#define vga_sprite_2_color_32_reg (*(volatile uint32_t*)0x30000050)



void main()
{
        /* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

	reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.


	// All GPIO pins are configured to be output
	// Used to flad the start/end of a test 

        reg_mprj_io_37 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_36 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_35 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_34 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_33 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_32 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_31 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_30 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_29 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_28 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_27 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_26 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;

        reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
        reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;

        reg_mprj_io_11 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_10 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_9  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_8  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_7  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_6  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_5  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_4  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_3  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_2  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_1  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
        reg_mprj_io_0  = GPIO_MODE_MGMT_STD_INPUT_PULLUP;

        /* Apply configuration */
        reg_mprj_xfer = 1;
        while (reg_mprj_xfer == 1);

        // activate the project with 2nd bank of the LA
        reg_la1_iena = 0; // input enable off
        reg_la1_oenb = 0; // output enable bar low (enabled)
        reg_la1_data = 1 << 10;


        vga_bg0_reg = 0x55555555;
        vga_bg1_reg = 0xaaaaaaaa;

        vga_bg_color_10_reg = 0x00f00fff;
        vga_bg_color_32_reg = 0x000f000f;

        vga_sprite_0_size_color_1_reg = 0x00000000;
        vga_sprite_0_color_32_reg = 0x00f0fff0;

        vga_sprite_1_size_color_1_reg = 0x00000fff;
        vga_sprite_1_color_32_reg = 0x000007f7;

        vga_sprite_2_size_color_1_reg = 0x00000777;
        vga_sprite_2_color_32_reg = 0x00077707;


        vga_sprite_0_pixels_reg = 0xffffffff;
        vga_sprite_0_start_reg = 70;
        vga_sprite_1_pixels_reg = 0xffffffff;
        vga_sprite_1_start_reg = 170;
        vga_sprite_2_pixels_reg = 0xffffffff;
        vga_sprite_2_start_reg = 180;


        vga_bgs_reg = 0x186;
        vga_h_reg = 0x120903f;
        vga_v_reg = 0x100c1d;
        vga_m_reg = 0x4451fc;

        uint32_t collision = vga_collision_reg;
}

