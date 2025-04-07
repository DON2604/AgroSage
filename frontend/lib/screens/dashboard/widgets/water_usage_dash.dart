import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaterUsageDashboard extends StatefulWidget {
  const WaterUsageDashboard({super.key});

  @override
  State<WaterUsageDashboard> createState() => _WaterUsageDashboardState();
}

class _WaterUsageDashboardState extends State<WaterUsageDashboard> {
  bool isLoading = false;
  String? errorMessage;
  WaterUsageData? waterUsageData;

  @override
  void initState() {
    super.initState();
    _fetchWaterUsageData();
  }

  Future<void> _fetchWaterUsageData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://1028-45-112-68-8.ngrok-free.app/water-usage'),headers: {
        'Accept': 'application/json',
        'User-Agent': 'PostmanRuntime/7.36.0', 
        'ngrok-skip-browser-warning': 'true',
      },)
          .timeout(const Duration(seconds: 100000));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          waterUsageData = WaterUsageData.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch water usage data: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ));
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _fetchWaterUsageData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (waterUsageData != null) {
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
              // Header
              Text(
                "Water Usage Dashboard",
                style: GoogleFonts.barlow(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Monitor water consumption and find ways to conserve",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),

              _buildWaterUsageSummary(waterUsageData!.totalWaterUsageLiters),
              const SizedBox(height: 25),

              _buildWaterUsageChart(waterUsageData!.farmData),
              const SizedBox(height: 25),

              _buildConservationInsights(waterUsageData!.conservationInsights),
              const SizedBox(height: 25),

              _buildConservationStrategies(
                  waterUsageData!.waterConservationStrategies),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text('No data available'));
    }
  }

  Widget _buildWaterUsageSummary(double totalWaterUsage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
              Icon(Icons.water_drop, color: Colors.white.withOpacity(0.9), size: 28),
              const SizedBox(width: 10),
              Text(
                "Total Water Usage",
                style: GoogleFonts.barlow(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "${(totalWaterUsage / 1000000).toStringAsFixed(2)} Million Liters",
            style: GoogleFonts.barlow(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Across all farms",
            style: GoogleFonts.barlow(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterUsageChart(List<FarmData> farmData) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                "Water Usage by Farm",
                style: GoogleFonts.barlow(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: _buildFarmWaterUsageChart(farmData),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Wheat', Colors.blue.shade400),
              _buildLegendItem('Corn', Colors.green.shade400),
              _buildLegendItem('Soybean', Colors.amber.shade600),
              _buildLegendItem('Rice', Colors.purple.shade400),
              _buildLegendItem('Maize', Colors.orange.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmWaterUsageChart(List<FarmData> farmData) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (farmData.map((e) => e.waterUsageLiters).reduce((a, b) => a > b ? a : b) * 1.1),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (value) {
              return Colors.white;
            },
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final farm = farmData[groupIndex];
              return BarTooltipItem(
                'Farm ${farm.farmId} (${farm.cropType})\n${(farm.waterUsageLiters / 1000).toStringAsFixed(1)}K liters',
                GoogleFonts.barlow(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= farmData.length || value < 0) return const Text('');
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    'Farm ${farmData[value.toInt()].farmId}',
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
              reservedSize: 60,
              interval: 1000000,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value / 1000000).toStringAsFixed(1)}M',
                  style: GoogleFonts.barlow(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1000000,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(
          farmData.length,
          (index) {
            final farm = farmData[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: farm.waterUsageLiters,
                  color: _getCropColor(farm.cropType),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getCropColor(String cropType) {
    switch (cropType) {
      case 'Wheat':
        return Colors.blue.shade400;
      case 'Corn':
        return Colors.green.shade400;
      case 'Soybean':
        return Colors.amber.shade600;
      case 'Rice':
        return Colors.purple.shade400;
      case 'Maize':
        return Colors.orange.shade400;
      default:
        return Colors.grey;
    }
  }

  Widget _buildConservationInsights(List<ConservationInsight> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 24),
            const SizedBox(width: 8),
            Text(
              "Conservation Insights",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: insights.length,
          itemBuilder: (context, index) {
            final insight = insights[index];
            return _buildInsightCard(insight);
          },
        ),
      ],
    );
  }

  Widget _buildInsightCard(ConservationInsight insight) {
    return Container(
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
        border: Border.all(color: _getCropColor(insight.cropType).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getCropColor(insight.cropType).withOpacity(0.2),
                child: Text(
                  insight.cropType[0],
                  style: TextStyle(
                    color: _getCropColor(insight.cropType),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.cropType,
                  style: GoogleFonts.barlow(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.water_drop, 
                  color: Colors.blue.shade700, 
                  size: 16),
              const SizedBox(width: 4),
              Text(
                "${(insight.estimatedSavingsLiters / 1000).toStringAsFixed(1)}K liters potential savings",
                style: GoogleFonts.barlow(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: insight.insights.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.eco, color: Colors.green.shade600, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          insight.insights[index],
                          style: GoogleFonts.barlow(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConservationStrategies(
      List<WaterConservationStrategy> strategies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.policy, color: Colors.indigo.shade600, size: 24),
            const SizedBox(width: 8),
            Text(
              "Water Conservation Strategies",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: strategies.length,
          itemBuilder: (context, index) {
            final strategy = strategies[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
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
                border: Border.all(
                  color: Colors.indigo.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          strategy.description,
                          style: GoogleFonts.barlow(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Saves ${strategy.savingsPercentage}",
                          style: GoogleFonts.barlow(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Source: ${strategy.source}",
                    style: GoogleFonts.barlow(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// Data model classes
class WaterUsageData {
  final List<ConservationInsight> conservationInsights;
  final List<FarmData> farmData;
  final double totalWaterUsageLiters;
  final List<WaterConservationStrategy> waterConservationStrategies;

  WaterUsageData({
    required this.conservationInsights,
    required this.farmData,
    required this.totalWaterUsageLiters,
    required this.waterConservationStrategies,
  });

  factory WaterUsageData.fromJson(Map<String, dynamic> json) {
    return WaterUsageData(
      conservationInsights: (json['conservation_insights'] as List)
          .map((item) => ConservationInsight.fromJson(item))
          .toList(),
      farmData: (json['farm_data'] as List)
          .map((item) => FarmData.fromJson(item))
          .toList(),
      totalWaterUsageLiters: json['total_water_usage_liters'],
      waterConservationStrategies: (json['water_conservation_strategies'] as List)
          .map((item) => WaterConservationStrategy.fromJson(item))
          .toList(),
    );
  }
}

class ConservationInsight {
  final String cropType;
  final double estimatedSavingsLiters;
  final List<String> insights;

  ConservationInsight({
    required this.cropType,
    required this.estimatedSavingsLiters,
    required this.insights,
  });

  factory ConservationInsight.fromJson(Map<String, dynamic> json) {
    return ConservationInsight(
      cropType: json['crop_type'],
      estimatedSavingsLiters: json['estimated_savings_liters'],
      insights: List<String>.from(json['insights']),
    );
  }
}

class FarmData {
  final String cropType;
  final int farmId;
  final double rainfallMm;
  final double soilMoisture;
  final double waterUsageLiters;

  FarmData({
    required this.cropType,
    required this.farmId,
    required this.rainfallMm,
    required this.soilMoisture,
    required this.waterUsageLiters,
  });

  factory FarmData.fromJson(Map<String, dynamic> json) {
    return FarmData(
      cropType: json['crop_type'],
      farmId: json['farm_id'],
      rainfallMm: json['rainfall_mm'],
      soilMoisture: json['soil_moisture'],
      waterUsageLiters: json['water_usage_liters'],
    );
  }
}

class WaterConservationStrategy {
  final String description;
  final String savingsPercentage;
  final String source;

  WaterConservationStrategy({
    required this.description,
    required this.savingsPercentage,
    required this.source,
  });

  factory WaterConservationStrategy.fromJson(Map<String, dynamic> json) {
    return WaterConservationStrategy(
      description: json['description'],
      savingsPercentage: json['savings_percentage'],
      source: json['source'],
    );
  }
}
