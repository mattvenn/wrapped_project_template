# cocotb setup
export COCOTB_REDUCED_LOG_FMT=1
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)

prove_wrapper:
	sby -f properties.sby

test_wrapper_gl:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -DMPRJ_IO_PADS=38 -DGATE_LEVEL -s testbench ./gds/wrapped_quad_pwm_fet_drivers.lvs.powered.v ./test/testbench.v -I $(PDK_ROOT)/sky130A
	MODULE=test.test_wrapper vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml
	
test_wrapper:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -DMPRJ_IO_PADS=38 -s testbench -g2012 ./wrapper.v ./src/pwm_fet_driver_unit.v ./src/pwm_fet_quad.v ./test/testbench.v
	MODULE=test.test_wrapper vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml
	
show_wrapper:
	gtkwave wrapper.vcd wrapper.gtkw

