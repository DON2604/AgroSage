import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DynamicDataCard extends StatefulWidget {
  const DynamicDataCard({Key? key}) : super(key: key);

  @override
  _DynamicDataCardState createState() => _DynamicDataCardState();
}

class _DynamicDataCardState extends State<DynamicDataCard> {
  late Timer _timer;
  double soilMoisture = 65.0;
  double temperature = 24.5;
  double humidity = 78.0;
  double soilPH = 6.8;
  double lightIntensity = 82.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // Add slight random variations to simulate changing data
        soilMoisture = _updateValue(soilMoisture, 50.0, 80.0);
        temperature = _updateValue(temperature, 20.0, 30.0);
        humidity = _updateValue(humidity, 65.0, 90.0);
        soilPH = _updateValue(soilPH, 6.0, 7.5);
        lightIntensity = _updateValue(lightIntensity, 70.0, 95.0);
      });
    });
  }

  double _updateValue(double current, double min, double max) {
    final change = (Random().nextDouble() * 2 - 1) * 2; // Between -2 and 2
    final newValue = current + change;
    return newValue.clamp(min, max);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Farm Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF225500),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Live Data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 175, // Adjust this height value as needed
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5, // Adjust this value to make cards wider or narrower
                shrinkWrap: true, // Makes grid take only the space it needs
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCompactMetricCard(
                    'Soil Moisture',
                    '${soilMoisture.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    Colors.blue,
                    _getStatusColor(soilMoisture, 60, 75),
                  ),
                  _buildCompactMetricCard(
                    'Temperature',
                    '${temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                    _getStatusColor(temperature, 22, 28),
                  ),
                  _buildCompactMetricCard(
                    'Humidity',
                    '${humidity.toStringAsFixed(1)}%',
                    Icons.cloud,
                    Colors.lightBlue,
                    _getStatusColor(humidity, 70, 85),
                  ),
                  _buildCompactMetricCard(
                    'Soil pH',
                    soilPH.toStringAsFixed(1),
                    Icons.science,
                    Colors.purple,
                    _getStatusColor(soilPH, 6.5, 7.2),
                  ),
                  _buildCompactMetricCard(
                    'Light',
                    '${lightIntensity.toStringAsFixed(1)}%',
                    Icons.wb_sunny,
                    Colors.amber,
                    _getStatusColor(lightIntensity, 75, 90),
                  ),
                  _buildRecommendationsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(double value, double min, double max) {
    if (value < min) return Colors.red;
    if (value > max) return Colors.orange;
    return Colors.green;
  }

  Widget _buildCompactMetricCard(String title, String value, IconData icon, Color iconColor, Color statusColor) {
    return Container(
      height: 60, // Set explicit height for metric cards
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      height: 60, // Set explicit height for recommendation card
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Recommendation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF616161),
                    ),
                  ),
                  Text(
                    soilMoisture < 60 ? 'Increase irrigation' : 'Optimal conditions',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
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
