#
# Library to access ADS1115 ADC to use the load cell
#
# 2019 Tomasz Bialas
#

class LoadSensor():
    import smbus
    import time
    
    CONFIG_REG_ADDR = 0x01
    CONVERT_REG_ADDR = 0x00

    def __init__(self, bus = 1, addr = 0x48, cfg_OS = 0b0, cfg_MUX = 0b000, cfg_PGA = 0b000, cfg_MODE = 0b1, cfg_DR = 0b100, cfg_COMP_MODE = 0b0, cfg_COMP_POL = 0b0, cfg_COMP_LAT = 0b0, cfg_COMP_QUE = 0b11,  offset = 0):
        self.dev_bus = bus
        self.dev_addr = addr
        self.cal_offset = offset
        # registers
        self.config_OS = cfg_OS
        self.config_MUX = cfg_MUX
        self.config_PGA = cfg_PGA
        self.config_MODE = cfg_MODE
        self.config_DR = cfg_DR
        self.config_COMP_MODE = cfg_COMP_MODE
        self.config_COMP_POL = cfg_COMP_POL
        self.config_COMP_LAT = cfg_COMP_LAT
        self.config_COMP_QUE = cfg_COMP_QUE
        self.config = self.config_OS << 15 | self.config_MUX << 12 | self.config_PGA << 9 | self.config_MODE << 8 | self.config_DR << 5 | self.config_COMP_POL << 4 | self.config_COMP_LAT << 3 | self.config_COMP_QUE

        self.bus = self.smbus.SMBus(self.dev_bus)
        self.read_config()

    def get_sample(self):
        # If single-shot mode enabled, check if device free
        # start conversion and block until complete
        if (self.config_MODE == 1):
            #print("oneshot")
            self.read_config()
            while(self.config_OS != 1):
                self.read_config()
            self.OS = 1
            self.write_config()
            self.read_config()
            while(self.config_OS != 1):
                self.read_config()


        sample = self.bus.read_i2c_block_data(self.dev_addr, self.CONVERT_REG_ADDR, 2)
        value = int.from_bytes(sample, byteorder='big', signed = True) - self.cal_offset
        return value

    
    def calibrate(self):
        # set sensor zero point by taking 100 samples
        value = 0
        for i in range(100):
            value += self.get_sample()
            self.time.sleep(0.01)
        average = value/100

        self.cal_offset = int(average)


    def write_config(self):
        self.config = self.config_OS << 15 | self.config_MUX << 12 | self.config_PGA << 9 | self.config_MODE << 8 | self.config_DR << 5 | self.config_COMP_POL << 4 | self.config_COMP_LAT << 3 | self.config_COMP_QUE
        #print("writing:")
        #print(format(self.config, '#018b'))
        value = list(map(int, self.config.to_bytes(2, byteorder="big")))
        #print(value)
        self.bus.write_i2c_block_data(self.dev_addr, self.CONFIG_REG_ADDR, value)

    def read_config(self):
        value = self.bus.read_i2c_block_data(self.dev_addr, self.CONFIG_REG_ADDR, 2)
        self.config = int.from_bytes(value, byteorder='big', signed=False)
        self.config_OS = (self.config & 0b1000000000000000) >> 15
        self.config_MUX = (self.config & 0b0111000000000000) >> 12
        self.config_PGA = (self.config & 0b0000111000000000) >> 9
        self.config_MODE = (self.config & 0b0000000100000000) >> 8
        self.config_DR = (self.config & 0b0000000011100000) >> 5
        self.config_COMP_MODE = (self.config & 0b0000000000010000) >> 4
        self.config_COMP_POL = (self.config & 0b0000000000001000) >> 3
        self.config_COMP_LAT = (self.config & 0b0000000000000100) >> 2
        self.config_COMP_QUE = (self.config & 0b0000000000000011)


    def update_config(self):
        self.OS = 0 # don't start a conversion
        self.write_config()
        self.read_config()

    def config_amp_gain(self, value):
        self.read_config()
        if (value == 0):
            self.config_PGA = 0b000
        elif (value == 1):
            self.config_PGA = 0b001
        elif (value == 2):
            self.config_PGA = 0b010
        elif (value == 3):
            self.config_PGA = 0b011
        elif (value == 4):
            self.config_PGA = 0b100
        elif (value == 5):
            self.config_PGA = 0b101
        elif (value == 6):
            self.config_PGA = 0b110
        elif (value == 7):
            self.config_PGA = 0b111
        else:
            print("Invalid value")
        
        self.update_config()


    def config_set_input_MUX(self, value):
        self.read_config()
        if (value == 0):
            self.config_MUX = 0b000
        elif (value == 1):
            self.config_MUX = 0b001
        elif (value == 2):
            self.config_MUX = 0b010
        elif (value == 3):
            self.config_MUX = 0b011
        elif (value == 4):
            self.config_MUX = 0b100
        elif (value == 5):
            self.config_MUX = 0b101
        elif (value == 6):
            self.config_MUX = 0b110
        elif (value == 7):
            self.config_MUX = 0b111
        else:
            print("Invalid mux configuration")
        
        self.update_config()


    def config_set_data_rate(self, value):
        self.read_config()
        if (value == 8):
            self.config_DR = 0b000
        elif (value == 16):
            self.config_DR = 0b001
        elif (value == 32):
            self.config_DR = 0b010
        elif (value == 64):
            self.config_DR = 0b011
        elif (value == 128):
            self.config_DR = 0b100
        elif (value == 250):
            self.config_DR = 0b101
        elif (value == 475):
            self.config_DR = 0b110
        elif (value == 860):
            self.config_DR = 0b111
        else:
            print("Invalid data rate configuration")
        
        self.update_config()
    
    def config_set_mode(self, mode):
        self.read_config()
        if (mode == 0):
            self.config_MODE = 0b0
        elif (mode == 1):
            self.config_MODE = 0b1
        else:
            print("Invalid mode configuration")

        self.update_config()

    def config_set_comparator_mode(self, mode):
        self.read_config()
        if (mode == 0):
            self.config_COMP_MODE = 0b0
        elif (mode == 1):
            self.config_COMP_MODE = 0b1
        else:
            print("Invalid comparator mode configuration")

        self.update_config()

    def config_set_comparator_polarity(self, mode):
        self.read_config()
        if (mode == 0):
            self.config_COMP_POL = 0b0
        elif (mode == 1):
            self.config_COMP_POL = 0b1
        else:
            print("Invalid comparator polarity configuration")

        self.update_config()
    
    def config_set_comparator_latch(self, mode):
        self.read_config()
        if (mode == 0):
            self.config_COMP_LAT = 0b0
        elif (mode == 1):
            self.config_COMP_LAT = 0b1
        else:
            print("Invalid comparator latch configuration")

        self.update_config()

    def config_set_comparator_queue(self, mode):
        self.read_config()
        if (mode == 0):
            self.config_COMP_QUE = 0b00
        elif (mode == 1):
            self.config_COMP_QUE = 0b01
        elif (mode == 2):
            self.config_COMP_QUE = 0b10
        elif (mode == 3):
            self.config_COMP_QUE = 0b11
        else:
            print("Invalid comparator queue configuration")

        self.update_config()


