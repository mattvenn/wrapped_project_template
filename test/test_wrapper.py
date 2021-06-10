import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Edge
from cocotbext.wishbone.driver import WishboneMaster
from cocotbext.wishbone.driver import WBOp

SHORT_RUN = True

# Register Definitions
PWM_DRIVE_PWM             = 0x30000000
PWM_DRIVE_SETUP           = 0x30000004
PWM_DRIVE_RESET           = 0x30000008
PWM_DRIVE_IV_LIMIT        = 0x3000000C
PWM_DRIVE_MODULE_CHECK    = 0x30000010

PWM_DRIVE_MODULE_CHECK_PATTERN = 0x12345678

def get_io_signal_number(channel,field):
	offset = {
		'LOW_SIDE':0,
		'HI_SIDE':1,
		'FAULT_DETECT':2,
		'CYCLE':3,
		'I_LIMIT':4,
		'V_LIMIT':5,
		'FAULT':6,
		'CHANNEL_CLOCK':7
	}
	return offset[field.upper()]+channel*8+8

class MeasurePWM(object):
	def __init__(self, dut):
		self.dut = dut
		self.ticks = 0
		self.LOW_TICK = [None,None,None,None]
		self.HIGH_TICK = [None,None,None,None]
		self.RESET_DONE = [False,False,False,False]
		self.LOW_TICK_REP = [None,None,None,None]
		self.HIGH_TICK_REP = [None,None,None,None]
	
	async def start(self):
		while True:
			await RisingEdge(self.dut.wb_clk_i)
			
			for i in range(4):
				if (self.dut.io_out[get_io_signal_number(i,'CYCLE')] == 1):
					if self.RESET_DONE[i] == False:
						self.LOW_TICK_REP[i] = self.LOW_TICK[i]
						self.HIGH_TICK_REP[i] = self.HIGH_TICK[i]
						self.LOW_TICK[i] = 0
						self.HIGH_TICK[i] = 0
						self.RESET_DONE[i] = True
				else:
					self.RESET_DONE[i] = False
				if (self.dut.io_out[get_io_signal_number(i,'LOW_SIDE')] == 1):
					if self.LOW_TICK[i] != None:
						self.LOW_TICK[i] += 1
				if (self.dut.io_out[get_io_signal_number(i,'HI_SIDE')] == 1):
					if self.HIGH_TICK[i] != None:
						self.HIGH_TICK[i] += 1
	
	def get_ticks_hi(self,channel):
		return self.HIGH_TICK_REP[channel]
			
	def get_ticks_low(self,channel):
		return self.LOW_TICK_REP[channel] 

class BusEmulator(object):
	def __init__(self, dut):
		self.dut = dut
		clock = Clock(self.dut.wb_clk_i, 10, units="ns")
		cocotb.fork(clock.start())
		self.wbs = WishboneMaster(
			dut,
			"wbs",
			dut.wb_clk_i,
			timeout=None,
			signals_dict={
				"cyc":  "cyc_i",
				"stb":  "stb_i",
				"we":   "we_i",
				"adr":  "adr_i",
				"datwr":"dat_i",
				"datrd":"dat_o",
				"ack":  "ack_o",
				"sel":  "sel_i"}
		)
		self.read = None
	
	async def write_reg(self,reg,val):
		await self.wbs.send_cycle([WBOp(reg, val)])
	
	async def read_reg(self, reg):
		wbRes = await self.wbs.send_cycle([WBOp(reg,idle=1,acktimeout=5)])
		self.read = wbRes[0].datrd.integer
	
	async def reset(self):
		self.dut.active <= 0
		await ClockCycles(self.dut.wb_clk_i, 1)
		self.dut.active <= 1
		await ClockCycles(self.dut.wb_clk_i, 1)
		self.dut.wb_rst_i <= 1
		for i in range(4):
			self.dut.io_in[get_io_signal_number(i,'I_LIMIT')] <= 0
			self.dut.io_in[get_io_signal_number(i,'V_LIMIT')] <= 0
			if (i != 3):
				self.dut.io_in[get_io_signal_number(i,'FAULT')] <= 0
		await ClockCycles(self.dut.wb_clk_i, 1)
		self.dut.wb_rst_i <= 0
		await ClockCycles(self.dut.wb_clk_i, 1)

	async def fault(self,channel,value):
		self.dut.io_in[get_io_signal_number(channel,'FAULT')] <= value
	
	async def v_limit(self,channel,value):
		self.dut.io_in[get_io_signal_number(channel,'V_LIMIT')] <= value
	
	async def i_limit(self,channel,value):
		self.dut.io_in[get_io_signal_number(channel,'I_LIMIT')] <= value
	
	async def wait_cycle(self,cycles):
		await ClockCycles(self.dut.wb_clk_i, cycles)

@cocotb.test()
async def test_wrapper(dut):
	# Synchronize in time to the PWM cycle.
	async def SyncWithCycle():
		while(True):
			await RisingEdge(dut.wb_clk_i)
			if dut.io_out[get_io_signal_number(0,'CYCLE')] == 1:
				break
		while(True):
			await RisingEdge(dut.wb_clk_i)
			if dut.io_out[get_io_signal_number(0,'CYCLE')] == 0:
				break
	
	# Globaly set PRESCALE and BREAK_BEFORE_MAKE for all 4 channels.
	async def GlobalSetup(PRESCALER=0,BREAK_BEFORE_MAKE=0):
		byte = (BREAK_BEFORE_MAKE << 4)|PRESCALER
		byte = byte<<24 | byte<<16 | byte<<8 | byte
		await be.write_reg(PWM_DRIVE_SETUP,byte)
		await be.read_reg(PWM_DRIVE_SETUP)
		assert(be.read == byte)
	
	# Globaly set the PWM for all 4 channels.
	async def GlobalPWM(PWM):
		byte = PWM<<24 | PWM<<16 | PWM<<8 | PWM
		await be.write_reg(PWM_DRIVE_PWM,byte)
		await be.read_reg(PWM_DRIVE_PWM)
		assert(be.read == byte)
	
	be = BusEmulator(dut)
	await be.reset()
	
	# General IO Test
	if True:
		dut._log.info("General I/O Test")
		# IO Check
		await be.read_reg(PWM_DRIVE_MODULE_CHECK)
		assert(be.read == PWM_DRIVE_MODULE_CHECK_PATTERN)
		# Check RESET values
		await be.read_reg(PWM_DRIVE_SETUP)
		assert(be.read == 0xF0F0F0F0)
		await be.read_reg(PWM_DRIVE_PWM)
		assert(be.read == 0x7F7F7F7F)
		# Cycle thru different values, verify bus I/O
		for BREAK_BEFORE_MAKE in range(16):
			for PRESCALER in range(8):
				await GlobalSetup(PRESCALER,BREAK_BEFORE_MAKE)
		for PWM in range(255):
			await GlobalPWM(PWM)
	
	pwm_measure = MeasurePWM(dut)
	cocotb.fork(pwm_measure.start())
	
	# PWM Test
	if True:
		if SHORT_RUN == True:
			PRESCALER_TEST = range(8)
			BREAK_BEFORE_MAKE_TEST = [0,1,15]
		else:
			PRESCALER_TEST = range(8)
			BREAK_BEFORE_MAKE_TEST = range(16)
			
		dut._log.info("PWM Test")
		for PRESCALER in PRESCALER_TEST:
			for BREAK_BEFORE_MAKE in BREAK_BEFORE_MAKE_TEST:
				await be.write_reg(PWM_DRIVE_RESET,0)
				await be.read_reg(PWM_DRIVE_RESET)
				assert(be.read == 0)
				
				# PWM Test UP
				dut._log.info('PWM TEST (PRESCALER = %d,BREAK_BEFORE_MAKE = %d)' % (PRESCALER,BREAK_BEFORE_MAKE))
				await GlobalSetup(PRESCALER,BREAK_BEFORE_MAKE)
				await GlobalPWM(0)

				await be.write_reg(PWM_DRIVE_RESET,0x01010101)
				await be.read_reg(PWM_DRIVE_RESET)
				assert(be.read == 0x01010101)
				
				if SHORT_RUN == True:
					test_pwm = [0x00,0x01,0x02,0xFC-BREAK_BEFORE_MAKE,0xFD-BREAK_BEFORE_MAKE,0xFE-BREAK_BEFORE_MAKE]
				else:
					test_pwm = range(0xFF-BREAK_BEFORE_MAKE)

				await SyncWithCycle()
				for PWM in test_pwm:
					await GlobalPWM(PWM)
					await SyncWithCycle()
					await SyncWithCycle()
					for i in range(4):
						check_high = PWM
						check_low = 256 - PWM
						check_high = check_high
						if (PWM == 0):
							check_low = max(0,check_low - BREAK_BEFORE_MAKE)
						else:
							check_low = max(0,check_low - (BREAK_BEFORE_MAKE*2))
						check_period = 256
						check_high = check_high * (1<<PRESCALER)
						check_low  = check_low * (1<<PRESCALER)
						check_period = check_period * (1<<PRESCALER)
						if (i==0):
							dut._log.info('DUTY=0x%02x,'%PWM+'HI=%d,LO=%d,PER=%d'%(pwm_measure.get_ticks_hi(i),pwm_measure.get_ticks_low(i),check_period))
							#print(check_high,check_low,check_period)
						assert(check_high == pwm_measure.get_ticks_hi(i))
						assert(check_low == pwm_measure.get_ticks_low(i))
		
	# Fault Test
	if True:
		if SHORT_RUN == True:
			PRESCALER_TEST = range(8)
			BREAK_BEFORE_MAKE_TEST = [0,1,15]
		else:
			PRESCALER_TEST = range(8)
			BREAK_BEFORE_MAKE_TEST = range(16)
		
		dut._log.info("BEGIN FAULT TEST")
		for PRESCALER in PRESCALER_TEST:
			for BREAK_BEFORE_MAKE in BREAK_BEFORE_MAKE_TEST:
				await be.write_reg(PWM_DRIVE_RESET,0)
				await be.read_reg(PWM_DRIVE_RESET)
				assert(be.read == 0)
				
				# PWM Test UP
				dut._log.info('FAULT TEST (PRESCALER = %d,BREAK_BEFORE_MAKE = %d)' % (PRESCALER,BREAK_BEFORE_MAKE))
				await GlobalSetup(PRESCALER,BREAK_BEFORE_MAKE)
				await GlobalPWM(0x7F)

				for i in range(3):
					await be.fault(i,0)
				
				await be.write_reg(PWM_DRIVE_RESET,0x01010101)
				await be.read_reg(PWM_DRIVE_RESET)
				assert(be.read == 0x01010101)
				
				await SyncWithCycle()
				
				for i in range(3):
					await be.fault(i,1)
				
				await be.wait_cycle(2)
				
				await be.read_reg(PWM_DRIVE_RESET)
				assert(be.read == 0x01818181)
	
	# IV-LIMIT
	if True:
		if SHORT_RUN == True:
			PRESCALER_TEST = range(8)
			BREAK_BEFORE_MAKE_TEST = [0,1,15]
		else:
			PRESCALER_TEST = range(8)
			BREAK_BEFORE_MAKE_TEST = range(16)
		
		for vi in range(2):
			if vi == 0:
				dut._log.info("BEGIN V-LIMIT TEST")
			else:
				dut._log.info("BEGIN I-LIMIT TEST")
			
			for PRESCALER in PRESCALER_TEST:
				for BREAK_BEFORE_MAKE in BREAK_BEFORE_MAKE_TEST:
					for i in range(4):
						await be.v_limit(i,0)
						await be.i_limit(i,0)
					for i in range(3):
						await be.fault(i,0)
					
					await be.write_reg(PWM_DRIVE_RESET,0)
					await be.read_reg(PWM_DRIVE_RESET)
					assert(be.read == 0)
					
					if vi == 0:
						dut._log.info('V-LIMIT (PRESCALER = %d,BREAK_BEFORE_MAKE = %d)' % (PRESCALER,BREAK_BEFORE_MAKE))
					else:
						dut._log.info('I-LIMIT (PRESCALER = %d,BREAK_BEFORE_MAKE = %d)' % (PRESCALER,BREAK_BEFORE_MAKE))
					
					await GlobalSetup(PRESCALER,BREAK_BEFORE_MAKE)
					await GlobalPWM(0x7F)
					
					await be.write_reg(PWM_DRIVE_RESET,0x01010101)
					await be.read_reg(PWM_DRIVE_RESET)
					assert(be.read == 0x01010101)
					
					await SyncWithCycle()
					
					await be.wait_cycle(0x50*(1<<PRESCALER))
					check = 0x50
					if PRESCALER == 0:
						check += 4
					if PRESCALER == 1:
						check += 2
					if PRESCALER == 2:
						check += 1
					
					for i in range(4):
						if vi == 0:
							await be.v_limit(i,1)
						else:
							await be.i_limit(i,1)
						
					await be.wait_cycle(2)
					
					check = (check<<24)|(check<<16)|(check<<8)|(check)
					await be.read_reg(PWM_DRIVE_IV_LIMIT)
					assert(be.read == check)
