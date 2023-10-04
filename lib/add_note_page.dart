import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddNotePage extends StatefulWidget {
  final String userUid;

  const AddNotePage({Key? key, required this.userUid}) : super(key: key);

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
  final TextEditingController _goodVegetableController = TextEditingController(); // ช่องใส่จำนวนผักที่ดี
  final TextEditingController _badVegetableController = TextEditingController(); // ช่องใส่จำนวนผักที่เสีย
  File? pickedImage;
  DateTime? selectedDate;

  void _addNote() async {
    final Timestamp dayTimestamp = selectedDate != null
        ? Timestamp.fromDate(selectedDate!)
        : Timestamp.now();
    final String disease = _diseaseController.text.trim();
    final String house = _houseController.text.trim();
    final String plot = _plotController.text.trim();
    final String temperature = _temperatureController.text.trim();
    final String humidity = _humidityController.text.trim();
    final String soilMoisture = _soilMoistureController.text.trim();
    final String goodVegetable = _goodVegetableController.text.trim(); // จำนวนผักที่ดี
    final String badVegetable = _badVegetableController.text.trim(); // จำนวนผักที่เสีย

    if (disease.isNotEmpty &&
        house.isNotEmpty &&
        plot.isNotEmpty &&
        temperature.isNotEmpty &&
        humidity.isNotEmpty &&
        soilMoisture.isNotEmpty) {
      // Upload the image (if available) to Firebase Storage
      String imageUrl = '';
      if (pickedImage != null) {
        imageUrl = await _uploadImage(pickedImage!);
      }

      // Add the note to Firestore, including the image URL
      FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.userUid)
          .collection('notes')
          .add({
        'day': dayTimestamp,
        'disease': disease,
        'img': imageUrl,
        'house': house,
        'plot': plot,
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soilMoisture,
        'goodVegetable': goodVegetable, // จำนวนผักที่ดี
        'badVegetable': badVegetable, // จำนวนผักที่เสีย
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('An error occurred while adding the note.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final storageReference = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(widget.userUid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageReference.putFile(imageFile);

    final TaskSnapshot downloadUrl = await uploadTask;
    final String url = await downloadUrl.ref.getDownloadURL();
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
        title: const Text('เพิ่มบันทึก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: const Text('วันที่'),
                subtitle: Text(selectedDate != null
                    ? "${selectedDate!.toLocal()}".split(' ')[0]
                    : 'เลือกวันที่'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context);
                },
              ),
              TextField(
                controller: _diseaseController,
                decoration: const InputDecoration(labelText: 'โรคที่พบ'),
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
                child: const Text('เลือกรูปภาพหรือถ่ายภาพ'),
              ),
              TextField(
                controller: _houseController,
                decoration: const InputDecoration(labelText: 'โรงเรือนที่'),
                onChanged: (houseName) {
                  _fetchSensorDataForHouse(houseName);
                },
              ),
              TextField(
                controller: _plotController,
                decoration: const InputDecoration(labelText: 'แปลงผักที่'),
              ),
              TextField(
                controller: _temperatureController,
                decoration: const InputDecoration(labelText: 'อุณหภูมิ (°C)'),
              ),
              TextField(
                controller: _humidityController,
                decoration: const InputDecoration(labelText: 'ความชื้น (%)'),
              ),
              TextField(
                controller: _soilMoistureController,
                decoration: const InputDecoration(labelText: 'ความชื้นในดิน (%)'),
              ),
              TextField(
                controller: _goodVegetableController, // จำนวนผักที่ดี
                decoration: const InputDecoration(labelText: 'ผักที่ดี (จำนวนต้น)'),
              ),
              TextField(
                controller: _badVegetableController, // จำนวนผักที่เสีย
                decoration: const InputDecoration(labelText: 'ผักที่เสีย (จำนวนต้น)'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addNote,
                child: const Text('บันทึก'),
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

  Future<void> _takePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchSensorDataForHouse(String houseNumber) async {
    String collectionName = '';

    // แปลงเลขที่ผู้ใช้ป้อนใน TextField เป็นชื่อ Collection
    switch (houseNumber) {
      case '1':
        collectionName = 'house0';
        break;
      case '2':
        collectionName = 'house1';
        break;
      case '3':
        collectionName = 'house2';
        break;
      case '4':
        collectionName = 'house3';
        break;
      case '5':
        collectionName = 'house4';
        break;
      // คุณอาจจะต้องเพิ่มเงื่อนไขเพิ่มเติมหากต้องการรองรับค่าเลขอื่น ๆ
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sensor_data')
          .doc(widget.userUid)
          .collection(collectionName)
          .doc('plot')
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        setState(() {
          _temperatureController.text = data['temperature'].toString();
          _humidityController.text = data['humidity'].toString();
          _soilMoistureController.text = data['soilMoisture'].toString();
        });
      }
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }
}
