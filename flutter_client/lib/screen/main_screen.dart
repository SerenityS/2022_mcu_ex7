import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcu_ex7/const/const.dart';
import 'package:mcu_ex7/const/theme_data.dart';
import 'package:mcu_ex7/dht11_data.dart';
import 'package:mcu_ex7/util/socket_client.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<int> colorIndex = [3, 2, 3, 1, 3, 2, 3, 1];

  List<double> brightnessSliderValue = [255, 255, 255, 255, 255, 255, 255, 255];
  List<bool> ledStatus = [true, true, true, true, true, true, true, true];

  int chartIndex = 0;
  List<DHT11Data> dht11ChartValue = [];
  List<double> dht11Value = [0, 0];
  Timer? refreshDHT11Time;

  final TextEditingController _ipTextController = TextEditingController();
  final TextEditingController _portTextController = TextEditingController();
  final TextEditingController _byteTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setDHT11();
    refreshDHT11Time =
        Timer.periodic(const Duration(seconds: 5), (Timer t) => setDHT11());
  }

  @override
  void dispose() {
    super.dispose();
    refreshDHT11Time?.cancel();
  }

  void setDHT11() async {
    var values = await getDHT11();
    var splitValues = values.split(',');
    dht11Value[0] = double.parse(splitValues[0]);
    dht11Value[1] = double.parse(splitValues[1]);
    dht11ChartValue.add(DHT11Data((chartIndex++).toString(),
        double.parse(splitValues[0]), double.parse(splitValues[1])));
    if (dht11ChartValue.length == 11) dht11ChartValue.removeAt(0);
    setState(() {});
  }

  void changeIpPortDialog() async {
    _ipTextController.text = ipAddress;
    _portTextController.text = port.toString();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            title: const Text("Change IP / Port"),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _ipTextController,
                  decoration: const InputDecoration(hintText: 'IP'),
                ),
                TextField(
                  controller: _portTextController,
                  decoration: const InputDecoration(hintText: 'PORT'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  "확인",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  ipAddress = _ipTextController.text;
                  port = int.parse(_portTextController.text);
                  Get.back();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LED & DHT11 Control"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              String rst = await sendClearData();
              setState(() {
                if (rst == "Clear") {
                  ledStatus = [true, true, true, true, true, true, true, true];
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              changeIpPortDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    title: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.10,
                                  child: Image.asset(
                                      'assets/icon/thermometer.png')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${dht11Value[0].toString()} °C",
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.10,
                                  child: Image.asset(
                                      'assets/icon/hygrometer.png')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${dht11Value[1].toString()} %",
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    children: [
                      SfCartesianChart(
                          title: ChartTitle(
                              text: 'Temperature',
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          primaryXAxis: CategoryAxis(),
                          series: <LineSeries<DHT11Data, String>>[
                            LineSeries<DHT11Data, String>(
                                dataSource: dht11ChartValue,
                                xValueMapper: (DHT11Data value, _) =>
                                    value.index,
                                yValueMapper: (DHT11Data value, _) =>
                                    value.tempValue)
                          ]),
                      SfCartesianChart(
                          title: ChartTitle(
                              text: 'Humidity',
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          primaryXAxis: CategoryAxis(),
                          series: <LineSeries<DHT11Data, String>>[
                            LineSeries<DHT11Data, String>(
                                dataSource: dht11ChartValue,
                                xValueMapper: (DHT11Data value, _) =>
                                    value.index,
                                yValueMapper: (DHT11Data value, _) =>
                                    value.hudvalue)
                          ])
                    ],
                  ),
                ),
                for (int i = 0; i < 8; i++)
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: ledStatus[i]
                                ? GradientTemplate
                                    .gradientTemplate[colorIndex[i]].colors
                                : GradientTemplate.gradientTemplate[0].colors,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                      ),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "LED ${i + 1}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.white70),
                                onPressed: () async {
                                  var cmd = !ledStatus[i] ? 1 : 0;
                                  String rst = await sendLedData(
                                      i + 1, cmd, brightnessSliderValue[i]);
                                  setState(
                                    () {
                                      if (rst == "ON") {
                                        ledStatus[i] = true;
                                      } else if (rst == "OFF") {
                                        ledStatus[i] = false;
                                      }
                                    },
                                  );
                                },
                                child: !ledStatus[i]
                                    ? const Text(
                                        "ON",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : const Text(
                                        "OFF",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          const Text(
                            "Brightness",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                            child: Slider(
                                activeColor: Colors.black54,
                                inactiveColor: Colors.black12,
                                thumbColor: Colors.black,
                                value: brightnessSliderValue[i],
                                label:
                                    brightnessSliderValue[i].round().toString(),
                                max: 255,
                                divisions: 255,
                                onChanged: (double value) {
                                  setState(() {
                                    brightnessSliderValue[i] = value;
                                  });
                                }),
                          ),
                        ],
                        trailing: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Byte Control",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextField(
                          controller: _byteTextController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            String rst =
                                await sendByteLedData(_byteTextController.text);
                            setState(() {
                              for (int i = 0; i < 8; i++) {
                                if (rst[i] == '0') {
                                  ledStatus[i] = false;
                                } else {
                                  ledStatus[i] = true;
                                }
                              }
                            });
                          },
                          child: const Text("Send"),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
