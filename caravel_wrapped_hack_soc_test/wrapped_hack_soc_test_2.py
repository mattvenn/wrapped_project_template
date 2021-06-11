import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, First, with_timeout


async def test_start(dut):
    dut.RSTB <= 0
    dut.power1 <= 0;
    dut.power2 <= 0;
    dut.power3 <= 0;
    dut.power4 <= 0;

    await ClockCycles(dut.clock, 8)
    dut.power1 <= 1;
    await ClockCycles(dut.clock, 8)
    dut.power2 <= 1;
    await ClockCycles(dut.clock, 8)
    dut.power3 <= 1;
    await ClockCycles(dut.clock, 8)
    dut.power4 <= 1;

    await ClockCycles(dut.clock, 80)
    dut.RSTB <= 1


@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.clock, 25, units="ns")
    cocotb.fork(clock.start())

    await test_start(dut)

    print("Project reset done")

    # hack_external_reset
    dut.mprj_io[26].value = 0


    
    print("Waiting for the rom loader to start...")
    await with_timeout(RisingEdge(dut.uut.mprj.mprj.soc.rom_loader_load), 1000, 'us')


    count = 0
    print("Loading rom: 0/16 instructions loaded\r", end='\r')
    while(dut.uut.mprj.mprj.soc.rom_loader_load==1):
        trigger_sck = FallingEdge(dut.uut.mprj.mprj.soc.rom_loader_sck)
        trigger_load = FallingEdge(dut.uut.mprj.mprj.soc.rom_loader_load)
        t = await(First(trigger_sck, trigger_load))
        if(t==trigger_sck):
            count = count + 1
            print("Loading rom: ", count, "/16 instructions loaded", end='\r')
        # await(ClockCycles(dut.clk, 1))

    print("")
    print("Rom loader to finished")
    # await with_timeout(RisingEdge(dut.uut.mprj.mprj.soc.rom_loader_load), 2000, 'us')


    print("Waiting reset of the Hack cpu...")
    await with_timeout(FallingEdge(dut.uut.mprj.mprj.soc.hack_reset), 350, 'us')
    print("Hack soc reset done")


    await ClockCycles(dut.uut.mprj.mprj.soc.hack_clk, 200)
    
    
    # encoder0 = Encoder(dut.clk, dut.enc0_a, dut.enc0_b, clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4)

    

    


    # # wait for the reset signal - time out if necessary - should happen around 165us
    # await with_timeout(RisingEdge(dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.reset), 180, 'us')
    # await FallingEdge(dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.reset)

    # assert dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.enc0 == 0
    # assert dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.enc1 == 0
    # assert dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.enc2 == 0

    # # pwm should all be low at start
    # assert dut.pwm0_out == 0
    # assert dut.pwm1_out == 0
    # assert dut.pwm1_out == 0

    # # do 3 ramps for each encoder 
    # max_count = 255
    # await run_encoder_test(encoder0, dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.enc0, max_count)
    # await run_encoder_test(encoder1, dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.enc1, max_count)
    # await run_encoder_test(encoder2, dut.uut.mprj.wrapped_rgb_mixer.rgb_mixer0.enc2, max_count)

    # # sync to pwm
    # await RisingEdge(dut.pwm0_out)
    # # pwm should all be on for max_count 
    # for i in range(max_count): 
    #     assert dut.pwm0_out == 1
    #     assert dut.pwm1_out == 1
    #     assert dut.pwm2_out == 1
    #     await ClockCycles(dut.clk, 1)