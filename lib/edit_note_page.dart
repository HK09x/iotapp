import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditNotePage extends StatefulWidget {
  final String userUid;
  final String noteId;

  const EditNotePage({super.key, required this.userUid, required this.noteId});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _soilMoistureController = TextEditingController();
  XFile? _pickedImage; // เปลี่ยนจาก File เป็น XFile สำหรับ ImagePicker
  String? _currentImageUrl; // เก็บ URL รูปภาพปัจจุบัน

  @override
  void initState() {
    super.initState();

    // ดึงข้อมูลบันทึกที่ต้องการแก้ไขจาก Firestore
    FirebaseFirestore.instance
        .collection('user_notes')
        .doc(widget.userUid)
        .collection('notes')
        .doc(widget.noteId)
        .get()
        .then((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // ตั้งค่าคอนโทรลเลอร์ให้มีค่าเริ่มต้นจากข้อมูลบันทึก
        _diseaseController.text = data['disease'];
        _houseController.text = data['house'];
        _plotController.text = data['plot'];
        _temperatureController.text = data['temperature'].toString();
        _humidityController.text = data['humidity'].toString();
        _soilMoistureController.text = data['soil_moisture'].toString();

        // กำหนดค่า _currentImageUrl ให้มีค่าเท่ากับ URL ปัจจุบัน
        _currentImageUrl = data['img'];
      }
    });
  }

  // ฟังก์ชันอัปโหลดรูปภาพ
  Future<String> _uploadImage(XFile imageFile) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${widget.userUid}')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask =
        storageReference.putFile(File(imageFile.path));

    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = await downloadUrl.ref.getDownloadURL();

    return url;
  }

  // ฟังก์ชันอัปโหลดและอัปเดตรูปภาพ
  Future<void> _uploadAndReplaceImage(XFile imageFile) async {
    // ตรวจสอบว่ามีรูปภาพที่ถูกเลือกหรือไม่
    if (imageFile != null) {
      // อัปโหลดรูปภาพที่ถูกเลือกไปยัง Firebase Storage
      final imageUrl = await _uploadImage(imageFile);

      // อัปเดตข้อมูลใน Firestore โดยใช้ URL ของรูปภาพใหม่
      FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.userUid)
          .collection('notes')
          .doc(widget.noteId)
          .update({'img': imageUrl}).then((_) {
        // แสดงแจ้งเตือนหรือทำอย่างอื่นตามที่คุณต้องการ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รูปภาพถูกบันทึกแล้ว'),
          ),
        );
      }).catchError((error) {
        // กรณีเกิดข้อผิดพลาดในการอัปเดตข้อมูล
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $error'),
          ),
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera); // ถ่ายรูป

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขบันทึก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _diseaseController,
                decoration: const InputDecoration(labelText: 'โรคที่พบ'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกโรคที่พบ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _houseController,
                decoration: const InputDecoration(labelText: 'โรงเรือนที่'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกโรงเรือนที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _plotController,
                decoration: const InputDecoration(labelText: 'แปลงผักที่'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกแปลงผักที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _temperatureController,
                decoration: const InputDecoration(labelText: 'อุณหภูมิ (°C)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกอุณหภูมิ';
                  }
                  // เพิ่มเงื่อนไขตรวจสอบอุณหภูมิตามความเหมาะสม
                  return null;
                },
              ),
              TextFormField(
                controller: _humidityController,
                decoration: const InputDecoration(labelText: 'ความชื้น (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกความชื้น';
                  }
                  // เพิ่มเงื่อนไขตรวจสอบความชื้นตามความเหมาะสม
                  return null;
                },
              ),
              TextFormField(
                controller: _soilMoistureController,
                decoration: const InputDecoration(labelText: 'ความชื้นในดิน (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกความชื้นในดิน';
                  }
                  // เพิ่มเงื่อนไขตรวจสอบความชื้นในดินตามความเหมาะสม
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // อัปเดตข้อมูลบันทึกเมื่อผู้ใช้กด "บันทึก"
                    final updatedData = {
                      'disease': _diseaseController.text,
                      'house': _houseController.text,
                      'plot': _plotController.text,
                      'temperature': double.parse(_temperatureController.text),
                      'humidity': double.parse(_humidityController.text),
                      'soil_moisture': double.parse(_soilMoistureController.text),
                    };

                    // บันทึกข้อมูลอัปเดตลงใน Firestore
                    FirebaseFirestore.instance
                        .collection('user_notes')
                        .doc(widget.userUid)
                        .collection('notes')
                        .doc(widget.noteId)
                        .update(updatedData)
                        .then((_) {
                      // แสดงแจ้งเตือนว่าข้อมูลถูกอัปเดต
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('บันทึกถูกอัปเดตแล้ว'),
                        ),
                      );

                      // ตรวจสอบว่ามีรูปภาพถูกเลือกหรือไม่ก่อนอัปโหลด
                      if (_pickedImage != null) {
                        _uploadAndReplaceImage(_pickedImage!);
                      }

                      // ย้อนกลับไปยังหน้าแสดงบันทึกหลัก (ViewNotesPage)
                      Navigator.pop(context);
                    }).catchError((error) {
                      // กรณีเกิดข้อผิดพลาดในการอัปเดตข้อมูล
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $error'),
                        ),
                      );
                    });
                  }
                },
                child: const Text('บันทึก'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final action = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('เลือกแหล่งที่มาของรูปภาพ'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('แก้ไขรูปภาพจากอัลบั้ม'),
                              onTap: () {
                                Navigator.pop(context, 'Gallery');
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera),
                              title: const Text('ถ่ายรูปภาพ'),
                              onTap: () {
                                Navigator.pop(context, 'Camera');
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (action == 'Gallery') {
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    // เพิ่มโค้ดเพื่อใช้รูปภาพที่ถูกเลือก
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = pickedFile;
                      });
                    }
                  } else if (action == 'Camera') {
                    final pickedFile =
                        await picker.pickImage(source: ImageSource.camera);
                    // เพิ่มโค้ดเพื่อใช้รูปภาพที่ถ่าย
                    if (pickedFile != null) {
                      setState(() {
                        _pickedImage = pickedFile;
                      });
                    }
                  }
                },
                icon: const Icon(
                  Icons.photo_camera,
                  size: 24.0,
                ),
                label: const Text('แก้ไขหรือถ่ายรูปภาพ'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey.withOpacity(0.5),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 16.0),
              if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                Image.network(_currentImageUrl!),
            ],
          ),
        ),
      ),
    );
  }
}
