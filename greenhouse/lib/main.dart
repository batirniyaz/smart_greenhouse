import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Greenhouse Controller',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Color(0xFFFF4081), // Pink
        scaffoldBackgroundColor: Colors.lightBlue[50],
        textTheme: TextTheme(
          labelLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: BluetoothControllerPage(),
    );
  }
}

class BluetoothControllerPage extends StatefulWidget {
  @override
  _BluetoothControllerPageState createState() =>
      _BluetoothControllerPageState();
}

class _BluetoothControllerPageState extends State<BluetoothControllerPage> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  late BluetoothDevice _device;
  bool _connected = false;

  void _connectToDevice() {
    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      if (scanResult.device.name == 'HC-05') {
        _device = scanResult.device;
        _device.connect();
        setState(() {
          _connected = true;
        });
      }
    });
  }

  void _sendCommand(String command) async {
    if (_connected) {
      String offCommand = ''; // Define the command to turn off the device
      switch (command) {
        case 'O':
          offCommand = 'C'; // Command to close the window
          break;
        case 'M':
          offCommand = 'm'; // Command to turn off the motor
          break;
        case 'F':
          offCommand = 'f'; // Command to turn off the fan
          break;
        case 'B':
          offCommand = 'b'; // Command to turn off the bad noise
          break;
        default:
          // Handle other commands if needed
          break;
      }
      if (offCommand.isNotEmpty) {
        _device.discoverServices().then((services) {
          for (var service in services) {
            for (var characteristic in service.characteristics) {
              List<int> bytes = utf8.encode(offCommand);
              characteristic.write(bytes);
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Greenhouse Controller'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ControlButton(
              iconPath: 'assets/images/window.png',
              label: 'Window',
              onPressedOn: () {
                _sendCommand('O'); // Open the door
              },
              onPressedOff: () {
                _sendCommand('C'); // Close the door
              },
            ),
            SizedBox(height: 20),
            ControlButton(
              iconPath: 'assets/images/Motor.png',
              label: 'Motor',
              onPressedOn: () {
                _sendCommand('M'); // Turn on motor
              },
              onPressedOff: () {
                _sendCommand('m'); // Turn off motor
              },
            ),
            SizedBox(height: 20),
            ControlButton(
              iconPath: 'assets/images/fan.png',
              label: 'Fan',
              onPressedOn: () {
                _sendCommand('F'); // Turn on fan
              },
              onPressedOff: () {
                _sendCommand('f'); // Turn off fan
              },
            ),
            SizedBox(height: 20),
            ControlButton(
              iconPath: 'assets/images/noise.png',
              label: 'Bad Noise',
              onPressedOn: () {
                _sendCommand('B'); // Turn on bad noise
              },
              onPressedOff: () {
                _sendCommand('b'); // Turn off bad noise
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectToDevice,
        tooltip: 'Connect to Device',
        child: Icon(Icons.bluetooth),
      ),
      bottomSheet: Text('Powered by Aral Tech'),
    );
  }
}

class ControlButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onPressedOn;
  final VoidCallback onPressedOff;

  const ControlButton({
    required this.iconPath,
    required this.label,
    required this.onPressedOn,
    required this.onPressedOff,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.asset(
          iconPath,
          width: 64,
          height: 64,
          color: Theme.of(context).hintColor,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: onPressedOn,
              child: Text('Turn On'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPressedOff,
              child: Text('Turn Off'),
            ),
          ],
        ),
      ],
    );
  }
}
