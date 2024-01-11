import random
import secrets

class SeqItem:
    def __init__(self, channel_qty):
        self._channel_qty = channel_qty
        self._ch_pkt_qty = {}

    def _random_pkts(self): # Func for rand nonrepeating int and add in list
        for i in range(self._channel_qty):
            self._ch_pkt_qty[f'Channel_{i}'] = 20 #random.randint(10, 40)

    def randomize(self):
        self._random_pkts()

    @property
    def ch_pkt_qty(self)->dict: return self._ch_pkt_qty