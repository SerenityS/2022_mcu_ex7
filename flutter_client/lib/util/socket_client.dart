import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mcu_ex7/const/const.dart';

Future<String> sendClearData() async {
  Socket socket = await Socket.connect(ipAddress, port);

  String rst = "";
  socket.write("12");
  var rsts = socket.listen(
    (Uint8List data) async {
      rst = String.fromCharCodes(data);
    },
    onError: (error) {
      socket.destroy();
    },
    onDone: () {
      socket.destroy();
    },
  );
  socket.close();
  await rsts.asFuture<void>();
  return rst;
}

Future<String> sendLedData(ledNum, ledCmd, ledBrightness) async {
  Socket socket = await Socket.connect(ipAddress, port);

  String rst = "";
  socket.write("${ledNum + 1}, $ledCmd, $ledBrightness");
  var rsts = socket.listen(
    (Uint8List data) async {
      rst = String.fromCharCodes(data);
    },
    onError: (error) {
      socket.destroy();
    },
    onDone: () {
      socket.destroy();
    },
  );
  socket.close();
  await rsts.asFuture<void>();
  return rst;
}

Future<String> sendByteLedData(cmd) async {
  Socket socket = await Socket.connect(ipAddress, port);

  String rst = "";
  socket.write("11,$cmd");
  var rsts = socket.listen(
    (Uint8List data) async {
      rst = String.fromCharCodes(data);
    },
    onError: (error) {
      socket.destroy();
    },
    onDone: () {
      socket.destroy();
    },
  );
  socket.close();
  await rsts.asFuture<void>();
  return rst;
}

Future<String> getDHT11() async {
  Socket socket = await Socket.connect(ipAddress, port);

  String rst = "";
  socket.write("10");
  var rsts = socket.listen(
    (Uint8List data) async {
      rst = String.fromCharCodes(data);
    },
    onError: (error) {
      socket.destroy();
    },
    onDone: () {
      socket.destroy();
    },
  );
  socket.close();
  await rsts.asFuture<void>();
  return rst;
}
