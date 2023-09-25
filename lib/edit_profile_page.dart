import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  // ส่งข้อมูลโปรไฟล์ของผู้ใช้เข้ามา
  final Map<String, dynamic> userProfile;
  final User? user;

  EditProfilePage({required this.userProfile, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String? imgURL; // เพิ่มตัวแปรเก็บ URL ของรูปภาพ
  File? pickedImage; // เพิ่มตัวแปรเก็บรูปภาพที่ถูกเลือก

  @override
  void initState() {
    super.initState();

    // กำหนดค่าเริ่มต้นของ TextController จากข้อมูลโปรไฟล์ปัจจุบัน
    _fullNameController.text = widget.userProfile['Full_Name'] ?? '';
    _phoneNumberController.text = widget.userProfile['Phone_Number'] ?? '';
    _emailController.text = widget.userProfile['Email'] ?? '';
    imgURL = widget.userProfile['img']; // กำหนด URL รูปภาพเริ่มต้น
  }

  // ฟังก์ชันอัปโหลดรูปภาพ
  Future<String> _uploadImage(File imageFile) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${widget.user?.uid}')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageReference.putFile(imageFile);

    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = await downloadUrl.ref.getDownloadURL();

    // เก็บ URL ของรูปภาพลงในตัวแปร imgURL
    setState(() {
      imgURL = url;
    });

    return url;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _showImageSourceSelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกแหล่งที่มาของรูปภาพ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('Gallery');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('เลือกจากแกลเรียม'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('Camera');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('ถ่ายรูป'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(
               child: InkWell(
                onTap: () async {
                  final action = await _showImageSourceSelectionDialog();
                  if (action == 'Gallery') {
                    _pickImage();
                  } else if (action == 'Camera') {
                    _takePicture();
                  }
                },
                child: Container(
                  width: 80.0, // ปรับขนาดของปุ่มตามที่ต้องการ
                  height: 80.0,
                  decoration: const BoxDecoration(
                    color: Colors.blue, // สีพื้นหลังของปุ่ม
                    shape: BoxShape.circle, // กำหนดให้รูปร่างเป็นวงกลม
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt, // เพิ่มไอคอนตามที่คุณต้องการ
                          color: Colors.white, // สีไอคอน
                          size: 36.0, // ขนาดไอคอน
                        ),
                      ],
                    ),
                  ),
                ),
                         ),
             ),
            const Text(
              'ชื่อ:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.blue, // เพิ่มสีเพื่อทำให้ข้อความแตกต่าง
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'กรอกชื่อ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'เบอร์โทร:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.blue,
              ),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                hintText: 'กรอกเบอร์โทร',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'อีเมล:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.blue,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'กรอกอีเมล',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                // ทำการบันทึกการแก้ไขข้อมูลโปรไฟล์ลง Firebase Firestore
                final updatedProfile = {
                  'Full_Name': _fullNameController.text,
                  'Phone_Number': _phoneNumberController.text,
                  'Email': _emailController.text,
                  'img': imgURL, // เพิ่ม URL รูปภาพลงในฟิลด์ "img"
                };

                // รับ User จาก Firebase Authentication
                final User? user = widget.user;

                // นำ updatedProfile ไปบันทึกลง Firebase Firestore หรือส่งไปยัง API ของคุณ
                final String uid = user?.uid ?? '';

                // เรียกใช้ฟังก์ชัน _uploadImage เพื่ออัปโหลดรูปภาพ (ถ้ามีรูปที่ถูกเลือก)
                if (pickedImage != null) {
                  final imageUrl = await _uploadImage(pickedImage!);
                  updatedProfile['img'] =
                      imageUrl; // อัปเดต URL รูปภาพใน updatedProfile
                }

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update(updatedProfile);

                // คืนค่ากลับไปยังหน้าโปรไฟล์และส่งข้อมูลที่อัพเดตกลับไป
                Navigator.of(context).pop(updatedProfile);
              },
              child: const Text(
                'บันทึก',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 16.0),
            // ส่วนเลือกและแสดงรูปภาพ
            if (pickedImage != null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10.0), // Add rounded corners
                child: Image.file(
                  pickedImage!,
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),

           
          ],
        ),
      ),
    );
  }
}
