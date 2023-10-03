import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartPage extends StatelessWidget {
  final String houseName;
  final User? user;

  const ChartPage({Key? key, required this.houseName, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sensor Data Chart for $houseName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection(houseName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('ไม่พบข้อมูลเซ็นเซอร์');
          }

          final sensorData = snapshot.data!.docs;

          final List<ChartData> chartData = sensorData.map((data) {
            final humidity = (data['humidity'] as num).toDouble();
            final temperature = (data['temperature'] as num).toDouble();
            final soilMoisture = (data['soilMoisture'] as num).toDouble();
            final timestamp = data.id;

            return ChartData(
              timestamp: timestamp,
              humidity: humidity,
              temperature: temperature,
              soilMoisture: soilMoisture,
            );
          }).toList();

          return Container(
            margin: EdgeInsets.all(8.0),
            height: 300,
            width: 500,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(),
              tooltipBehavior: TooltipBehavior(
                enable: true, // เปิดใช้งาน Tooltip
              ),
              series: <ChartSeries>[
                LineSeries<ChartData, String>(
                  name: 'Humidity',
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.timestamp,
                  yValueMapper: (data, _) => data.humidity,
                  width: 2,
                  color: Colors.blue,
                ),
                LineSeries<ChartData, String>(
                  name: 'Temperature',
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.timestamp,
                  yValueMapper: (data, _) => data.temperature,
                  width: 2,
                  color: Colors.green,
                ),
                LineSeries<ChartData, String>(
                  name: 'Soil Moisture',
                  dataSource: chartData,
                  xValueMapper: (data, _) => data.timestamp,
                  yValueMapper: (data, _) => data.soilMoisture,
                  width: 2,
                  color: Colors.orange,
                ),
              ],
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                textStyle: TextStyle(fontSize: 12),
                overflowMode: LegendItemOverflowMode.wrap,
              ),
            ),
          );
        },
      ),
    );
  }
}

class ChartData {
  final String timestamp;
  final double humidity;
  final double temperature;
  final double soilMoisture;

  ChartData({
    required this.timestamp,
    required this.humidity,
    required this.temperature,
    required this.soilMoisture,
  });
}
