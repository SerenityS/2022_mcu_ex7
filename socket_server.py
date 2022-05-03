import asyncio

import websockets

from arduino_controller import ArduinoController

arduino = ArduinoController()

async def echo(websocket):
    async for message in websocket:
        message = int(message)
        if 1 <= message <= 8:
            rst = arduino.send_msg(message)
            await websocket.send(rst)
        if message == 9:
            rst = arduino.get_hud_temp()
            print(rst)
            await websocket.send(rst)

async def main():
    async with websockets.serve(echo, "localhost", 8765):
        await asyncio.Future()

asyncio.run(main())
