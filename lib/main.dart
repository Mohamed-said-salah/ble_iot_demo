import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BLEPage(),
    );
  }
}

class BLEPage extends StatefulWidget {
  @override
  _BLEPageState createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  final List<BluetoothDevice> devicesList = [];

  @override
  void initState() {
    super.initState();
    requestBluetoothPermissions(); // Request permissions before scanning
  }

  void startScan() {
    // Start scanning for devices
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    // Listen to scan results
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devicesList.contains(result.device)) {
          setState(() {
            devicesList.add(result.device);
          });
        }
      }
    });
  }

  void requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      startScan(); // Proceed with scanning
    } else {
      // Handle the case when permissions are denied
      print("Bluetooth permissions are required to scan devices.");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // Discover services after connecting to the device
    List<BluetoothService> services = await device.discoverServices();
    // Handle services or characteristics if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BLE App')),
      body: devicesList.isEmpty
          ? Center(child: Text("No devices found"))
          : ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                final device = devicesList[index];
                return ListTile(
                  title: Text(
                      device.name.isNotEmpty ? device.name : "Unknown Device"),
                  subtitle: Text(device.id.toString()),
                  onTap: () => connectToDevice(device),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: startScan,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
