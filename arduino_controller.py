import sys
import time

import serial


class ArduinoController:
    def __init__(self):
        try:
            self.ser = serial.Serial('COM3', 9600, timeout=1)
            time.sleep(1)
        except:
            print("Not Initialized")
            sys.exit(0)

        if self.ser.readable():
            print(self.ser.readline().decode())

    def __del__(self):
        self.ser.close()

    def send_msg(self, val):
        val = str(int(val) + 1)
        self.ser.write(bytes(val, 'utf-8'))
        time.sleep(1)
        rst = self.ser.readline().decode()

        return rst

    def get_hud_temp(self):
        self.ser.write(b'10')
        time.sleep(1)
        try:
            temp, hud = self.ser.readline().decode().split(",")
        except:
            return f"DHT11 is not Initialized"
        return f"Temp = {temp}, Humidity = {hud}"
        
