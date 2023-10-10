class APBContainer:
    def __init__(self) -> None:
        self._frame_ptr_addr_list_output:list = []
        self._offsets_list              :list = []
        self._apb_id                    :int
        self._version                   :int
        self._ch_num                    :int
        self._header_size               :int
        self._bpe                       :int
        self._type                      :int

    @property
    def frame_ptr_addr_list_output(self):
        return self._frame_ptr_addr_list_output
    @property
    def offsets_list(self):
        return self._offsets_list
    @property
    def apb_id(self):
        return self._apb_id
    @property
    def version(self):
        return self._version
    @property
    def ch_num(self):
        return self._ch_num
    @property
    def header_size(self):
        return self._header_size
    @property
    def bpe(self):
        return self._bpe
    @property
    def type(self):
        return self._type
    @property
    def mem_size(self):
        return self._mem_size
    @mem_size.setter
    def mem_size(self, value):
        self._mem_size = value

class AXISContainer:
    def __init__(self) -> None:
        self._data_out:bytes
        self._frame_header_dict:dict = {}
    @property
    def data_out(self):
        return self._data_out.hex()
    @property
    def frame_header_dict(self):
        return self._frame_header_dict
    @data_out.setter
    def data_out(self, value):
        self._data_out = value

class FrameStatusHeaderContainer:
    def __init__(self) -> None:
        self._frame_status:bytes
        self._frame_header:dict = {}
    @property
    def frame_status(self):
        return self._frame_status
    @frame_status.setter
    def frame_status(self, value):
        self._frame_status = value
    @property
    def frame_header(self):
        return self._frame_header
