import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'devices.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'dart:convert' show utf8;
import 'dart:convert' show AsciiDecoder;
import 'dart:convert' show base64;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  bool connected = false;
  BluetoothDevice? results;
  List<BluetoothService> services = <BluetoothService>[];
  List<BluetoothDevice> _connectedDevice = <BluetoothDevice>[];
  String bpm = "";
  int BPM = 87;
  final asciidecoder = AsciiDecoder();

  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 150,
            left: 60,
            child: Text(
              "Your BPM : ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
            ),
          ),
          Positioned(
            top: 350,
            left: 140,
            child: Text(
              BPM.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 100,
                //decoration: TextDecoration.underline,
              ),
            ),
          ),
          Positioned(
            top: 650,
            left: 150,
            child: FloatingActionButton.extended(
                label: Text("Refresh"),
                backgroundColor: Colors.black,
                onPressed: () async {
                  if (connected == true) {
                    for (BluetoothService service in services) {
                      for (BluetoothCharacteristic characteristic
                          in service.characteristics) {
                        if (characteristic.properties.notify) {
                          await characteristic.setNotifyValue(true);
                          characteristic.value.listen((value) {
                            //const asciiDecoder = AsciiDecoder();
                            //debugPrint("Value: " + value.toString());
                            bpm = (utf8.decode(value));
                            if (bpm != null && bpm.length > 0) {
                              debugPrint("bite");
                              setState(() {
                                BPM = bpm.characters.first.codeUnitAt(0);
                              });
                            }
                            //String c = bpm[0];
                            //debugPrint("c:" + c);

                            debugPrint("BPM: " + BPM.toString());
                            //debugPrint("BPM: " + BPM.toString());
                          });
                        }
                      }
                    }
                  }
                }),
          ),
          Positioned(
              top: 750,
              left: 90,
              child: FloatingActionButton.extended(
                  label: Text('Connect to your sensor.'),
                  backgroundColor: Colors.black,
                  heroTag: 'connect',
                  onPressed: () async {
                    bool permGranted = true;

                    if (await Nearby().checkBluetoothPermission()) {
                    } else {
                      permGranted = false;
                      Nearby().askBluetoothPermission();
                      if (await Nearby().checkBluetoothPermission()) {
                        permGranted = true;
                      }
                    }
                    if (connected == false && permGranted == true) {
                      results = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MyHomePage(title: "oui oui baguette !")));
                    }
                    if (results != null) {
                      connected = true;
                      services = await results!.discoverServices();

                      setState(() {
                        _connectedDevice.add(results!);
                      });
                    }
                  })),
        ],
      ),
    )));
  }
}

int asciiToDecimal(String asciiChar) {
  int decimalValue =
      asciiChar.codeUnitAt(0); // get the ASCII code for the character
  return decimalValue;
}
