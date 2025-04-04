import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatefulWidget {
  @override
  _LineChartWidgetState createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width:300,
      decoration:BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.circular(15)

      ),
      padding:EdgeInsets.all(2),
      child: Column(
        children: [
          Text("Field Analysis",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold)),
          LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false), // Show grid lines
                  borderData: FlBorderData(show:false), // Show border lines
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),  // (X, Y)
                        FlSpot(1, 3),
                        FlSpot(2, 2),
                        FlSpot(3, 1.5),
                        FlSpot(4, 3.5),
                        FlSpot(5, 4),
                        FlSpot(6, 3),
                      ],
                      isCurved: true, // Smooth curves
                      barWidth: 2,
                      color: Colors.green,
                      belowBarData: BarAreaData(show: true, color: const Color.fromARGB(255, 24, 116, 60).withOpacity(0.2)), // Fill area under the line
                      dotData: FlDotData(show: false), // Show dots at data points
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
     
  }
}