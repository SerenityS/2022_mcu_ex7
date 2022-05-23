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

    # 초기화 명령 전송
    def sendClear(self):
        # 12 전송
        self.ser.write(b"12")
        time.sleep(0.1)
        rst = self.ser.readline().decode()
        return rst

    # LED 제어 명령 전송
    def sendLedControl(self, val):
        # LEDNo, On/Off, Brightness
        self.ser.write(bytes(val, "utf-8"))
        time.sleep(0.1)
        # 결괏값 받음
        rst = self.ser.readline().decode()
        return rst

    # Byte 형식 LED 제어 명령 전송
    def sendByteLedControl(self, val):
        # 11, 8Bit
        self.ser.write(bytes(val, "utf-8"))
        time.sleep(0.1)
        rst = self.ser.readline().decode()
        return rst

    # DHT11 명령 전달
    def getHudTemp(self):
        self.ser.write(b"10")
        time.sleep(0.1)
        try:
            # 정상적으로 값을 받아온 경우
            return self.ser.readline().decode()
        except:
            # 정상적으로 값을 받아오지 못한 경우
            return f"0, 0"
