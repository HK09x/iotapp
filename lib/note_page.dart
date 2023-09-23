import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewNotesPage extends StatefulWidget {
  final String userUid;

  const ViewNotesPage({Key? key, required this.userUid});

  @override
  _ViewNotesPageState createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกของคุณ'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_notes')
            .doc(widget.userUid)
            .collection('notes')
            .orderBy('day', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final notes = snapshot.data!.docs;

          if (notes.isEmpty) {
            return Center(
              child: Text('ยังไม่มีบันทึก'),
            );
          }

          return ListView.separated(
            itemCount: notes.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
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

              final formattedDate = (day as Timestamp).toDate();
              final formattedDateString =
                  "${formattedDate.day}/${formattedDate.month}/${formattedDate.year}";

              return Container(
  padding: EdgeInsets.all(8.0),
  child: Card(
    color: Color.fromARGB(255, 126, 120, 120),
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
              : SizedBox(),
          SizedBox(width: 60.0),
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
              ],
            ),
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
}
