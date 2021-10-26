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
    await with_timeout(RisingEdge(dut.uut.mprj.wrapped_hack_soc_6.soc.rom_loader_load), 1000, 'us')


    count = 0
    print("Loading rom: 0/16 instructions loaded\r", end='\r')
    while(dut.uut.mprj.wrapped_hack_soc_6.soc.rom_loader_load==1):
        trigger_sck = FallingEdge(dut.uut.mprj.wrapped_hack_soc_6.soc.rom_loader_sck)
        trigger_load = FallingEdge(dut.uut.mprj.wrapped_hack_soc_6.soc.rom_loader_load)
        t = await(First(trigger_sck, trigger_load))
        if(t==trigger_sck):
            count = count + 1
            print("Loading rom: ", count, "/16 instructions loaded", end='\r')
        # await(ClockCycles(dut.clk, 1))

    print("")
    print("Rom loader to finished")
    # await with_timeout(RisingEdge(dut.uut.mprj.wrapped_hack_soc_6.soc.rom_loader_load), 2000, 'us')


    print("Waiting reset of the Hack cpu...")
    await with_timeout(FallingEdge(dut.uut.mprj.wrapped_hack_soc_6.soc.hack_reset), 350, 'us')
    print("Hack soc reset done")


    for i in range(0,24):
        await ClockCycles(dut.uut.mprj.wrapped_hack_soc_6.soc.hack_clk, 1)
        print("PC: ", int(dut.uut.mprj.wrapped_hack_soc_6.soc.hack_pc.value), " INSTRUCTION:", hex(dut.uut.mprj.wrapped_hack_soc_6.soc.hack_instruction.value))
        if(i==4):
            # Set first word of the screen to 0x53ED
            # In vram the bits are saved inverted, so 0x53ED becomes 0xB7CA
            assert(dut.vram.MemoryBlock[0] == 0xB7)
            assert(dut.vram.MemoryBlock[1] == 0xCA)
            print("  vram instruction write check passed")
        if(i==7):
            # Set Memory[4] = 0x53ED
            assert(dut.ram.MemoryBlock[4*2] == 0x53)
            assert(dut.ram.MemoryBlock[4*2+1] == 0xED)
            print("  ram instruction write check passed")
        if(i==11):
            # Read Keyboard and store value on Memory[5]
            # Firmware inputs keycode 0x61 thourgh LA[8:1]
            assert(dut.ram.MemoryBlock[5*2] == 0x00)
            assert(dut.ram.MemoryBlock[5*2+1] == 0x61)
            print("  keyboard read and memory write check passed")
        if(i==13):
            # Loop forever incrementing Memory[6]=Memory[6]+1
            # Memory[6] = 0
            assert(dut.ram.MemoryBlock[6*2] == 0x00)
            assert(dut.ram.MemoryBlock[6*2+1] == 0x00)
        if(i==15):            
            # Loop forever incrementing Memory[6]=Memory[6]+1
            # Memory[6] = 1            
            assert(dut.ram.MemoryBlock[6*2] == 0x00)
            assert(dut.ram.MemoryBlock[6*2+1] == 0x01)
        if(i==19):            
            # Loop forever incrementing Memory[6]=Memory[6]+1
            # Memory[6] = 2
            assert(dut.ram.MemoryBlock[6*2] == 0x00)
            assert(dut.ram.MemoryBlock[6*2+1] == 0x02)            
        if(i==23):            
            # Loop forever incrementing Memory[6]=Memory[6]+1
            # Memory[6] = 3
            assert(dut.ram.MemoryBlock[6*2] == 0x00)
            assert(dut.ram.MemoryBlock[6*2+1] == 0x03)
            print("  incremental loop check passed")
    


    await ClockCycles(dut.uut.mprj.wrapped_hack_soc_6.soc.hack_clk, 5)

    print("All checks passed")

    
    # encoder0 = Encoder(dut.clk, dut.enc0_a, dut.enc0_b, clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4)

