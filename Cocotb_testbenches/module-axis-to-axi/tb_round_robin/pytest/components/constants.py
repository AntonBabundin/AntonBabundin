import dataclasses

@dataclasses.dataclass
class Constants:
    CHANNEL_0 :int = 0 
    CHANNEL_1 :int = 1
    CHANNEL_2 :int = 2
    CHANNEL_3 :int = 3
    CHANNEL_4 :int = 4
    CHANNEL_5 :int = 5

    MAX_QTY_PACKETS_CH_0 : int = 50
    MAX_QTY_PACKETS_CH_1 : int = 50
    MAX_QTY_PACKETS_CH_2 : int = 50
    MAX_QTY_PACKETS_CH_3 : int = 50
    MAX_QTY_PACKETS_CH_4 : int = 50
    MAX_QTY_PACKETS_CH_5 : int = 50