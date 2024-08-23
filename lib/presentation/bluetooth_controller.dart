import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class BluetoothController extends GetxController {
  final scanResults = <ScanResult>[].obs;

  Future<void> scanDevice() async {
    try {
      // Check for location services
      if (!(await Geolocator.isLocationServiceEnabled())) {
        print("Location services are disabled.");
        return;
      }

      // Check for location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print('Location permissions are permanently denied');
          return;
        }
      }

      // Check if Bluetooth is enabled
      if (await FlutterBluePlus.isOn) {
        // Start scanning with a timeout of 5 seconds
        FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

        // Listen for scan results and update the observable list
        FlutterBluePlus.scanResults.listen((results) {
          scanResults.assignAll(results); // Update scan results
        });
      } else {
        print("Bluetooth is not turned on.");
      }
    } catch (e) {
      print("Error during scanning: $e");
    } finally {
      FlutterBluePlus.stopScan();
    }
  }
}
