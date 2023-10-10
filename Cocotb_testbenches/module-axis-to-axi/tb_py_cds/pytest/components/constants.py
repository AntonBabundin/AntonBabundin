import dataclasses

@dataclasses.dataclass
class Status:
    FINISH_FIELD           :str = '0x8'
    CLEAR_FIELD            :str = '0x8'
    FRAME_STATUS           :int = 0
    ENABLE_ALL_AXIS_CHANNEL:int = 0x3F
    FRAME_STATUS_PTR_ADDR  :int = 0x68800

@dataclasses.dataclass
class Constants:
    FRAME_PTR_QTY        :int = 8 # Frame regs quantity
    OFFSETS_QTY          :int = 6
    AXIS_0_WIDTH         :int = 64
    AXIS_1_WIDTH         :int = 64
    AXIS_2_WIDTH         :int = 64
    AXIS_3_WIDTH         :int = 64
    AXIS_4_WIDTH         :int = 64
    AXIS_5_WIDTH         :int = 64
    QTY_OF_BYTES_RND_DATA:int = 2048
    MEM_SIZE             :int = 0x00DB0000
