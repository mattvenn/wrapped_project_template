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

/*
	MPRJ LA Test:
		- Sets counter clk through LA[64]
		- Sets counter rst through LA[65] 
		- Observes count value for five clk cycle through LA[31:0]
*/

int clk = 0;
int i;

int bufeq(const uint8_t* p, const uint8_t* q)
{
    uint32_t* pp = (uint32_t*)p;
    uint32_t* qq = (uint32_t*)q;
    int i;
    for(i=0; i<2; i++)
    {
        if (*pp++ != *qq++)
            return 0;
    }
    return 1;
}

void bufcpy(uint8_t* p, const uint8_t* q)
{
    uint32_t* pp = (uint32_t*)p;
    uint32_t* qq = (uint32_t*)q;
    int i;
    for(i=0; i<2; i++)
    {
        *pp++ = *qq++;
    }
}

void main()
{
    /* Set up the housekeeping SPI to be connected internally so	*/
    /* that external pin changes don't affect it.			*/

    reg_spimaster_config = 0xa002; // Enable, prescaler = 2,

    // All GPIO pins are configured to be output
    // Used to flad the start/end of a test

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

    reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_12 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_9 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_8 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_7 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_5 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_4 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_3 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_1 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_0 = GPIO_MODE_USER_STD_OUTPUT;

    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1)
        ;

    reg_la1_oenb = 0;
    reg_la1_iena = 0;
    reg_la1_data = 1 << 8; // QARMA is project #8.

    // Flag start of the test
    reg_mprj_datal = 0x41410000;

    int tests_good = 0;

    static const uint8_t qarma_vector0_key[] = {
        0xe9, 0x88, 0xa4, 0xe0, 0xd4, 0x02, 0x28, 0xec,
        0x4b, 0xe9, 0x04, 0x98, 0xce, 0x85, 0xbe, 0x84,
    };
    static const uint8_t qarma_vector0_in[] = {
        0x27, 0x81, 0x6e, 0xda, 0x99, 0x35, 0x62, 0xfb,
    };
    static const uint8_t qarma_vector0_tweak[] = {
        0x62, 0x87, 0x0b, 0xec, 0x9d, 0x46, 0x7d, 0x47,
    };
    static const uint8_t qarma_vector0_ref[] = {
        0x65, 0x07, 0x93, 0xde, 0x89, 0x6c, 0xaf, 0xbc,
    };

    bufcpy((uint8_t*) 0x30000010, qarma_vector0_key);
    bufcpy((uint8_t*) 0x30000018, qarma_vector0_key + 8);
    bufcpy((uint8_t*) 0x30000020, qarma_vector0_in);
    bufcpy((uint8_t*) 0x30000040, qarma_vector0_tweak);

    *(int*) 0x30000004 = 1;
    *(int*) 0x30000008 = 1;
    while (!((*(int*) 0x30000000) & 1));

    if (bufeq((uint8_t*) 0x30000030, qarma_vector0_ref))
        tests_good++;

    static const uint8_t qarma_vector1_key[16] = {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    };
    static const uint8_t qarma_vector1_in[] = {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    };
    static const uint8_t qarma_vector1_tweak[] = {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    };
    static const uint8_t qarma_vector1_ref[] = {
        0x1e, 0x02, 0x76, 0xc3, 0xfb, 0x74, 0xdc, 0xe8,
    };

    bufcpy((uint8_t*) 0x30000010, qarma_vector1_key);
    bufcpy((uint8_t*) 0x30000018, qarma_vector1_key + 8);
    bufcpy((uint8_t*) 0x30000020, qarma_vector1_in);
    bufcpy((uint8_t*) 0x30000040, qarma_vector1_tweak);

    *(int*) 0x30000004 = 1;
    *(int*) 0x30000008 = 1;
    while (!((*(int*) 0x30000000) & 1));

    if (bufeq((uint8_t*) 0x30000030, qarma_vector1_ref))
        tests_good++;

    reg_mprj_datal = 0x80000000 | (tests_good << 16);

    while (1)
        ;
}
