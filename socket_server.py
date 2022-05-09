import socket
from cgitb import enable

from arduino_controller import ArduinoController
from const import serverIp, serverPort

arduino = ArduinoController()

enabled = False

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:

    server_socket.bind((serverIp, serverPort))
    server_socket.listen()

    def sendData(msg, enabled):
        try:
            if 1 <= int(msg[0]) <= 9 and enabled == False:
                enabled = True
                rst = arduino.sendLedControl(msg)
            if int(msg[0]) == 10 and enabled == False:
                enabled = True
                rst = arduino.getHudTemp()
            print(f"arduino >> {rst}")
            client_socket.sendall(rst.encode())
            enabled = False
        except:
            pass

    while True:
        client_socket, client_addr = server_socket.accept()
        msg = client_socket.recv(1024).decode('utf-8')
        print(f"client>> {msg}")
        sendData(msg, enabled)

        client_socket.close()

