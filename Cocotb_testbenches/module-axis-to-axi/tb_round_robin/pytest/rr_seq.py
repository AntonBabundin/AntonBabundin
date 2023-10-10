# -----------------------------------------------------
#       Company Name                   : Artec 3D
#       Pytest top file name           : dma_test.py
#       DUT top file name              : tb.sv
#       Function                       : Regression tests for DMA
#       Required GIT Libraries         : cocotb 1.6.2, cocotb-test 0.2.2, cocotbext-axi 0.1.18, cocotb-bus 0.2.1 
#       Required Proprietary Libraries : artec3d_apb, artec3d_regs
#       Main Coder                     : Babundin Anton
#       Last Сhanges                   : 02.08.2022 - Added TestFactory(Autocreate tests), 
#                                        Added random ready(AXISlave)and valid(AXIStream)
#                                        04.08.2022 - Added regression for FRAME_STATUS_PTR
#                                        05.08.2022 - Added parallel wirte on AXIStream channels with random start
#                                                     Added watchdog timer
#                                        06.10.2022 - Added test for HEADER
#                                        10.11.2022 - Added test with unfinished frames
# -----------------------------------------------------
#Standart libs
import os
import random
import logging
#Cocotb libs
import cocotb
from cocotb.triggers import Timer, RisingEdge, Combine,FallingEdge
from cocotb.result import TestSuccess
from cocotb import utils
#Test libs
from logger import SetupLog
from rr_model import Process, RoundRobin
from constants import Constants
from rr_item import SeqItem
import misc

class Connection:
    def __init__(self, dut):
        self.dut = dut

        self.dut.clear.setimmediatevalue(0)
        self.dut.req_i[0].setimmediatevalue(0)
        self.dut.req_i[1].setimmediatevalue(0)
        self.dut.req_i[2].setimmediatevalue(0)
        self.dut.req_i[3].setimmediatevalue(0)
        self.dut.req_i[4].setimmediatevalue(0)
        self.dut.req_i[5].setimmediatevalue(0)

class RrModelWrapper:
    def __init__(self, item) -> None:
        self.processes = [
            Process("CHANNEL_0", Constants.MAX_QTY_PACKETS_CH_0),
            Process("CHANNEL_1", Constants.MAX_QTY_PACKETS_CH_1),
            Process("CHANNEL_2", Constants.MAX_QTY_PACKETS_CH_2),
            Process("CHANNEL_3", Constants.MAX_QTY_PACKETS_CH_3),
            Process("CHANNEL_4", Constants.MAX_QTY_PACKETS_CH_4),
            Process("CHANNEL_5", Constants.MAX_QTY_PACKETS_CH_5)
        ]



@cocotb.test()
async def simple_seq(dut):
    """Round Robin simple test"""
    SetupLog()   # Init logger
    Connection(dut) # Init values
    item = SeqItem(6) # Init Seq Item
    item.randomize() # Rand items
    processes = [
        Process("CHANNEL_0", Constants.MAX_QTY_PACKETS_CH_0),
        Process("CHANNEL_1", Constants.MAX_QTY_PACKETS_CH_1),
        Process("CHANNEL_2", Constants.MAX_QTY_PACKETS_CH_2),
        Process("CHANNEL_3", Constants.MAX_QTY_PACKETS_CH_3),
        Process("CHANNEL_4", Constants.MAX_QTY_PACKETS_CH_4),
        Process("CHANNEL_5", Constants.MAX_QTY_PACKETS_CH_5)
    ]

    rr_proc = RoundRobin(processes)

    processes[0].add_packets(item.ch_pkt_qty.get("Channel_0"))
    processes[1].add_packets(item.ch_pkt_qty.get("Channel_1"))
    processes[2].add_packets(item.ch_pkt_qty.get("Channel_2"))
    processes[3].add_packets(item.ch_pkt_qty.get("Channel_3"))
    processes[4].add_packets(item.ch_pkt_qty.get("Channel_4"))
    processes[5].add_packets(item.ch_pkt_qty.get("Channel_5"))

    logging.critical("Resets start")
    cocotb.start_soon(misc.reset_on_clock(dut.rstn, dut.clk, click_time=100))
    logging.critical("Resets end")
    await Combine(increment_req(dut, Constants.CHANNEL_0, item.ch_pkt_qty.get("Channel_0")), increment_req(dut, Constants.CHANNEL_1, item.ch_pkt_qty.get("Channel_1")), increment_req(dut, Constants.CHANNEL_2, item.ch_pkt_qty.get("Channel_2")),
                  increment_req(dut, Constants.CHANNEL_3, item.ch_pkt_qty.get("Channel_3")), increment_req(dut, Constants.CHANNEL_4, item.ch_pkt_qty.get("Channel_4")),increment_req(dut, Constants.CHANNEL_5, item.ch_pkt_qty.get("Channel_5")))
    cocotb.start_soon(read_grant(dut, processes, rr_proc))
    await Timer(3500, 'ns')

@cocotb.coroutine
async def increment_req(dut, chann_num, incr_rng):
    for i in range(incr_rng+1):
        await RisingEdge(dut.clk)
        dut.req_i[chann_num].value = i

async def read_grant(dut, processes:list, rr_proc:RoundRobin):
    while True:
        await RisingEdge(dut.clk)
        if (processes[0].empty() and processes[1].empty() and processes[2].empty() 
           and processes[3].empty() and processes[4].empty() and processes[5].empty()):
            logging.critical("All queues are empty")
            raise TestSuccess()
        if dut.grant_valid_o.value:
            val = dut.grant_o.value.integer
            id_chan = rr_proc.round_robin_process()
            if id_chan is False:
                while True:
                    id_chan = rr_proc.round_robin_process()
                    if id_chan is not False:
                        break
            print(f"""RTL MODEL = {val}, PYTHON MODEL = {id_chan}\n
                    QUEUE_SIZE_0 = {processes[0].size()}\n
                    QUEUE_SIZE_1 = {processes[1].size()}\n
                    QUEUE_SIZE_2 = {processes[2].size()}\n
                    QUEUE_SIZE_3 = {processes[3].size()}\n
                    QUEUE_SIZE_4 = {processes[4].size()}\n
                    QUEUE_SIZE_5 = {processes[5].size()}\n
                    TIME = {utils.get_sim_time('ns')} ns""")
            assert val == id_chan, f"RTL MODEL GRANT = {val}, PYTHON MODEL GRANT = {id_chan}"
            dut.req_i[val].value = dut.req_i[val].value.integer-1
            processes[id_chan].get_packet()
        else:
            continue
