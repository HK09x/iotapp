import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNotePage extends StatefulWidget {
  final String userUid;
  final String noteId;

  EditNotePage({required this.userUid, required this.noteId});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _diseaseController = TextEditingController();
  TextEditingController _houseController = TextEditingController();
  TextEditingController _plotController = TextEditingController();
  TextEditingController _temperatureController = TextEditingController();
  TextEditingController _humidityController = TextEditingController();
  TextEditingController _soilMoistureController = TextEditingController();

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขบันทึก'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _diseaseController,
                decoration: InputDecoration(labelText: 'โรคที่พบ'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกโรคที่พบ';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _houseController,
                decoration: InputDecoration(labelText: 'โรงเรือนที่'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกโรงเรือนที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _plotController,
                decoration: InputDecoration(labelText: 'แปลงผักที่'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกแปลงผักที่';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(labelText: 'อุณหภูมิ (°C)'),
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
                decoration: InputDecoration(labelText: 'ความชื้น (%)'),
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
                decoration: InputDecoration(labelText: 'ความชื้นในดิน (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'กรุณากรอกความชื้นในดิน';
                  }
                  // เพิ่มเงื่อนไขตรวจสอบความชื้นในดินตามความเหมาะสม
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
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
                        SnackBar(
                          content: Text('บันทึกถูกอัปเดตแล้ว'),
                        ),
                      );

                      // ย้อนกลับไปยังหน้าแสดงบันทึกหลัก (ViewNotesPage)
                      Navigator.pop(context);
                    }).catchError((error) {
                      // กรณีเกิดข้อผิดพลาดในการอัปเดตข้อมูล
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เกิดข้อผิดพลาดในการอัปเดตข้อมูล'),
                        ),
                      );
                    });
                  }
                },
                child: Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
