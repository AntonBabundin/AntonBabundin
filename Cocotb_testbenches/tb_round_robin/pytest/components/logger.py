import logging

class SetupLog:
    def __init__(self) -> None:
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.CRITICAL)