import sys
import time

import serial

from const import arduinoPort


class ArduinoController:
    def __init__(self):
        try:
            # Serial Port Open
            self.ser = serial.Serial(f"COM{arduinoPort}", 9600, timeout=1)
            time.sleep(1)
        except:
            # Serial Port Open Error
            print("Not Initialized")
            sys.exit(0)

        # 정상적으로 포트 연결시 아두이노로 부터 전달 받은 "Ready" 출력
        if self.ser.readable():
            print(self.ser.readline().decode())

    def __del__(self):
        # Serial Port Close
        self.ser.close()

    # LED Control 명령 전달
    def sendLedControl(self, val):
        self.ser.write(bytes(val, "utf-8"))
        time.sleep(0.5)
        # 결괏값 해독 후 반환
        rst = self.ser.readline().decode()
        return rst

    # DHT11 명령 전달
    def getHudTemp(self):
        self.ser.write(b"10")
        time.sleep(0.5)
        try:
            # 정상적으로 값을 받아온 경우
            return self.ser.readline().decode().split(",")
        except:
            # 정상적으로 값을 받아오지 못한 경우
            return f"0, 0"
