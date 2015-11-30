.origin 0
.entrypoint START

#define PRU0_ARM_INTERRUPT 19

#define GPIO1 			0x4804c000		// The adress of the GPIO1 
#define GPIO_CLEARDATAOUT 	0x190
#define GPIO_SETDATAOUT 	0x194
#define STEPDELAYCYCLES	 	0x000005000 		// Min = 0x000002500


//#define LEN_ADDR        0x00000000     			// Adress of the abort command         
//#define PIN_OFFSET      0x00000004      		// Offset for the pins (reserve the first adress for abort)

#define CONST_DDR           C31
#define CTPPR_1             0x2202C 


START:
    
    //MOV  r0, 0                          		// The first register contains the loop count
    //LBBO r1, r0, LEN_ADDR, 4            		// Load the number of steps to perform into r1
    //MOV  r4, PIN_OFFSET                 		// r4 is the pin and delay counter
 
    MOV r0, 0x00100000          // Configure the programmable pointer register for PRU0 by setting c31_pointer[15:0]
    MOV r1, CTPPR_1             // field to 0x0010. This will make C31 point to 0x80001000 (DDR memory).
    SBBO r0, r1, 0, 4
    LBCO r1, CONST_DDR, 0, 4     //Load values from external DDR Memory into R1

	LBCO r4, CONST_DDR, 0, 4     //Load values from external DDR Memory into R4, left motor P9_15
	LBCO r5, CONST_DDR, 4, 4     //Load values from external DDR Memory into R5, right motor P9_23
	MAX r1, r4, r5


    LBCO r0, C4, 4, 4					// Load Bytes Constant Offset (?)
    CLR  r0, r0, 4					// Clear bit 4 in reg 0
    SBCO r0, C4, 4, 4					// Store Bytes Constant Offset

    //MOV r1, 10000
BLINK:
    MOV r2, 0
	MOV r6, 0
	MOV r7, 0
	
	QBGE SKIP_P9_15, r4, 0
	SUB r4, r4, 1
    MOV r6, 1<<16 | 1<<23 //P9_15 | USR2
	
SKIP_P9_15:
	
	QBGE SKIP_P9_23, r5, 0
	SUB r5, r5, 1
    MOV r7, 1<<17 | 1<<24 //P19_23 | USR3
    
SKIP_P9_23:
   
    //set GPIO
	OR r2, r6, r7
    MOV r3, GPIO1 | GPIO_SETDATAOUT
    SBBO r2, r3, 0, 4

    MOV r0, STEPDELAYCYCLES
DELAY:
    SUB r0, r0, 1
    QBNE DELAY, r0, 0

	//reset GPIO
    MOV r2, 1<<16 | 1<<17 | 1<<23 | 1<<24 //P9_15 | P9_23 | USR2 | USR3
    MOV r3, GPIO1 | GPIO_CLEARDATAOUT
    SBBO r2, r3, 0, 4


    MOV r0, STEPDELAYCYCLES
DELAY2:
    SUB r0, r0, 1
    QBNE DELAY2, r0, 0
    
	SUB r1, r1, 1
    QBNE BLINK, r1, 0

    MOV R31.b0, PRU0_ARM_INTERRUPT+16   // Send notification to Host for program completion
HALT


//GPIO1_14 'P8_16'
//GPIO1_15 'P8_15'
//GPIO1_16 'P9_15'
//GPIO1_17 'P9_23'
