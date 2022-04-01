import subprocess
import os
from pathlib import Path
from cocotb import result
from scapy.all import wrpcap
from pcap_read import txt_gen      # Custom utils
from json_reader import Json_class # Custom utils
import cocotb
from cocotb.result import TestFailure, TestSuccess
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotbext.eth import GmiiFrame, RgmiiPhy

run_path = Path().resolve()
Json_obj = Json_class(f'{str(run_path.parent)}/rtl/hw/npu/tb/general_sim_npu/full.json')
fileOutPcap_0 = Json_obj.file2Name_getter_ch_0()
fileOutPcap_1 = Json_obj.file2Name_getter_ch_1()
fileOutPcap_2 = Json_obj.file2Name_getter_ch_2()

def pcap_gen(id, fileName, packetNumber, packetLenthgs, packetDestMAC0, packetDestMAC1, packetDestMAC2):
        p1 = subprocess.run([f'{str(run_path.parent)}/rtl/rtl-tools/npu/pcap/utils/pcap_gen/{id}', f'{fileName}', f'{packetNumber}', f'{packetLenthgs}', f'{packetDestMAC0}', f'{packetDestMAC1}', f'{packetDestMAC2}'], capture_output=True, text=True)
        if p1.returncode == 0:
            txt_gen(f'{fileName}',f'{fileName}.txt')
        else:
            print("Some wrong with pcap_gen")

def rvemu_open(id, firmware, pcap_file, port_nmb):
    p1 = subprocess.run([f'{str(run_path.parent)}/rtl/rtl-tools/npu/rvemu/{id}', f'{str(run_path.parent)}/img/{firmware}', f'{str(run_path)}/{pcap_file}', f'{port_nmb}'],text=True, stderr=True, cwd=f'{str(run_path.parent)}/rtl/rtl-tools/npu/rvemu')
    if p1.returncode == 0:
        print ("Emulation success")
    else:
        print ("Emulation failed")
        print(p1.returncode)
        raise Exception


def pcap_cmp(id ,pcap_in, pcap_out):
    p1 = subprocess.run([f'{str(run_path.parent)}/rtl/rtl-tools/npu/pcap/utils/pcap_cmp/{id}', f'{str(run_path.parent)}/rtl/rtl-tools/npu/rvemu/{pcap_in}', f'{pcap_out}'], text=True,  stderr=True)
    if p1.returncode == 0:
        print("All okay")
    else: 
        print("Not okay")


@cocotb.test(skip= not Json_obj.enable_getter())
async def load_on_4_channels(dut):
    """Simple test for simulation NPU"""
    fileName = Json_obj.fileName_getter()
    fileOutPcap_0 = "output_0.pcap"
    title = Json_obj.title_getter()
    description = Json_obj.description_getter()
    dut._log.info(f"            TITLE:  {title}")
    dut._log.info(f"Description of test: {description}")
    pcap_gen(Json_obj.id_getter(), Json_obj.fileName_getter(), Json_obj.packetNumber_getter(), 
                            Json_obj.packetLength_getter(), Json_obj.packetDestMAC0_getter(), Json_obj.packetDestMAC1_getter(), Json_obj.packetDestMAC2_getter())
    rvemu_open(Json_obj.id_rvemu_getter(), Json_obj.firmware_getter(), Json_obj.inputPacket_getter(), Json_obj.channelNumber_getter())
    cocotb.fork(Clock(dut.CLK_ext_i_p, 5, units="ns").start())
    cocotb.fork(Clock(dut.CLK_ext_i_n, 5, units="ns").start(start_high=False))

    cocotb.fork(Clock(dut.ETH_RXCLK_0, 8, units="ns").start())# Init cloclk channel 0
    cocotb.fork(Clock(dut.ETH_RXCLK_1, 8, units="ns").start())# Init cloclk channel 0
    cocotb.fork(Clock(dut.ETH_RXCLK_2, 8, units="ns").start())# Init cloclk channel 0
    cocotb.fork(Clock(dut.ETH_RXCLK_3, 8, units="ns").start())# Init cloclk channel 0

    dut._log.info("Reset start")
    while str(dut.sys_rst.value) != '0':
        await RisingEdge(dut.CLK_ext_i_p)  
    await Timer(2, units='us')
    dut._log.info("Reset end")
    source_channel_0 = RgmiiPhy(dut.ETH_TXD0, dut.ETH_TXCTL_0, dut.ETH_TXCLK_0, dut.ETH_RXD0, dut.ETH_RXCTL_0, dut.ETH_RXCLK_0, speed=1000e6, reset_active_level=False)
    source_channel_1 = RgmiiPhy(dut.ETH_TXD1, dut.ETH_TXCTL_1, dut.ETH_TXCLK_1, dut.ETH_RXD1, dut.ETH_RXCTL_1, dut.ETH_RXCLK_1, speed=1000e6, reset_active_level=False)
    source_channel_2 = RgmiiPhy(dut.ETH_TXD2, dut.ETH_TXCTL_2, dut.ETH_TXCLK_2, dut.ETH_RXD2, dut.ETH_RXCTL_2, dut.ETH_RXCLK_2, speed=1000e6, reset_active_level=False)
    source_channel_3 = RgmiiPhy(dut.ETH_TXD3, dut.ETH_TXCTL_3, dut.ETH_TXCLK_3, dut.ETH_RXD3, dut.ETH_RXCTL_3, dut.ETH_RXCLK_3, speed=1000e6, reset_active_level=False)
    i = 0
    dut._log.info("Start transactions")
    with open(f'{fileName}.txt', 'r') as f0:
        while True:
            line0 = (f0.readline()).rstrip()

            if not line0:
                dut._log.info("End of test")
                break
        
            payload0 = bytearray.fromhex(line0)

            test_frame_0 = GmiiFrame.from_payload(payload0)
            await source_channel_0.rx.send(test_frame_0)

            if i % 3 == 0:
                rx_frame_0 = await source_channel_0.tx.recv()
                wrpcap(fileOutPcap_0, bytes(rx_frame_0.get_payload()), append = True)
            elif i % 3 == 1:
                rx_frame_1 = await source_channel_1.tx.recv()
                wrpcap(fileOutPcap_1, bytes(rx_frame_1.get_payload()), append = True)
            elif i % 3 == 2:
                rx_frame_2 = await source_channel_2.tx.recv()
                wrpcap(fileOutPcap_2, bytes(rx_frame_2.get_payload()), append = True)
            i+=1
    pcap_cmp(Json_obj.id_pcap_cmp_getter(), Json_obj.file1Name_getter_ch_0(), Json_obj.file2Name_getter_ch_0())
    pcap_cmp(Json_obj.id_pcap_cmp_getter(), Json_obj.file1Name_getter_ch_1(), Json_obj.file2Name_getter_ch_1())
    pcap_cmp(Json_obj.id_pcap_cmp_getter(), Json_obj.file1Name_getter_ch_2(), Json_obj.file2Name_getter_ch_2())
    if os.path.exists(fileOutPcap_0) and os.path.exists(fileOutPcap_1) and os.path.exists(fileOutPcap_2):
        os.remove(fileOutPcap_0)
        os.remove(fileOutPcap_1)
        os.remove(fileOutPcap_2)
    else:
        print(f"The file does not exist")
