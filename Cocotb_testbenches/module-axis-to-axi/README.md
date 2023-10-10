#  Module - DMA
## List of tests for the module:

- test_reg - Don't need additional parameters
- test_each_axis_channel[Channel=x] x - The number of the channel through which you want to send data. By default, all channels are being sorted out
- test_full_axis_channel - Don't need additional parameters
- test_frame_reg_status[FRAME_REG_STATUS=x] x - The number of the status register which you want to test. By default, all status registers are being sorted out
- test_turn_off_on - Don't need additional parameters

## Description of tests:

1. "test_regs" - Simple test of all registers in DMA.
2. "test_each_axis_channel" - Test for 1 of 5 AXIStream channel
3. "test_full_axis_channel" - Test for all AXIStream channel in parallel with random launch with a header check.
4. "test_frame_reg_status" - Test for all AXIStream channel in parallel with random launch and with a status register check.
5. "test_turn_off_on" - Test for all AXIStream channel in parallel with random launch ,random stop and turn off DMA and random qty of frames.

## A brief description of how to run the test

Command to run full regression

```sh

make run WORK_LIB=work

```

Command to run 1 test from regression.
1. Select a test name from the list of tests above
2. If the test is with a parameter, then select the parameter

Example:

```sh

make run_spec_test TEST=test_frame_reg_status[FRAME_REG_STATUS=2] WORK_LIB=work

```

For a more detailed description, click [here](https://confluence.artec-group.com:4432/display/SP2/Verification+Enviroment+Wiki)