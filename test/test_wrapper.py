import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

async def reset(dut):
    dut.io_in[8]    <= 1    # i_reset
    dut.io_in[9]    <= 0    # i_spi_mosi
    dut.io_in[10]   <= 1    # i_spi_cs_n
    dut.io_in[11]   <= 0    # i_spi_clk
    await ClockCycles(dut.wb_clk_i, 5)
    dut.io_in[8]    <= 0    # i_reset
    await ClockCycles(dut.wb_clk_i, 5)

async def send_byte(dut, data):
    dut.io_in[10]   <= 0    # i_spi_cs_n
    for i in range(8):
        dut.io_in[11]   <= 0 # i_spi_clk
        dut.io_in[9]    <= (data >> (7-i)) & 0x1   # i_spi_mosi
        await ClockCycles(dut.wb_clk_i, 4)
        dut.io_in[11]   <= 1 # i_spi_clk
        await ClockCycles(dut.wb_clk_i, 4)

    dut.io_in[11]   <= 0    # i_spi_clk
    await ClockCycles(dut.wb_clk_i, 4)
    dut.io_in[9]    <= 0    # i_spi_mosi
    dut.io_in[10]   <= 1    # i_spi_cs_n
    await ClockCycles(dut.wb_clk_i, 8)

async def send_spi_data(dut, line_count):
    # Test sending byte packets when FIFO is not full
    data = 0x01
    packet_count = 0
    send_packet = 0
    while (packet_count < 120*line_count): # send image frames (120*640 for a frame)
        if (dut.buf_io_out[12] == 1):   # o_wfull
            send_packet = 0
        if (dut.buf_io_out[14] == 1):   # o_rempty
            send_packet = 1

        if (send_packet == 1):
            packet_count = packet_count + 1
            await send_byte(dut, data)
            data = data + 0x01
            if (data > 0x3F):
                data = 0x01 

        await ClockCycles(dut.wb_clk_i, 1)

@cocotb.test()
async def test_wrapper(dut):
    clock = Clock(dut.wb_clk_i, 10, units="ns")
    cocotb.fork(clock.start())

    # deactivate project
    dut.active <= 0

    await reset(dut)

    await send_spi_data(dut, 4)

    # pause
    await ClockCycles(dut.wb_clk_i, 100)

    # activate project
    dut.active <= 1

    # reset it
    await reset(dut)

    # Send Data over SPI
    await send_spi_data(dut, 4)

    await ClockCycles(dut.wb_clk_i, 10000)

    assert dut.memLCDdriver.memlcd_fsm.r_count_v == 4
    assert dut.memLCDdriver.memlcd_fsm.r_count_h == 121
