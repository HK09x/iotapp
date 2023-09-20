import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddNotePage extends StatefulWidget {
  final User user; // เพิ่มบรรทัดนี้เพื่อรับออบเจ็กต์ 'user'

  AddNotePage({required this.user}); // เพิ่มคอนสตรักเตอร์นี้

  @override
  _AddNotePageState createState() => _AddNotePageState();
}


class _AddNotePageState extends State<AddNotePage> {
  
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _soilMoistureController = TextEditingController();
  File? pickedImage;

  DateTime? selectedDate; // เพิ่มตัวแปรเก็บวันที่ที่เลือก

  void _addNote() {
    final String day = selectedDate != null ? selectedDate.toString() : '';
    final String disease = _diseaseController.text.trim();
    final String house = _houseController.text.trim();
    final String plot = _plotController.text.trim();
    final String temperature = _temperatureController.text.trim();
    final String humidity = _humidityController.text.trim();
    final String soil_moisture = _soilMoistureController.text.trim();
    if (day.isNotEmpty &&
        disease.isNotEmpty &&
        house.isNotEmpty &&
        plot.isNotEmpty &&
        temperature.isNotEmpty &&
        humidity.isNotEmpty &&
        soil_moisture.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.user.uid) // ใช้ widget.user.uid ในการเข้าถึง UID ของผู้ใช้
          .collection('notes')
          .add({
        'day': day,
        'disease': disease,
        'img': pickedImage != null ? pickedImage!.path : '',
        'house': house,
        'plot': plot,
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soil_moisture,
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while adding the note.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มบันทึก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text('วันที่'),
                subtitle: Text(selectedDate != null
                    ? "${selectedDate!.toLocal()}".split(' ')[0]
                    : 'เลือกวันที่'),
                trailing: Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context);
                },
              ),
              TextField(
                controller: _diseaseController,
                decoration: InputDecoration(labelText: 'โรคที่พบ'),
              ),
              if (pickedImage != null)
                Image.file(
                  pickedImage!,
                  width: 200.0,
                  height: 200.0,
                ),
              ElevatedButton(
                onPressed: () async {
                  final action = await _showImageSourceSelectionDialog();
                  if (action == 'Gallery') {
                    _pickImage();
                  } else if (action == 'Camera') {
                    _takePicture();
                  }
                },
                child: Text('เลือกรูปภาพหรือถ่ายภาพ'),
              ),
              TextField(
                controller: _houseController,
                decoration: InputDecoration(labelText: 'โรงเรือนที่'),
              ),
              TextField(
                controller: _plotController,
                decoration: InputDecoration(labelText: 'แปลงผักที่'),
              ),
              TextField(
                controller: _temperatureController,
                decoration: InputDecoration(labelText: 'อุณหภูมิ (°C)'),
              ),
              TextField(
                controller: _humidityController,
                decoration: InputDecoration(labelText: 'ความชื้น (%)'),
              ),
              TextField(
                controller: _soilMoistureController,
                decoration: InputDecoration(labelText: 'ความชื้นในดิน (%)'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addNote,
                child: Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showImageSourceSelectionDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกแหล่งที่มาของรูปภาพ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('Gallery');
                  },
                  child: ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('เลือกจากแกลเรียม'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop('Camera');
                  },
                  child: ListTile(
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

  Future<void> _takePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }
}