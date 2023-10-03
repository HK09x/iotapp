import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iotapp/house_page.dart';
import 'package:iotapp/main.dart';

class HomePage extends StatelessWidget {
  final User? user;

  const HomePage(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const LoginPage();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('IoT Smart Farm - Home Page'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            final houseName = 'house$index';
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sensor_data')
                  .doc(user?.uid)
                  .collection(houseName)
                  .doc('plot')
                  .snapshots(),
              builder: (context, snapshot) {
                // ปรับแต่งสไตล์ Card ที่ครอบข้อมูลโรงเรือน
                return Card(
                  elevation: 5, // เพิ่มเงาให้ Card
                  margin: const EdgeInsets.all(30),
                  color: Colors.white, // สีพื้นหลังของ Card
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Center(
                      child: Text(
                        index == 0
                            ? 'โรงเรือนที่ 1'
                            : 'โรงเรือนที่ ${index + 1}',
                        style: const TextStyle(
                          color: Colors.green, // สีข้อความ
                          fontSize: 25,
                        ),
                      ),
                    ),
                    subtitle: Center(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const CircularProgressIndicator()
                          : snapshot.hasError
                              ? Text(
                                  'เกิดข้อผิดพลาด: ${snapshot.error}',
                                  style: const TextStyle(
                                    color: Colors
                                        .red, // สีข้อความเมื่อเกิดข้อผิดพลาด
                                  ),
                                )
                              : snapshot.hasData && snapshot.data!.exists
                                  ? const Text(
                                      'มีข้อมูล',
                                      style: TextStyle(
                                        color: Colors
                                            .green, // สีข้อความเมื่อมีข้อมูล
                                      ),
                                    )
                                  : const Text(
                                      'ไม่มีข้อมูล',
                                      style: TextStyle(
                                        color: Colors
                                            .red, // สีข้อความเมื่อไม่มีข้อมูล
                                      ),
                                    ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HousePage(
                            user: user,
                            houseNumber: index,
                            houseName: houseName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }
}
