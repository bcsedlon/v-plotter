''' blinkled.py - test script for the PyPRUSS library
It blinks the user leds ten times'''

import pypruss
import mmap

import Adafruit_BBIO.GPIO as GPIO
GPIO.setup('P9_15',GPIO.OUT)
#GPIO.output('P9_15', False)

 
DDR_BASEADDR        = 0x70000000                    # The actual baseaddr is 0x80000000, but due to a bug(?),
DDR_HACK            = 0x10001000                    # Python accept unsigned int as offset argument.
DDR_FILELEN         = DDR_HACK+0x1000               # The amount of memory to make available
DDR_OFFSET          = DDR_HACK                      # Add the hack to the offset as well.
 
steps = 10000
b0 = steps % 256
b1 = (steps >> 8) % 256
b2 = (steps >> 16) % 256
b3 = steps >> 24

with open("/dev/mem", "r+b") as f:                  # Open the memory device
    ddr_mem = mmap.mmap(f.fileno(), DDR_FILELEN, offset=DDR_BASEADDR) #
data = "".join(map(chr, [b0, b1, b2, b3]))              # Make the data, it needs to be a string
ddr_mem[DDR_OFFSET:DDR_OFFSET+4] = data             # Write the data to the DDR memory, four bytes should suffice
ddr_mem.close()                                     # Close the memory
f.close()                                           # Close the file





pypruss.modprobe() 			  # This only has to be called once pr boot
pypruss.init()				  # Init the PRU
pypruss.open(0)				  # Open PRU event 0 which is PRU0_ARM_INTERRUPT
pypruss.pruintc_init()			  # Init the interrupt controller
pypruss.exec_program(0, "./blinkled.bin") # Load firmware "blinkled.bin" on PRU 0
pypruss.wait_for_event(0)		  # Wait for event 0 which is connected to PRU0_ARM_INTERRUPT
pypruss.clear_event(0)			  # Clear the event
pypruss.pru_disable(0)			  # Disable PRU 0, this is already done by the firmware
pypruss.exit()				  # Exit, don't know what this does. 

#import pypruss as pru                   # The Programmable Realtime Unit Library
#import numpy as np                      # Needed for braiding the pins with the delays

#distance =100
#steps_pr_mm = 1
#inst_pr_step = 1
#num_steps = int(distance*steps_pr_mm)   # Number of ticks in total
#steps     = [(1<<12), 0]*num_steps      # Make the table of ticks for the stepper.
#delays    = [inst_pr_step]*2*num_steps  # Make the table of delays
 
#data = np.array([steps, delays])        # Make a 2D matrix combining the ticks and delays
#data = data.transpose().flatten()       # Braid the data so every other item is a
#data = [num_steps*2+1]+list(data)       # Make the data into a list and add the number of ticks total

#data = 50
#pru_num = 0                             # PRU0
#pru.init(pru_num, "./blinkled.bin")     # Load PRU 0 with the firmware.
#pru.set_data(pru_num, data)            # Load the data in the PRU ram
#pru.wait_for_event(pru_num)             # Wait a while for it to finish.
#pru.disable(pru_num)                    # Clean shit up, we don't want to be piggies.

GPIO.cleanup()
