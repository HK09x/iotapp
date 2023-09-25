import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iotapp/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = '';
  String phoneNumber = '';
  String email = '';
  String img = '';

  @override
  void initState() {
    super.initState();

    fetchProfileData(widget.user).then((data) {
      setState(() {
        fullName = data['Full_Name'] ?? '';
        phoneNumber = data['Phone_Number'] ?? '';
        email = data['Email'] ?? '';
        img = data['img'] ?? '';
      });
    });
  }

  Future<Map<String, dynamic>> fetchProfileData(User? user) async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data;
    } else {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('โปรไฟล์'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue, // สีพื้นหลังสำหรับแบบ Neumorphism
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // สีเงา
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(img),
                ),
              ),
              SizedBox(height: 20),
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                email,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'เบอร์โทรศัพท์: ${phoneNumber ?? 'ไม่มี'}',
                style: TextStyle(fontSize: 18),
              ),
               SizedBox(height: 20),
                // แสดง UID ที่นี่
                Text(
                  'UID: ${widget.user?.uid}',
                  style: TextStyle(fontSize: 16),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(
                        userProfile: {
                          'Full_Name': fullName,
                          'Phone_Number': phoneNumber,
                          'Email': email,
                          'img': img,
                        },
                        user: widget.user,
                      ),
                    ),
                  ).then((updatedProfile) {
                    if (updatedProfile != null) {
                      setState(() {
                        fullName = updatedProfile['Full_Name'] ?? '';
                        phoneNumber = updatedProfile['Phone_Number'] ?? '';
                        email = updatedProfile['Email'] ?? '';
                        img = updatedProfile['img'] ?? '';
                      });
                    }
                  });
                },
                icon: Icon(
                  Icons.edit,
                  size: 24.0,
                ),
                label: Text('แก้ไขโปรไฟล์'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.5), // สีเงา
                  elevation: 5, // ความสูงของเงา
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
