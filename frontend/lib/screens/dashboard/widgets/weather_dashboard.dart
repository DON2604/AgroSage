import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final CropRecommendation cropRecommendation;
  final List<CropQueryData> queryData;
  final WeatherCondition weatherCondition;

  WeatherData({
    required this.cropRecommendation,
    required this.queryData,
    required this.weatherCondition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cropRecommendation: CropRecommendation.fromJson(json['crop_recommendation'] ?? {}),
      queryData: (json['query_data'] as List<dynamic>? ?? [])
          .map((item) => CropQueryData.fromJson(item))
          .toList(),
      weatherCondition: WeatherCondition.fromJson(json['weather_condition'] ?? {}),
    );
  }
}

class CropRecommendation {
  final List<String> harvestCrops;
  final List<String> plantationCrops;
  final String reason;

  CropRecommendation({
    required this.harvestCrops,
    required this.plantationCrops,
    required this.reason,
  });

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    return CropRecommendation(
      harvestCrops: List<String>.from(json['harvestation_crops'] ?? []),
      plantationCrops: List<String>.from(json['plantation_crops'] ?? []),
      reason: json['reason'] ?? '',
    );
  }
}

class CropQueryData {
  final String crop;
  final double value1;
  final double value2;

  CropQueryData({
    required this.crop,
    required this.value1,
    required this.value2,
  });

  factory CropQueryData.fromJson(Map<String, dynamic> json) {
    return CropQueryData(
      crop: json['crop'] ?? '',
      value1: (json['value1'] ?? 0).toDouble(),
      value2: (json['value2'] ?? 0).toDouble(),
    );
  }
}

class WeatherCondition {
  final String condition;
  final String explanation;

  WeatherCondition({
    required this.condition,
    required this.explanation,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      condition: json['description'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class RightDashboard extends StatefulWidget {
  const RightDashboard({super.key});

  @override
  State<RightDashboard> createState() => _RightDashboardState();
}

class _RightDashboardState extends State<RightDashboard> {
  bool isLoading = false;
  String? errorMessage;
  WeatherData? weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final url = Uri.parse('https://agrosage.pagekite.me/weather');
      final response = await http.get(url,headers: {
        'Accept': 'application/json',
        'User-Agent': 'PostmanRuntime/7.36.0', 
        'ngrok-skip-browser-warning': 'true', 
      },).timeout(const Duration(seconds: 100000));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch weather data: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchWeatherData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (weatherData != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color.fromARGB(245, 235, 234, 234),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Weather-Intelligence-Dashboard",
                style: GoogleFonts.barlow(fontSize: 32, color: Colors.black),
              ),
              const SizedBox(height: 15),
              _buildWeatherCard(weatherData!.weatherCondition),
              const SizedBox(height: 15),
              Text(
                "Crop Recommendations",
                style: GoogleFonts.barlow(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _buildRecommendationCard(
                          "Harvest Crops",
                          weatherData!.cropRecommendation.harvestCrops,
                          Colors.green.shade100)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildRecommendationCard(
                          "Plantation Crops",
                          weatherData!.cropRecommendation.plantationCrops,
                          Colors.amber.shade100)),
                ],
              ),
              const SizedBox(height: 15),
              _buildReasonCard(weatherData!.cropRecommendation.reason),
              const SizedBox(height: 15),
              Text(
                "Crop Performance",
                style: GoogleFonts.barlow(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 250,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: _buildCropComparisonChart(weatherData!.queryData),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text('No data available'));
    }
  }

  Widget _buildWeatherCard(WeatherCondition weather) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.orange.shade800, size: 32),
              const SizedBox(width: 10),
              Text(
                weather.condition,
                style: GoogleFonts.barlow(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            weather.explanation,
            style: GoogleFonts.barlow(
              fontSize: 14,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(String title, List<String> crops, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.barlow(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          ...crops.map((crop) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record,
                        size: 12, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      crop.substring(0, 1).toUpperCase() + crop.substring(1),
                      style: GoogleFonts.barlow(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReasonCard(String reason) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                "Recommendation Reason",
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reason,
            style: GoogleFonts.barlow(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildCropComparisonChart(List<CropQueryData> data) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= data.length || value < 0) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data[value.toInt()].crop,
                    style: GoogleFonts.barlow(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.barlow(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 20,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(
          data.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].value2,
                color: Colors.green.shade400,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}