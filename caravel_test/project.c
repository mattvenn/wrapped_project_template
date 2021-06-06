/* Licensed under the Apache License, Version 2.0 (the "License");
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
 */

#include "verilog/dv/caravel/defs.h"
#include <stdint.h>

#define PWM_DRIVE_PWM             (*(volatile uint32_t*)0x30000000)
#define PWM_DRIVE_SETUP           (*(volatile uint32_t*)0x30000004)
#define PWM_DRIVE_RESET           (*(volatile uint32_t*)0x30000008)
#define PWM_DRIVE_IV_LIMIT        (*(volatile uint32_t*)0x3000000C)
#define PWM_DRIVE_MODULE_CHECK    (*(volatile uint32_t*)0x30000010)

#define PWM(CHAN,VALUE)                      ((VALUE&0xFF)<<(8*CHAN))
#define PWM_BREAK_BEFORE_MAKE(CHAN,VALUE)    ((VALUE&0xF)<<(8*CHAN+4))
#define PWM_PRESCALER(CHAN,VALUE)            ((VALUE&0xF)<<(8*CHAN))

#define PWM_DRIVE_MODULE_CHECK_PATTERN	0x12345678

#define ID 5

void main()
{
	// Channel 0
	reg_mprj_io_8  = GPIO_MODE_USER_STD_OUTPUT;         // LOW_SIDE
	reg_mprj_io_9  = GPIO_MODE_USER_STD_OUTPUT;         // HI_SIDE
	reg_mprj_io_10 = GPIO_MODE_USER_STD_OUTPUT;         // FAULT_DETECT
	reg_mprj_io_11 = GPIO_MODE_USER_STD_OUTPUT;         // CYCLE
	reg_mprj_io_12 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // I_LIMIT
	reg_mprj_io_13 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // V_LIMIT
	reg_mprj_io_14 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // FAULT
	reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;         // CHANNEL CLOCK

	// Channel 1
	reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;         // LOW_SIDE
	reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;         // HI_SIDE
	reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;         // FAULT_DETECT
	reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;         // CYCLE
	reg_mprj_io_20 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // I_LIMIT
	reg_mprj_io_21 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // V_LIMIT
	reg_mprj_io_22 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // FAULT
	reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;         // CHANNEL CLOCK

	// Channel 2
	reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;         // LOW_SIDE
	reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;         // HI_SIDE
	reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;         // FAULT_DETECT
	reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;         // CYCLE
	reg_mprj_io_28 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // I_LIMIT
	reg_mprj_io_29 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // V_LIMIT
	reg_mprj_io_30 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // FAULT
	reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;         // CHANNEL CLOCK

	// Channel 3
	reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;         // LOW_SIDE
	reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;         // HI_SIDE
	reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;         // FAULT_DETECT
	reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;         // CYCLE
	reg_mprj_io_36 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // I_LIMIT
	reg_mprj_io_37 = GPIO_MODE_USER_STD_INPUT_PULLDOWN; // V_LIMIT
	
	reg_mprj_xfer = 1;
	while (reg_mprj_xfer == 1);

	// activate the project by setting the 1st bit of 2nd bank of LA - depends on the project ID
	reg_la1_iena = 0; // input enable off
	reg_la1_oenb = 0; // output enable on
	reg_la1_data = 1 << ID;

	PWM_DRIVE_SETUP = 
		PWM_BREAK_BEFORE_MAKE(3,3) | PWM_PRESCALER(3,0) |
		PWM_BREAK_BEFORE_MAKE(2,2) | PWM_PRESCALER(2,0) |
		PWM_BREAK_BEFORE_MAKE(1,1) | PWM_PRESCALER(1,0) |
		PWM_BREAK_BEFORE_MAKE(0,0) | PWM_PRESCALER(0,0);
	
	PWM_DRIVE_PWM = PWM(3,0x40) | PWM(2,0x30) | PWM(1,0x20) | PWM(0,0x10);
	
	if (PWM_DRIVE_MODULE_CHECK == PWM_DRIVE_MODULE_CHECK_PATTERN) {
		PWM_DRIVE_RESET = 0x01010101;
	}
	
	while(1);
}

