import 'package:flutter/material.dart';
import 'dart:math';

class HealthStatusCircle extends StatelessWidget {
  final Map<String, dynamic> healthData;
  final String centerText;

  HealthStatusCircle({required this.healthData, required this.centerText});

  @override
  Widget build(BuildContext context) {
    double radius = 100; // Adjusted radius for better spacing
    double textOffset=15;

    // Remove "userId" from displayed data
    Map<String, dynamic> filteredData = Map.from(healthData)..remove("userId");
    filteredData.remove("lastUpdated");
    List<String> keys = filteredData.keys.toList();

    return Center(
      child: SizedBox(
        width: radius * 3.5, // Enough space for text labels
        height: radius * 3,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Central Circle
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellowAccent.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  centerText,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Surrounding Health Status Items
            for (int i = 0; i < keys.length; i++)
              Positioned(
                left: radius + (radius+textOffset)  * cos((i / keys.length) * 2 * pi) +40,
                top: radius + (radius+textOffset)  * sin((i / keys.length) * 2 * pi) +35 ,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 12, color: Colors.orange),
                    SizedBox(height: 8),
                    Container(
                      constraints: BoxConstraints(maxWidth: 100), // Prevent text overflow
                      child: Text(
                        keys[i], // Display health attribute (e.g., weight, blood pressure)
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Text(
                      filteredData[keys[i]].toString(), // Display corresponding value
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
