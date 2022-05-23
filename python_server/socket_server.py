import socket

from arduino_controller import ArduinoController
from const import serverIp, serverPort

# 아두이노 컨트롤러 객체 선언
arduino = ArduinoController()

# Race Condition 방지를 위한 Flaga
enabled = False

# Socket Stream Open
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
    server_socket.bind((serverIp, serverPort))
    server_socket.listen()

    # 클라이언트(PC, Android)에서 소켓 통신을 통해 전달 받은 명령어 실행
    def sendCmd(cmd, enabled):
        try:
            # 명령어가 2 ~ 9인 경우
            # 2 ~ 9(Pin No) == 1 ~ 8(LED No)
            if 2 <= int(cmd[0]) <= 9 and enabled == False:
                enabled = True
                rst = arduino.sendLedControl(cmd)
            # 명령어가 10인 경우
            # DHT11에서 정보 받아옴
            elif int(cmd[0:2]) == 10 and enabled == False:
                enabled = True
                rst = arduino.getHudTemp()
            elif int(cmd[0:2]) == 11 and enabled == False:
                enabled = True
                rst = arduino.sendByteLedControl(f"11,{int(cmd[3:]):08b}")
            elif int(cmd[0:2]) == 12 and enabled == False:
                enabled = True
                rst = arduino.sendClear()
            # 아두이노 시리얼 통신으로 전달받은 결괏값 출력
            print(f"arduino >> {rst}")
            # 결과값을 소켓 통신을 통해 클라이언트에 전송
            client_socket.sendall(rst.encode())
            enabled = False
        except:
            pass

    # 소켓 통신 대기
    while True:
        client_socket, client_addr = server_socket.accept()
        # 클라이언트로부터 전달 받은 명령어 해독
        cmd = client_socket.recv(1024).decode("utf-8")
        # 명령어 출력
        print(f"client>> {cmd}")
        # 아두이노로 명령어 전달
        sendCmd(cmd, enabled)
        # 클라이언트 소켓 닫음
        client_socket.close()
