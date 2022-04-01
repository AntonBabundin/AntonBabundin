
import json

class Json_class:
    def __init__(self, json_path): 
        self.json_path = json_path
        self._title = ''
        self._description = ''
        self._enable = bool()
        self._id = ''
        self._actions = list()
        self._args = tuple()
        self._fileName = ''
        self._packetNumber = ''
        self._packetLength = ''
        self._packetDestMACs = ''
        self.json_parser(json_path)
    def json_parser(self, json_path):
        with open(json_path) as f:
            self._data = json.load(f)
            self._title = self._data[0]['title']
            self._description = self._data[0]['description']
            self._enable = self._data[0]['enabled']
            self._actions = self._data[0]['actions']
            self._id = self._data[0]['actions'][0]['id']
            self._args = self._data[0]['actions'][0]['args']
            self._fileName = self._data[0]['actions'][0]['args']['fileName']
            self._packetNumber = self._data[0]['actions'][0]['args']['packetNumber']
            self._packetLength = self._data[0]['actions'][0]['args']['packetLength']
            self._packetDestMAC0 = self._data[0]['actions'][0]['args']['packetDestMAC0']
            self._packetDestMAC1 = self._data[0]['actions'][0]['args']['packetDestMAC1']
            self._packetDestMAC2 = self._data[0]['actions'][0]['args']['packetDestMAC2']
            self._id_rvemu = self._data[0]['actions'][1]['id']
            self._firmware = self._data[0]['actions'][1]['args']['firmware']
            self._channelNumber = self._data[0]['actions'][1]['args']['channelNumber']
            self._inputPacket = self._data[0]['actions'][1]['args']['inputPacket']
            self._id_pcap_cmp = self._data[0]['actions'][2]['id']
            self._file1Name_ch_0 = self._data[0]['actions'][2]['args']['file1Name']
            self._file2Name_ch_0 =  self._data[0]['actions'][2]['args']['file2Name']
            self._file1Name_ch_1 = self._data[0]['actions'][3]['args']['file1Name']
            self._file2Name_ch_1 =  self._data[0]['actions'][3]['args']['file2Name']
            self._file1Name_ch_2 = self._data[0]['actions'][4]['args']['file1Name']
            self._file2Name_ch_2 =  self._data[0]['actions'][4]['args']['file2Name']
    def title_getter(self):
        return self._title
    def description_getter(self):
        return self._description
    def enable_getter(self):
        return self._enable
    def action_getter(self):
        return self._actions
    def id_getter(self):
        return self._id
    def args_getter(self):
        return self._args
    def fileName_getter(self):
        return self._fileName
    def packetNumber_getter(self):
        return self._packetNumber
    def packetLength_getter(self):
        return self._packetLength
    def packetDestMAC0_getter(self):
        return self._packetDestMAC0
    def packetDestMAC1_getter(self):
        return self._packetDestMAC1
    def packetDestMAC2_getter(self):
        return self._packetDestMAC2
    def id_rvemu_getter(self):
        return self._id_rvemu
    def firmware_getter(self):
        return self._firmware
    def channelNumber_getter(self):
        return self._channelNumber
    def inputPacket_getter(self):
        return self._inputPacket
    def id_pcap_cmp_getter(self):
        return self._id_pcap_cmp
    def file1Name_getter_ch_0(self):
        return self._file1Name_ch_0
    def file2Name_getter_ch_0(self):
        return self._file2Name_ch_0
    def file1Name_getter_ch_1(self):
        return self._file1Name_ch_1
    def file2Name_getter_ch_1(self):
        return self._file2Name_ch_1
    def file1Name_getter_ch_2(self):
        return self._file1Name_ch_2
    def file2Name_getter_ch_2(self):
        return self._file2Name_ch_2
