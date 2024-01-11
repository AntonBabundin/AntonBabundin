from queue import Queue
from itertools import cycle
REGISTER_THRESHOLD = 16

class Process:
    _id_ch = -1
    def __init__(self, name, max_size):
        self._name = name
        self._counter = 0
        __class__._id_ch +=1
        self._id_channel = __class__._id_ch
        self.data_queue = Queue(maxsize=max_size)

        self._priority = False

        self._valid = False
        self._first = False

    @property
    def name(self): return self._name 

    @property
    def counter(self): return self._counter
    @counter.setter
    def counter(self, val:int):
        self._counter = val

    @property
    def priority(self): return self._priority

    @priority.setter
    def priority(self, val:bool):
        self._priority = val

    @property
    def valid(self): return self._valid
    @valid.setter
    def valid(self, val:bool):
        self._valid = val

    @property
    def first(self): return self._first 
    @first.setter
    def first(self, val:bool):
        self._first = val

    @property
    def id_channel(self): return self._id_channel 


    def __str__(self) -> str:
        return f"""Process {self.name} priority = {self.priority}, counter = {self.counter} remaining packets = {self.size()}, valid = {self.valid}"""

    def add_packets(self, pkt_qty):
        for i in range(pkt_qty):
            if self.data_queue.full():
                print(f"Process {self.name} is full. Packets skipped")
                return 0
            self.data_queue.put(1)
            if self.size() >= REGISTER_THRESHOLD:
                self.priority = True

    def get_packet(self):
        if self.data_queue.empty():
            print(f"Process {self.name} is empty")
            return 0
        self.data_queue.get()
        if self.size() <= REGISTER_THRESHOLD:
            self.priority = False
    
    def size(self):
        return self.data_queue.qsize()
    
    def empty(self):
        return self.data_queue.empty()


class RoundRobin:
    def __init__(self, processes:list) -> None:
        self._processes = processes
        self._processes[0].first = True
        self._qty_channels = len(self._processes)
        self._clock = 0
        self._rr_last_prior_channel : str

    def _increment_counter_check_priority(self): ## Func for incr counter for each channel and check prior after rr proccess
        for proc in self._processes:
            proc.counter += 1
            if proc.counter >= REGISTER_THRESHOLD:
                print(f"Counter worked. Process = {proc.name}")
                proc.priority = True

    def _checker(self): ## Func for checking priority and valid
        self._valid_counter = 0
        for proc in self._processes:
            if proc.size() >= REGISTER_THRESHOLD:
                proc.priority = True

            if proc.priority == False:
                proc.valid = True
                self._valid_counter +=1
        return self._valid_counter

    def _transfer_first_counter(self): ## Func for checking priority and valid
        pool = cycle(self._processes)
        for channel in pool:
            if channel.first == True:
                channel.first = False
                next(pool).first = True
                break

    def round_robin_process(self)->int:
        _valid_counter = self._checker()
        if _valid_counter == self._qty_channels:
            while True:
                cur_proc = next((proc for proc in self._processes if proc.first == True and proc.valid == True), None)
                if cur_proc == None:
                    self._transfer_first_counter()
                else:
                    break
        else:
            while True:
                cur_proc = next((proc for proc in self._processes if proc.first == True and proc.priority == True), None)
                if cur_proc == None:
                    self._transfer_first_counter()
                else:
                    break
        if cur_proc.priority == True or (self._valid_counter == self._qty_channels):
            cur_proc.counter=0
            if cur_proc.data_queue.empty():
                print(f"Process {cur_proc.name} is empty")
                self._transfer_first_counter()
                return False
            self._transfer_first_counter()
            if cur_proc.size() < REGISTER_THRESHOLD+1:
                cur_proc.priority = False
            self._increment_counter_check_priority()
            self._clock += 1
            print(f"\nClock = {self._clock}")
            print(cur_proc)
            return cur_proc.id_channel # Return id of choosed channel

# if __name__ == "__main__":
#     #Example how work with model
#     processes = [
#         Process("AXIS_CHANNEL_0", 16),
#         Process("AXIS_CHANNEL_1", 21),
#         Process("AXIS_CHANNEL_2", 20),
#         Process("AXIS_CHANNEL_3", 16),
#         Process("AXIS_CHANNEL_4", 13)
#     ]
#     rr_proc = RoundRobin(processes)
#     processes[0].add_packets(16)
#     processes[1].add_packets(21)
#     processes[2].add_packets(20)
#     processes[3].add_packets(16)
#     processes[4].add_packets(13)
#     for i in range(25):
#         id_chan = rr_proc.round_robin_process()
#         print(id_chan)
#         processes[id_chan].get_packet()


#     processes[1].get_packet()
#     rr_proc.round_robin_process()
#     rr_proc.round_robin_process()
#     rr_proc.round_robin_process()
#     rr_proc.round_robin_process()