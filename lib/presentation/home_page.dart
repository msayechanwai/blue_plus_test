/* import 'package:blue_plus_test/presentation/bluetooth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.blue,
                  child: const Center(
                    child: Text("Bluetooth App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
                const SizedBox(height: 20,),
                Center(
                  child: ElevatedButton(
                    onPressed: ()=>controller.scanDevice(),
                      style:ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(350, 55),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      child: const Text("Scan",
                        style: TextStyle(fontSize: 18),
                      )
                    
                  ),
                ),
                const SizedBox(height: 20,),

                StreamBuilder(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); 
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(data.device.name.isNotEmpty ? data.device.name : 'Unknown Device'),
                              subtitle: Text(data.device.id.id),
                              trailing: Text(data.rssi.toString()),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text("No device found"));
                    }
                  },
                )

              ],
            ),
          );
        }),
      );
  }
}  */