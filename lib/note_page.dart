import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iotapp/add_note_page.dart';
import 'package:iotapp/edit_note_page.dart';
import 'package:flutter_dropdown/flutter_dropdown.dart';

class ViewNotesPage extends StatefulWidget {
  final String userUid;

  const ViewNotesPage({Key? key, required this.userUid}) : super(key: key);

  @override
  _ViewNotesPageState createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  String? selectedHouse; // เพิ่มตัวแปรเก็บข้อมูลของโรงเรือนที่เลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกของคุณ'),
        actions: <Widget>[
          DropdownButton<String>(
            value: selectedHouse,
            onChanged: (String? newValue) {
              setState(() {
                selectedHouse = newValue;
              });
            },
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'ทั้งหมด',
                child: Text('ทั้งหมด'),
              ),
              DropdownMenuItem<String>(
                value: '1',
                child: Text('โรงเรือนที่1'),
              ),
              DropdownMenuItem<String>(
                value: '2',
                child: Text('โรงเรือนที่2'),
              ),
              DropdownMenuItem<String>(
                value: '3',
                child: Text('โรงเรือนที่3'),
              ),
              DropdownMenuItem<String>(
                value: '4',
                child: Text('โรงเรือนที่4'),
              ),
              DropdownMenuItem<String>(
                value: '5',
                child: Text('โรงเรือนที่5'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotePage(
                    userUid: widget.userUid,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: selectedHouse == null || selectedHouse == 'ทั้งหมด'
            ? FirebaseFirestore.instance
                .collection('user_notes')
                .doc(widget.userUid)
                .collection('notes')
                .orderBy('day', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('user_notes')
                .doc(widget.userUid)
                .collection('notes')
                .where('house',
                    isEqualTo: selectedHouse) // ตรวจสอบค่า 'house' ที่ถูกกรอง
                .orderBy('day', descending: true)
                .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('ยังไม่มีบันทึก'),
            );
          }

          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return Center(
              child: Text('ไม่พบบันทึกสำหรับโรงเรือนที่เลือก'),
            );
          }

          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
            itemBuilder: (BuildContext context, int index) {
              final note = notes[index];
              final day = note['day'];
              final disease = note['disease'];
              final img = note['img']; // URL ของรูปภาพ
              final house = note['house'];
              final plot = note['plot'];
              final temperature = note['temperature'];
              final humidity = note['humidity'];
              final soilMoisture = note['soil_moisture'];
              final goodVegetable = note['goodVegetable'];
              final badVegetable = note['badVegetable'];

              final formattedDate = (day as Timestamp).toDate();
              final formattedDateString =
                  "${formattedDate.day}/${formattedDate.month}/${formattedDate.year}";

              return Container(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: const Color.fromARGB(255, 126, 120, 120),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        img.isNotEmpty
                            ? Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(img),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(width: 60.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('วันที่: $formattedDateString'),
                              Text('โรคที่พบ: $disease'),
                              Text('โรงเรือนที่: $house'),
                              Text('แปลงผักที่: $plot'),
                              Text('อุณหภูมิ : $temperature (°C)'),
                              Text('ความชื้น : $humidity (%)'),
                              Text('ความชื้นในดิน : $soilMoisture (%)'),
                              Text('ผักที่ดี : $goodVegetable (ต้น)'),
                              Text('ผักที่เสีย : $badVegetable (ต้น)'),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (choice) {
                            if (choice == 'edit') {
                              // เรียกฟังก์ชันแก้ไขบันทึก
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditNotePage(
                                    userUid: widget.userUid,
                                    noteId: note.id,
                                  ),
                                ),
                              );
                            } else if (choice == 'delete') {
                              // เรียกฟังก์ชันลบบันทึก
                              _deleteNote(note.id);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return ['edit', 'delete'].map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice == 'edit'
                                    ? 'แก้ไขบันทึก'
                                    : 'ลบบันทึก'),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ฟังก์ชันลบบันทึก
  Future<void> _deleteNote(String noteId) async {
    try {
      // ลบบันทึกจาก Firestore
      await FirebaseFirestore.instance
          .collection('user_notes')
          .doc(widget.userUid)
          .collection('notes')
          .doc(noteId)
          .delete();

      // แสดงแจ้งเตือนว่าบันทึกถูกลบแล้ว
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกถูกลบแล้ว'),
        ),
      );
    } catch (error) {
      // กรณีเกิดข้อผิดพลาดในการลบ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการลบบันทึก'),
        ),
      );
    }
  }
}
