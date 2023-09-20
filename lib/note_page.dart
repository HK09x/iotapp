import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewNotesPage extends StatefulWidget {
  @override
  _ViewNotesPageState createState() => _ViewNotesPageState();
}

class _ViewNotesPageState extends State<ViewNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ดูบันทึก'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_notes')
            .doc('YOUR_USER_UID')
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
          List<Widget> noteWidgets = [];
          for (var note in notes) {
            final day = note['day'];
            final disease = note['disease'];
            final img = note['img'];
            final house = note['house'];
            final plot = note['plot'];
            final temperature = note['temperature'];
            final humidity = note['humidity'];
            final soilMoisture = note['soil_moisture'];

            final noteWidget = ListTile(
              title: Text('วันที่: $day'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('โรคที่พบ: $disease'),
                  Text('โรงเรือนที่: $house'),
                  Text('แปลงผักที่: $plot'),
                  Text('อุณหภูมิ (°C): $temperature'),
                  Text('ความชื้น (%): $humidity'),
                  Text('ความชื้นในดิน (%): $soilMoisture'),
                ],
              ),
              leading: img.isNotEmpty ? Image.network(img) : SizedBox(),
            );
            noteWidgets.add(noteWidget);
          }

          return ListView(
            children: noteWidgets,
          );
        },
      ),
    );
  }
}
