import random
import secrets
from constants import Status

class SeqItem:
    def __init__(self, name, **kwargs):
        self._name = name
        self._range_rnd = kwargs.get('rand_range')
        self._min_step_from_mem = kwargs.get('min_mem_step')
        self._qty_of_bytes = kwargs.get('qty_of_bytes')
        self._qty_of_axis_channel = kwargs.get('qty_of_axis_channel')

    def _random_adr(self): # Func for rand nonrepeating int and add in list
        self._frame_ptr_addr_list = [] # List with random addresses for FRAME regs 
        for _ in range(self._range_rnd):
            while True:
                addr_rand = random.randrange(0, random.getrandbits(32), self._min_step_from_mem)
                # alignment depends on Output AXI Data Width (128)
                if (addr_rand % 16 !=0) or (addr_rand==Status.FRAME_STATUS_PTR_ADDR) or (addr_rand in  self._frame_ptr_addr_list):
                    continue
                else:
                    break
            self._frame_ptr_addr_list.append(addr_rand)

    def _random_data(self):
        self._data = secrets.token_hex(self._qty_of_bytes)

    def _random_data_for_full_axis(self):
        self._data_for_axis = []
        self._data_bytes_len_ram = []
        for _ in range(self._qty_of_axis_channel):
            data_int_bytes_len = random.randrange(2*1024, 30*1024)      # Random from 2 to 30 KB data for each AXIS channel
            self._data_for_axis.append(secrets.token_hex(data_int_bytes_len)) #
            self._data_bytes_len_ram.append(data_int_bytes_len)               # I add to the list the length of data for each AXIS channel (for reading by AxiRAM)

    def _random_tuser(self):
        self._tuser = random.randrange(0,8)

    def _random_time(self):
        self._time = random.randrange(100, 1000)

    def randomize(self):
        self._random_adr()
        self._random_data()
        self._random_tuser()
        self._random_time()
        self._random_data_for_full_axis()

    @property
    def name(self)->str: return self._name
    @property
    def data_for_axis(self)->list: return self._data_for_axis
    @property
    def data_bytes_len_ram(self)->list: return self._data_bytes_len_ram
    @property
    def frame_ptr_addr_list(self)->list: return self._frame_ptr_addr_list
    @property
    def tuser(self)->int: return self._tuser
    @property
    def time(self)->int: return self._time
    @property
    def data(self)->list: return self._data