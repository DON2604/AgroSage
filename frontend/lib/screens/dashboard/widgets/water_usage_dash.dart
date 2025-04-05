import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class WaterUsageDash extends StatefulWidget {
  const WaterUsageDash({Key? key}) : super(key: key);

  @override
  _WaterUsageDashState createState() => _WaterUsageDashState();
}

class _WaterUsageDashState extends State<WaterUsageDash> {
  bool _isLoading = true;
  Map<String, dynamic> _sustainabilityData = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSustainabilityData();
  }

  Future<void> _fetchSustainabilityData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.207:5000/sustainability'));

      if (response.statusCode == 200) {
        setState(() {
          _sustainabilityData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: Colors.red)),
      );
    }

    return _buildDashboard();
  }

  Widget _buildDashboard() {
    final totalWaterUsage = _sustainabilityData['water_usage_calculation']?['total_water_usage'] ?? 0.0;
    final farmData = List<Map<String, dynamic>>.from(_sustainabilityData['farm_data'] ?? []);
    final farmCalculations = List<Map<String, dynamic>>.from(
        _sustainabilityData['water_usage_calculation']?['farm_calculations'] ?? []);
    final conservationInsights = List<Map<String, dynamic>>.from(
        _sustainabilityData['conservation_insights'] ?? []);
    final waterConservationStrategies = List<Map<String, dynamic>>.from(
        _sustainabilityData['web_water_trends']?['conservation_strategies'] ?? []);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(totalWaterUsage),
            const SizedBox(height: 24),
            _buildWaterUsageByFarm(farmCalculations),
            const SizedBox(height: 24),
            _buildWaterSavingsPotential(conservationInsights),
            const SizedBox(height: 24),
            _buildInsightsSection(conservationInsights),
            const SizedBox(height: 24),
            _buildStrategiesSection(waterConservationStrategies),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double totalWaterUsage) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crop Sustainability Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.white, size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Water Usage',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${(totalWaterUsage / 1000000).toStringAsFixed(2)} Million Liters',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterUsageByFarm(List<Map<String, dynamic>> farmCalculations) {
    Map<String, double> waterByCrop = {};
    for (var farm in farmCalculations) {
      final cropType = farm['crop_type'] as String;
      final waterUsage = farm['water_usage_liters'] as double? ?? 0.0;
      waterByCrop[cropType] = (waterByCrop[cropType] ?? 0) + waterUsage;
    }

    final pieChartSections = waterByCrop.entries.map((entry) {
      final color = _getCropColor(entry.key);
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value / 1000000).toStringAsFixed(1)}M',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Usage by Crop Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: waterByCrop.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getCropColor(entry.key),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterSavingsPotential(List<Map<String, dynamic>> conservationInsights) {
    Map<String, double> savingsByCrop = {};
    for (var insight in conservationInsights) {
      final cropType = insight['crop_type'] as String;
      final savings = insight['estimated_savings'] as double? ?? 0.0;
      savingsByCrop[cropType] = (savingsByCrop[cropType] ?? 0) + savings;
    }

    final barGroups = savingsByCrop.entries.map((entry) {
      final index = savingsByCrop.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: _getCropColor(entry.key),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Potential Water Savings by Crop (Liters)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: savingsByCrop.values.fold(
                          0.0, (prev, curr) => curr > prev ? curr : prev) *
                      1.2,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final crops = savingsByCrop.keys.toList();
                          if (value.toInt() >= 0 &&
                              value.toInt() < crops.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                crops[value.toInt()],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      right: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(List<Map<String, dynamic>> conservationInsights) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conservation Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: conservationInsights.length,
                itemBuilder: (context, index) {
                  final insight = conservationInsights[index];
                  return _buildInsightCard(insight);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    final cropType = insight['crop_type'] as String;
    final savings = insight['estimated_savings'] as double? ?? 0.0;
    final insightText = insight['insights'] as String? ?? "No insights available";

    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 214, 244, 244),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.eco, size: 20, color: _getCropColor(cropType)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cropType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _getCropColor(cropType),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${savings.toStringAsFixed(0)} L',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                insightText,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategiesSection(List<Map<String, dynamic>> strategies) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Conservation Strategies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: strategies.length,
              itemBuilder: (context, index) {
                final strategy = strategies[index];
                return _buildStrategyCard(strategy, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyCard(Map<String, dynamic> strategy, int index) {
    final description = strategy['description'] as String? ?? "No description available";
    final savingsPercentage = strategy['savings_percentage'] as String? ?? "N/A";
    final source = strategy['source'] as String? ?? "Unknown source";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.blue : Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      index % 2 == 0 ? Icons.water_drop : Icons.eco,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strategy ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Potential Savings: $savingsPercentage',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Text(
              'Source: $source',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCropColor(String cropType) {
    switch (cropType) {
      case 'Wheat':
        return const Color.fromARGB(255, 233, 177, 7);
      case 'Corn':
        return Colors.yellow.shade800;
      case 'Soybean':
        return Colors.green.shade700;
      default:
        return Colors.blue;
    }
  }
}
