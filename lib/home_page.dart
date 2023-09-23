import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iotapp/add_note_page.dart';

import 'package:iotapp/main.dart';
import 'package:iotapp/note_page.dart';
import 'package:iotapp/video_page.dart';
import 'package:iotapp/video_viewer.dart';

class HomePage extends StatelessWidget {
  final User user;

  const HomePage(this.user, {super.key});
  @override
  Widget build(BuildContext context) {
    final String userUID = user.uid;
    double humidity = 0.0;
    double soilMoisture = 0.0;
    double temperature = 0.0;
    int pumpState = 0;
    int lampState = 0;
    String ip = "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Smart Farm'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          // เพิ่มปุ่ม "แสดงวิดีโอ" ที่นี่
          ElevatedButton(
            onPressed: () async {
              // ดึง URL จาก Cloud Firestore
              final snapshot = await FirebaseFirestore.instance
                  .collection('sensor_data')
                  .doc(userUID)
                  .collection('house')
                  .doc('plot')
                  .get();

              if (snapshot.exists) {
                final data = snapshot.data() as Map<String, dynamic>;
                ip = data['ip'] ?? "";

                // เช็คว่า URL มี HTTPS หรือไม่
                bool isHttps = ip.toLowerCase().startsWith("http://");
                if (!isHttps) {
                  // ถ้า URL ไม่มี HTTPS ให้แก้ไข URL เป็น HTTPS
                  ip = "http://$ip";
                }

                // เปิดหน้า VideoViewer ด้วย URL ที่ถูกแก้ไขแล้ว
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(videoUrl: ip),
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ไม่พบข้อมูล URL ใน Cloud Firestore'),
                  ),
                );
              }
            },
            child: const Text('วิดีโอ'),
          ),
          ElevatedButton(
            onPressed: () {
              // เมื่อปุ่มถูกคลิก
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddNotePage(user: user), // ส่งออบเจ็กต์ 'user' ไปที่นี่
                ),
              );
            },
            child: const Text('บันทึกข้อมูล'),
          ),
         
        ],
      ),
      body: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 20), // เพิ่มระยะห่างด้านบน

      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(userUID)
            .collection('house')
            .doc('plot')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('ไม่สามารถเชื่อมต่อข้อมูลได้');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            humidity = (data['humidity'] as num?)?.toDouble() ?? 0.0;
            soilMoisture =
                (data['soilMoisture'] as num?)?.toDouble() ?? 0.0;
            temperature =
                (data['temperature'] as num?)?.toDouble() ?? 0.0;
            pumpState = (data['pump_state'] as num?)?.toInt() ?? 0;
            lampState = (data['lamp_state'] as num?)?.toInt() ?? 0;
          }

          return Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 214, 214, 214),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: buildDataItem(
                        'ความชื้นในอากาศ',
                        '$humidity%',
                        Icons.cloud,
                      ),
                    ),
                    Expanded(
                      child: buildDataItem(
                        'ความชื้นในดิน',
                        '$soilMoisture%',
                        Icons.grass,
                      ),
                    ),
                    Expanded(
                      child: buildDataItem(
                        'อุณหภูมิ',
                        '$temperature°C',
                        Icons.thermostat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: buildPumpToggleButton(pumpState),
                    ),
                    Expanded(
                      child: buildLampToggleButton(lampState),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      // เพิ่มปุ่ม "ดูบันทึก" ที่นี่
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewNotesPage(userUid: userUID),
            ),
          );
        },
        child: const Text('ดูบันทึก'),
      ),
    ],
  ),
),

    );
  }

  Widget buildDataItem(String label, String value, IconData iconData) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 24.0,
            color: Colors.blue, // เปลี่ยนสีไอคอนตามที่คุณต้องการ
          ),
          const SizedBox(height: 8.0), // เพิ่มระยะห่างระหว่างไอคอนและข้อความ
          Text(
            label,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(value, style: const TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }

  buildPumpToggleButton(int state) {
    return GestureDetector(
      onTap: () {
        int newToggleState = state == 0 ? 1 : 0;

        FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(user.uid)
            .collection('house')
            .doc('plot')
            .update({
          'pump_state': newToggleState,
        }).then((_) {
          print('อัปเดตสถานะปั๊มน้ำสำเร็จ');
        }).catchError((error) {
          print('เกิดข้อผิดพลาดในการอัปเดตปั๊มน้ำ: $error');
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.water,
            size: 24.0,
            color: state == 1 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8.0),
          const Text(
            'ปั๊มน้ำ',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: state == 1 ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                state == 1 ? 'เปิด' : 'ปิด',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildLampToggleButton(int state) {
    return GestureDetector(
      onTap: () {
        int newToggleState = state == 0 ? 1 : 0;

        FirebaseFirestore.instance
            .collection('sensor_data')
            .doc(user.uid)
            .collection('house')
            .doc('plot')
            .update({
          'lamp_state': newToggleState,
        }).then((_) {
          print('อัปเดตสถานะหลอดไฟสำเร็จ');
        }).catchError((error) {
          print('เกิดข้อผิดพลาดในการอัปเดตหลอดไฟ: $error');
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.lightbulb,
            size: 24.0,
            color: state == 1 ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8.0),
          const Text(
            'หลอดไฟ',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              color: state == 1 ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                state == 1 ? 'เปิด' : 'ปิด',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
