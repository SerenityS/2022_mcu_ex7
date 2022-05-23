import sys
import time

import serial


class ArduinoController:
    def __init__(self):
        try:
            self.ser = serial.Serial("COM8", 9600, timeout=1)
            time.sleep(1)
        except:
            print("Not Initialized")
            sys.exit(0)

        if self.ser.readable():
            print(self.ser.readline().decode())

    def __del__(self):
        self.ser.close()

    def sendClear(self):
        self.ser.write(b"12")
        time.sleep(0.1)
        rst = self.ser.readline().decode()
        return rst

    def sendLedControl(self, val):
        self.ser.write(bytes(val, "utf-8"))
        time.sleep(0.1)
        rst = self.ser.readline().decode()
        return rst

    def sendByteLedControl(self, val):
        self.ser.write(bytes(val, "utf-8"))
        time.sleep(0.1)
        rst = self.ser.readline().decode()
        return rst

    def getHudTemp(self):
        self.ser.write(b"10")
        time.sleep(0.1)
        try:
            return self.ser.readline().decode()
        except:
            return f"0, 0"
