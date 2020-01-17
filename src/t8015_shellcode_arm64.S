.text

.pool
.set RD_MD0_PROG_ADDR, 0x18008CF2D
.set RD_MD0_PATCH_VERBOSE, 0x0000762D
.set X19_ARGS_ADDR, 0x180033470
.set X19_ARGS_PATCH, 0x302CD5F3
.set CSEL_ARGS_ADDR, 0x180033344
.set CSEL_ARGS_PATCH, 0xAA0903F3
.set JUMP_BACK, 0x180018004

.globl _main
_main:
 msr DAIFSET, #0xF

 ldr x5, =RD_MD0_PROG_ADDR
 ldr w6, =RD_MD0_PATCH_VERBOSE
 str w6, [x5]
 ldr x5, =X19_ARGS_ADDR
 ldr w6, =X19_ARGS_PATCH
 str w6, [x5]
 ldr x5, =CSEL_ARGS_ADDR
 ldr w6, =CSEL_ARGS_PATCH
 str w6, [x5]

 /* 
 	now we've overwrote rd=md0 data address with -v
 	additionally, there's an instruction that looks like this:

 	ADR X19, byte_xxxxxx

 	we've patched this instruction to ADR rd=md0 (-progress) address into X19
 	it should now look like

 	ADR X19, #0x59abd

 	where 0x59abd is a pc relative offset to the data location of rd=md0 (can be calculated by subtracting address of the ADR X19 instruction from the data address of rd=md0)

 	x19 is later loaded into the stack boot args
 	we now have -v on the stack boot args

 	we do the same to a CSEL instruction that also loads something into x19
 	the rd=md0 -progress data address is loaded into x9 and the one without -progress is loaded into x8
 	since we patched -progress, we want x9 to now always be loaded into x19 no matter what
 	so we patch

 	CSEL x19, x9, x8, NE

 	with

 	MOV x19, x9

 	let's jump back and continue normal boot of the device now
 */

 ldr x5, =JUMP_BACK
 br x5