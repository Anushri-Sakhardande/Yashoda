import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HealthLineChart extends StatefulWidget {
  final String userId;

  HealthLineChart({required this.userId});

  @override
  _HealthLineChartState createState() => _HealthLineChartState();
}

class _HealthLineChartState extends State<HealthLineChart> {
  String selectedParameter = "weight";
  List<String> parameterOptions = ["weight", "hemoglobin", "bloodPressure"];
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  void fetchEntries() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection("healthStatusEntries")
        .orderBy("lastUpdated")
        .get();

    final docs = snapshot.docs.map((doc) {
      return {
        "lastUpdated": (doc["lastUpdated"] as Timestamp).toDate(),
        "weight": doc.data()["weight"],
        "hemoglobin": doc.data()["hemoglobin"],
        "bloodPressure": doc.data()["bloodPressure"]
      };
    }).toList();

    setState(() {
      entries = docs;
    });
  }

  List<FlSpot> getChartData() {
    List<FlSpot> spots = [];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final dynamic value = entry[selectedParameter];

      // Convert string BP to numeric avg (e.g., "120/80" => 100)
      double yValue = 0;
      if (value is int || value is double) {
        yValue = value.toDouble();
      } else if (selectedParameter == "bloodPressure" && value is String) {
        final parts = value.split("/");
        if (parts.length == 2) {
          yValue = (int.parse(parts[0]) + int.parse(parts[1])) / 2.0;
        }
      }

      spots.add(FlSpot(i.toDouble(), yValue));
    }
    return spots;
  }

  List<String> getDates() {
    return entries.map((e) => DateFormat('dd MMM').format(e["lastUpdated"])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown to select health parameter
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: selectedParameter,
            items: parameterOptions.map((String param) {
              return DropdownMenuItem<String>(
                value: param,
                child: Text(param),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedParameter = newValue!;
              });
            },
          ),
        ),
        if (entries.isEmpty)
          Center(child: CircularProgressIndicator())
        else
          AspectRatio(
            aspectRatio: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < getDates().length) {
                            return Text(getDates()[index], style: TextStyle(fontSize: 10));
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: getChartData(),
                      isCurved: true,
                      barWidth: 2,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
