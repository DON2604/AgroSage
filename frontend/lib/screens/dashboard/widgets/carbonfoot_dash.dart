import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class CarbonFootprintDashboard extends StatefulWidget {
  const CarbonFootprintDashboard({super.key});

  @override
  State<CarbonFootprintDashboard> createState() =>
      _CarbonFootprintDashboardState();
}

class _CarbonFootprintDashboardState extends State<CarbonFootprintDashboard> {
  bool isLoading = true;
  Map<String, dynamic>? sustainabilityData;

  @override
  void initState() {
    super.initState();
    fetchSustainabilityData();
  }

  Future<void> fetchSustainabilityData() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.207:5000/market-trend'));

      if (response.statusCode == 200) {
        setState(() {
          sustainabilityData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load sustainability data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50),
        ),
      );
    }

    if (sustainabilityData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Failed to load sustainability data',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: fetchSustainabilityData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final carbonData = sustainabilityData!['carbon_footprint_calculation'];
    final reductionData = sustainabilityData!['reduction_insights'];
    final webTrendsData = sustainabilityData!['web_carbon_trends'];

    final farmData = carbonData['farm_data'] as List;
    final totalCarbonFootprint = carbonData['total_carbon_footprint'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.eco,
                          color: Color(0xFF4CAF50), size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Sustainability Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50)),
                      onPressed: fetchSustainabilityData,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Monitor and optimize your farm\'s carbon footprint',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildTotalCarbonCard(totalCarbonFootprint),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child:
                    _buildReductionOpportunityCard(reductionData['reductions']),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFarmCarbonChart(farmData),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFarmDataSection(farmData),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReductionInsights(reductionData['reductions']),
          const SizedBox(height: 24),
          _buildWebCarbonTrends(webTrendsData['reduction_strategies']),
        ],
      ),
    );
  }

  Widget _buildTotalCarbonCard(double totalCarbon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.co2, color: Color(0xFF4CAF50), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Carbon Footprint',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${totalCarbon.toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total CO₂ emissions',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReductionOpportunityCard(List reductions) {
    final totalReduction = reductions
        .map<double>((r) => r['estimated_reduction'] as double)
        .fold(0.0, (a, b) => a + b);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_down,
                      color: Color(0xFFFFA000), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Reduction Potential',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFA000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${totalReduction.toStringAsFixed(2)} kg',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFFA000),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(totalReduction / sustainabilityData!['carbon_footprint_calculation']['total_carbon_footprint'] * 100).toStringAsFixed(1)}% potential reduction',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmCarbonChart(List farmData) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < farmData.length; i++) {
      final farm = farmData[i];
      barGroups.add(
        BarChartGroupData(
          x: farm['farm_id'],
          barRods: [
            BarChartRodData(
              toY: farm['carbon_footprint'],
              color: _getCropColor(farm['crop_type']).withOpacity(0.8),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Explicitly set to white
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carbon Footprint by Farm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: farmData
                          .map<double>(
                              (farm) => farm['carbon_footprint'] as double)
                          .reduce((a, b) => a > b ? a : b) *
                      1.2,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Farm ${value.toInt()}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
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
                            '${value.toInt()} kg',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildCropLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildCropLegend() {
    final cropTypes = {'Wheat', 'Corn', 'Soybean'};
    return Wrap(
      spacing: 24,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: cropTypes.map((crop) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCropColor(crop),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              crop,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getCropColor(String cropType) {
    switch (cropType) {
      case 'Wheat':
        return const Color(0xFFFFB74D);
      case 'Corn':
        return const Color(0xFF81C784);
      case 'Soybean':
        return const Color(0xFF64B5F6);
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildFarmDataSection(List farmData) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Explicitly set to white
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                dataRowHeight: 56,
                headingRowColor:
                    MaterialStateProperty.all(const Color(0xFFF5F5F5)),
                columns: const [
                  DataColumn(
                      label: Text('Farm ID',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                  DataColumn(
                      label: Text('Crop Type',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                  DataColumn(
                      label: Text('Carbon',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                  DataColumn(
                      label: Text('Fertilizer',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                  DataColumn(
                      label: Text('Pesticide',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                ],
                rows: farmData.map<DataRow>((farm) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        '${farm['farm_id']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 47, 43, 43)),
                      )),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getCropColor(farm['crop_type']),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${farm['crop_type']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 47, 43, 43))),
                          ],
                        ),
                      ),
                      DataCell(Text('${farm['carbon_footprint']} kg',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                      DataCell(Text(
                          '${farm['fertilizer_use'].toStringAsFixed(2)} kg',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                      DataCell(Text(
                          '${farm['pesticide_use'].toStringAsFixed(2)} kg',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 47, 43, 43)))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReductionInsights(List reductions) {
    final totalReduction = reductions
        .map<double>((r) => r['estimated_reduction'] as double)
        .fold(0.0, (a, b) => a + b);

    List<PieChartSectionData> sections = [];
    for (final reduction in reductions) {
      if (reduction['estimated_reduction'] > 0) {
        sections.add(
          PieChartSectionData(
            value: reduction['estimated_reduction'],
            title: 'F${reduction['farm_id']}',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            color: _getCropColor(reduction['crop_type']),
            radius: 70,
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        );
      }
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Explicitly set to white
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emission Reduction Opportunities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(enabled: false),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Potential Reduction',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${totalReduction.toStringAsFixed(2)} kg CO₂e',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Reduction Percentage',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((totalReduction / sustainabilityData!['carbon_footprint_calculation']['total_carbon_footprint']) * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: reductions.map((reduction) {
                if ((reduction['insights'] as List).isEmpty) return Container();

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCropColor(reduction['crop_type'])
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Farm ${reduction['farm_id']} • ${reduction['crop_type']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _getCropColor(reduction['crop_type'])
                                    .withOpacity(0.8),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${reduction['estimated_reduction']} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(reduction['insights'] as List).map((insight) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.arrow_right,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  insight,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Color.fromARGB(255, 47, 43, 43),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebCarbonTrends(List strategies) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Explicitly set to white
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Industry Best Practices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 20),
            ...(strategies as List).map((strategy) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy['description'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Reduction: ${strategy['reduction_percentage']}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Source: ${strategy['source']}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
