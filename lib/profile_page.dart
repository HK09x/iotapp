import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iotapp/change_password_page.dart';
import 'package:iotapp/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({super.key, required this.user});

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
        title: const Text('โปรไฟล์'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.lock,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ChangePasswordPage(),
                ),
              );
            },
          ),
        ],
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
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(img),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                email,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'เบอร์โทรศัพท์: ${phoneNumber ?? 'ไม่มี'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (widget.user != null && widget.user!.uid.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: widget.user!.uid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('คัดลอก UID สำเร็จ'),
                      ),
                    );
                  }
                },
                child: Text(
                  'UID: ${widget.user?.uid}',
                  style: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                icon: const Icon(
                  Icons.edit,
                  size: 24.0,
                ),
                label: const Text('แก้ไขโปรไฟล์'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.5),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
