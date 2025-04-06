import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class SustainabilityDashboard extends StatefulWidget {
  const SustainabilityDashboard({super.key});

  @override
  State<SustainabilityDashboard> createState() =>
      _SustainabilityDashboardState();
}

class _SustainabilityDashboardState extends State<SustainabilityDashboard> {
  bool isLoading = false;
  String? errorMessage;
  SustainabilityData? sustainabilityData;

  @override
  void initState() {
    super.initState();
    _fetchSustainabilityData();
  }

  Future<void> _fetchSustainabilityData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://22bb-45-112-68-8.ngrok-free.app/sustainability'),
          headers: {
        'Accept': 'application/json',
        'User-Agent': 'PostmanRuntime/7.36.0', 
        'ngrok-skip-browser-warning': 'true', 
      },)
          .timeout(const Duration(seconds: 15000));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          sustainabilityData = SustainabilityData.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch sustainability data: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _fetchSustainabilityData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (sustainabilityData != null) {
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
                "Sustainability Dashboard",
                style: GoogleFonts.barlow(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Analyze and compare crop sustainability metrics",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),

              // Main sustainability analysis section
              _buildMainCropSection(sustainabilityData!.sustainabilityAnalysis),
              const SizedBox(height: 25),

              // Top 3 crops comparison
              _buildTopCropsComparison(sustainabilityData!.top3Comparison),
              const SizedBox(height: 25),

              // Web trends
              _buildWebTrendsSection(sustainabilityData!.webTrends),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text('No data available'));
    }
  }

  Widget _buildMainCropSection(SustainabilityAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.eco, color: Colors.green.shade600, size: 24),
            const SizedBox(width: 8),
            Text(
              "Sustainability Analysis: ${analysis.crop}",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Sustainability analysis card
        Container(
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
              Text(
                analysis.analysis,
                style: GoogleFonts.barlow(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Sustainability scores graph
              SizedBox(
                height: 200,
                child: _buildSustainabilityScoreChart(
                    analysis.sustainabilityScores),
              ),
              const SizedBox(height: 20),

              // Parameter radar chart
              _buildParameterRadarChart(analysis.parameters),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSustainabilityScoreChart(List<double> scores) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    'Farm ${value.toInt() + 1}',
                    style: GoogleFonts.barlow(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.2,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.barlow(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: scores.length - 1,
        minY: 0,
        maxY: 1.0,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              scores.length,
              (index) => FlSpot(index.toDouble(), scores[index]),
            ),
            isCurved: true,
            color: Colors.green.shade400,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.green.shade400,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRadarChart(Map<String, List<num>> parameters) {
    // Calculate averages for each parameter
    final Map<String, double> averages = {};
    parameters.forEach((key, values) {
      double sum = 0;
      for (var value in values) {
        sum += value.toDouble();
      }
      averages[key] = sum / values.length;
    });

    // Updated normalization values based on the provided sample data
    final Map<String, double> maxValues = {
      'Crop_Yield_ton': 4.0,
      'Fertilizer_Usage_kg': 200.0,
      'Pesticide_Usage_kg': 10.0,
      'Rainfall_mm': 250.0,
      'Soil_Moisture': 50.0,
      'Soil_pH': 7.5,
      'Temperature_C': 30.0,
    };

    // Normalize values for radar chart (0-1 scale)
    final Map<String, double> normalizedValues = {};
    averages.forEach((key, value) {
      if (maxValues.containsKey(key)) {
        normalizedValues[key] = value / maxValues[key]!;
        // Cap at 1.0
        if (normalizedValues[key]! > 1.0) normalizedValues[key] = 1.0;
      } else {
        // Fallback for any unexpected parameters
        normalizedValues[key] = value / 100.0;
        if (normalizedValues[key]! > 1.0) normalizedValues[key] = 1.0;
      }
    });

    final List<String> features = normalizedValues.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Average Parameter Values",
          style: GoogleFonts.barlow(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 250,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              dataSets: [
                RadarDataSet(
                  dataEntries: List.generate(
                    features.length,
                    (index) =>
                        RadarEntry(value: normalizedValues[features[index]]!),
                  ),
                  borderColor: Colors.green,
                  fillColor: Colors.green.withOpacity(0.2),
                  borderWidth: 2,
                ),
              ],
              radarBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
              tickCount: 5,
              ticksTextStyle:
                  const TextStyle(color: Colors.transparent, fontSize: 10),
              tickBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
              gridBorderData:
                  BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: GoogleFonts.barlow(
                color: Colors.black54,
                fontSize: 11,
              ),
              getTitle: (index, angle) => RadarChartTitle(
                text: features[index].replaceAll('_', ' '),
              ),
            ),
          ),
        ),

        // Legend with more readable formatting
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: features.map((feature) {
            String valueStr;
            if (feature.contains('pH')) {
              valueStr = averages[feature]!.toStringAsFixed(1);
            } else if (feature.contains('Crop_Yield')) {
              valueStr = '${averages[feature]!.toStringAsFixed(1)} ton';
            } else if (feature.contains('_kg')) {
              valueStr = '${averages[feature]!.toStringAsFixed(1)} kg';
            } else if (feature.contains('Rainfall')) {
              valueStr = '${averages[feature]!.toStringAsFixed(1)} mm';
            } else if (feature.contains('Temperature')) {
              valueStr = '${averages[feature]!.toStringAsFixed(1)}°C';
            } else {
              valueStr = averages[feature]!.toStringAsFixed(1);
            }
            
            return Chip(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.green.shade100),
              label: Text(
                '${feature.replaceAll('_', ' ')}: $valueStr',
                style: GoogleFonts.barlow(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTopCropsComparison(Top3Comparison comparison) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.leaderboard, color: Colors.amber.shade700, size: 24),
            const SizedBox(width: 8),
            Text(
              "Top Crops Comparison",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Text(
          comparison.insights,
          style: GoogleFonts.barlow(
            fontSize: 14,
            color: Colors.black87,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 15),

        // Bar chart for comparing scores
        SizedBox(
          height: 200,
          child: _buildCropScoreComparisonChart(comparison.topCrops),
        ),
        const SizedBox(height: 20),

        // Detailed cards for each crop
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: comparison.topCrops.length,
          itemBuilder: (context, index) {
            final crop = comparison.topCrops[index];
            return _buildCropDetailCard(
                crop,
                [
                  Colors.green.shade400,
                  Colors.teal.shade400,
                  Colors.cyan.shade400,
                ][index % 3]);
          },
        ),
      ],
    );
  }

  Widget _buildCropScoreComparisonChart(List<TopCrop> crops) {
    final maxScore = crops.map((c) => c.score).reduce((a, b) => a > b ? a : b);
    final roundedMax = (maxScore.ceil() / 10).ceil() * 10.0;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: roundedMax > 0 ? roundedMax : 10.0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${crops[groupIndex].crop}\nScore: ${crops[groupIndex].score.toStringAsFixed(1)}',
                GoogleFonts.barlow(
                    color: Colors.black87, fontWeight: FontWeight.bold),
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
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    crops[value.toInt()].crop,
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
              reservedSize: 40,
              interval: 2.0,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
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
          horizontalInterval: 2,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(
          crops.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: crops[index].score,
                color: [
                  Colors.green.shade400,
                  Colors.teal.shade400,
                  Colors.cyan.shade400,
                ][index % 3],
                width: 20,
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

  Widget _buildCropDetailCard(TopCrop crop, Color color) {
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
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grass, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  crop.crop,
                  style: GoogleFonts.barlow(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Score: ${crop.score}',
            style: GoogleFonts.barlow(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: crop.parameters.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.replaceAll('_', ' '),
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: GoogleFonts.barlow(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTrendsSection(WebTrends trends) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.purple.shade400, size: 24),
            const SizedBox(width: 8),
            Text(
              "Web Trends",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Trending crops cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.4,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: trends.trendingCrops.length,
          itemBuilder: (context, index) {
            final crop = trends.trendingCrops[index];
            return _buildTrendingCropCard(
                crop,
                [
                  Colors.purple.shade200,
                  Colors.indigo.shade200,
                  Colors.blue.shade200,
                ][index % 3]);
          },
        ),
      ],
    );
  }

  Widget _buildTrendingCropCard(TrendingCrop crop, Color color) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.3),
                child: Text(
                  crop.crop[0].toUpperCase(),
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  crop.crop,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (crop.parameters.isNotEmpty) ...[
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: crop.parameters.entries.take(3).map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key.replaceAll('_', ' '),
                                style: GoogleFonts.barlow(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                entry.value.toString(),
                                style: GoogleFonts.barlow(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Strength: ${crop.strength}',
                  style: GoogleFonts.barlow(
                    fontSize: 12,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.source_rounded, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      crop.source,
                      style: GoogleFonts.barlow(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SustainabilityData {
  final SustainabilityAnalysis sustainabilityAnalysis;
  final Top3Comparison top3Comparison;
  final WebTrends webTrends;

  SustainabilityData({
    required this.sustainabilityAnalysis,
    required this.top3Comparison,
    required this.webTrends,
  });

  factory SustainabilityData.fromJson(Map<String, dynamic> json) {
    return SustainabilityData(
      sustainabilityAnalysis:
          SustainabilityAnalysis.fromJson(json['sustainability_analysis']),
      top3Comparison: Top3Comparison.fromJson(json['top3_comparison']),
      webTrends: WebTrends.fromJson(json['web_trends']),
    );
  }
}

class SustainabilityAnalysis {
  final String analysis;
  final String crop;
  final Map<String, List<num>> parameters;
  final List<double> sustainabilityScores;

  SustainabilityAnalysis({
    required this.analysis,
    required this.crop,
    required this.parameters,
    required this.sustainabilityScores,
  });

  factory SustainabilityAnalysis.fromJson(Map<String, dynamic> json) {
    final Map<String, List<num>> parameters = {};
    (json['parameters'] as Map<String, dynamic>).forEach((key, value) {
      parameters[key] = List<num>.from(value);
    });

    return SustainabilityAnalysis(
      analysis: json['analysis'] ?? '',
      crop: json['crop'] ?? '',
      parameters: parameters,
      sustainabilityScores: List<double>.from(json['sustainability_scores'] ?? []),
    );
  }
}

class Top3Comparison {
  final String insights;
  final List<TopCrop> topCrops;

  Top3Comparison({
    required this.insights,
    required this.topCrops,
  });

  factory Top3Comparison.fromJson(Map<String, dynamic> json) {
    return Top3Comparison(
      insights: json['insights'],
      topCrops: (json['top_crops'] as List)
          .map((item) => TopCrop.fromJson(item))
          .toList(),
    );
  }
}

class TopCrop {
  final String crop;
  final Map<String, dynamic> parameters;
  final double score;

  TopCrop({
    required this.crop,
    required this.parameters,
    required this.score,
  });

  factory TopCrop.fromJson(Map<String, dynamic> json) {
    return TopCrop(
      crop: json['crop'] ?? '',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}

class WebTrends {
  final List<TrendingCrop> trendingCrops;

  WebTrends({
    required this.trendingCrops,
  });

  factory WebTrends.fromJson(Map<String, dynamic> json) {
    return WebTrends(
      trendingCrops: (json['trending_crops'] as List)
          .map((item) => TrendingCrop.fromJson(item))
          .toList(),
    );
  }
}

class TrendingCrop {
  final String crop;
  final Map<String, dynamic> parameters;
  final String source;
  final String strength;

  TrendingCrop({
    required this.crop,
    required this.parameters,
    required this.source,
    required this.strength,
  });

  factory TrendingCrop.fromJson(Map<String, dynamic> json) {
    return TrendingCrop(
      crop: json['crop'] ?? '',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      source: json['source'] ?? '',
      strength: json['strength'] ?? '',
    );
  }
}