import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void main() {
  runApp(const MyApp());
}

/// ***
/// No UI, run `flutter run -d windows` and result in the terminal
/// ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    // List all available ports
    List<String> availablePort = SerialPort.availablePorts;
    print('Available Ports: $availablePort');

    // Open the port
    SerialPort port1 = SerialPort('COM3');
    print('Open Port: ${port1.openReadWrite()}');

    try {
      // test command to write to the port. in this case,
      // I'm request EDC device to start received a mobile number from customer.
      Uint8List command = Uint8List.fromList([
        0x02,
        0x00,
        0x18,
        0x36,
        0x30,
        0x30,
        0x30,
        0x30,
        0x30,
        0x30,
        0x30,
        0x30,
        0x30,
        0x31,
        0x30,
        0x36,
        0x30,
        0x30,
        0x30,
        0x30,
        0x1C,
        0x03,
        0x36
      ]);

      // Write to port
      print('Written Bytes: ${port1.write(command)}');

      // Read from port
      SerialPortReader reader = SerialPortReader(port1);
      Stream<String> upcomingData = reader.stream.map((data) {
        // stream of Uint8List, handle it depend on the interfaces of target system.
        // below code assume that the binary come in ASCII data.
        return String.fromCharCodes(data);
      });

      upcomingData.listen((data) {
        print('Read Data: $data');
      });
    } on SerialPortError catch (err, _) {
      print(SerialPort.lastError);
      port1.close();
    }

    return Container();
  }
}

int _calculateLRC(Uint8List data) {
  var value = -1;

  for (var element in data) {
    if (value == -1) {
      value = element;
      continue;
    }
    value ^= element;
  }

  return value;
}
