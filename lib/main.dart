/* import 'package:flutter/material.dart';

import 'presentation/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}  */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Bluetooth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BluetoothDevicesScreen(),
    );
  }
}

class BluetoothDevicesScreen extends StatefulWidget {
  const BluetoothDevicesScreen({super.key});

  @override
  _BluetoothDevicesScreenState createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  final List<ScanResult> scanResults = [];
  BluetoothDevice? boundDevice;
  BluetoothConnectionState? boundDeviceState;
  Timer? autoRefreshTimer;
  bool _isLoading = false;

  final String targetPlatformName = 'SOUNDPEATS Sonic';
  final String targetRemoteId = '28:52:E0:0B:92:C2';

  @override
  void initState() {
    super.initState();
    checkBluetoothAndRequestPermissions();
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> checkBluetoothAndRequestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    final bluetoothState = FlutterBluePlus.isScanningNow;

    if (!bluetoothState) {
      await FlutterBluePlus.turnOn();
    }

    final granted = await checkAndRequestPermissions();
    if (granted) {
      startScan();
      startAutoRefresh();
    } else {
      print('Permissions not granted');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    bool allGranted = statuses.values.every((status) => status == PermissionStatus.granted);
    return allGranted;
  }

  void startScan() async {
  scanResults.clear();
  try {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults.clear();
        scanResults.addAll(results);
        handleTargetDevice();
        if (boundDeviceState == BluetoothConnectionState.connected) {
          _isLoading = false;
        }
      });
    });
  } catch (e) {
    print('Error starting scan: $e');
    setState(() {
      _isLoading = false;
    });
  }
}

  void stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  void startAutoRefresh() {
  autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (boundDeviceState != BluetoothConnectionState.connected) {
      setState(() {
        _isLoading = true;
      });

      try {
        await boundDevice?.connect();
      } catch (e) {
        print('Error reconnecting to device: $e');
      } finally {
        startScan();
      }
    } else {
      setState(() {
        _isLoading = true;
      });
      startScan();
    }
  });
}


  void handleTargetDevice() {
    bool targetDeviceFound = false;

    for (var result in scanResults) {
      if (result.device.platformName == targetPlatformName &&
          result.device.remoteId.toString() == targetRemoteId) {
        bindDevice(result.device);
        targetDeviceFound = true;
        break;
      }
    }

    if (!targetDeviceFound) {
      scanResults.insert(
        0,
        ScanResult(
          device: BluetoothDevice(
            remoteId: DeviceIdentifier(targetRemoteId),
          ),
          rssi: 0,
          advertisementData: AdvertisementData(
            advName: targetPlatformName,
            appearance: null,
            txPowerLevel: null,
            connectable: true,
            manufacturerData: {},
            serviceData: {},
            serviceUuids: [],
          ),
          timeStamp: DateTime.now(),
        ),
      );
    }
    sortScanResults();
  }

  void sortScanResults() {
    scanResults.sort((a, b) {
      if (a.device.remoteId.toString() == targetRemoteId) return -1;
      if (b.device.remoteId.toString() == targetRemoteId) return 1;
      return 0;
    });
  }

  void bindDevice(BluetoothDevice device) async {
  boundDevice = device;
  try {
    setState(() {
      _isLoading = true;
    });
    await boundDevice!.connect();
    boundDevice!.connectionState.listen((state) {
      setState(() {
        boundDeviceState = state;
        _isLoading = boundDeviceState != BluetoothConnectionState.connected;
        if (boundDeviceState == BluetoothConnectionState.disconnected) {
          startScan();  // Trigger a scan when disconnected
        }
      });
      sortScanResults();
    });
  } catch (e) {
    print('Error connecting to device: $e');
    setState(() {
      _isLoading = true;  // Show loading indicator if error occurs
    });
  }
  sortScanResults();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),       
      ),


      body: Stack(
        children: [
          ListView.builder(
            itemCount: scanResults.length,
            itemBuilder: (context, index) {
              final result = scanResults[index];
              final isTargetDevice = result.device.remoteId.toString() == targetRemoteId;
              final deviceStateText = isTargetDevice
                  ? (boundDeviceState == BluetoothConnectionState.connected
                      ? 'Connected'
                      : 'Disconnected')
                  : '';
              return ListTile(
                title: Text(result.advertisementData.advName.isNotEmpty
                    ? result.advertisementData.advName
                    : result.device.platformName.isNotEmpty
                        ? result.device.platformName
                        : 'Unknown Device'),
                subtitle: Text('${result.device.remoteId} $deviceStateText'),
                trailing: Text(result.rssi.toString()),
                onTap: () async {
                  if (isTargetDevice) {
                    stopScan();
                    bindDevice(result.device);
                  }
                },
              );

            },
          ),
           if (_isLoading)
          const Positioned(
            top: 16.0,
            right: 16.0,
            child: SpinKitFadingCircle(
              color: Colors.grey,
              size: 30.0,
            ),
          ),       
        ],
      ),
    );
  }
}