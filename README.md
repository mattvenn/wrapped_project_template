# PWM FET Drivers

![Block Diagram](https://github.com/ChrisDePalm/wrapped_quad_pwm_fet_drivers/blob/main/docs/wrapped_quad_pwm_fet_drivers.block_diagram.png)

This is a Zerotoasic MPW2 project submission to Google/Efabless/Skywater shuttle program.

This project includes four PWM FET drivers.  The intended application is for multi-channel power supplies, motor-driver, H-bridge, and digital to analog applications.

Features Include:
> - Four independently controllable PWM generators.
> - 32-Bit Wishbone Interface
> - Four independent voltage and current limit inputs
> - Three emergency shut-down fault inputs
> - Adjustable prescaler (1:1 to 1:128)

# Requirements

The [cocotbext-wishbone](https://github.com/jamieiles/cocotbext-wishbone.git) package is required to run the test_wrapper and test_wrapper_gl recipes. 

# License

This project is [licensed under Apache 2](LICENSE)
