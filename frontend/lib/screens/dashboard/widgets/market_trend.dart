import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketTrendDashboard extends StatefulWidget {
  const MarketTrendDashboard({super.key});

  @override
  State<MarketTrendDashboard> createState() => _MarketTrendDashboardState();
}

class _MarketTrendDashboardState extends State<MarketTrendDashboard> {
  bool isLoading = false;
  String? errorMessage;
  MarketTrendData? marketTrendData;

  @override
  void initState() {
    super.initState();
    _fetchMarketTrendData();
  }

  Future<void> _fetchMarketTrendData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('https://1028-45-112-68-8.ngrok-free.app/market-trends'),headers: {
        'Accept': 'application/json',
        'User-Agent': 'PostmanRuntime/7.36.0', 
        'ngrok-skip-browser-warning': 'true', 
      },)
          .timeout(const Duration(seconds: 10000));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          marketTrendData = MarketTrendData.fromJson(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch market trend data: ${e.toString()}";
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
              onPressed: () => _fetchMarketTrendData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (marketTrendData != null) {
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
                "Market Trends Dashboard",
                style: GoogleFonts.barlow(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Analyze and compare market trends for crops",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),

              // Market Analysis Section
              _buildMarketAnalysisSection(marketTrendData!.marketAnalysis),
              const SizedBox(height: 25),

              // Top Crops Comparison Section
              _buildTopCropsComparisonSection(
                  marketTrendData!.top3MarketComparison),
              const SizedBox(height: 25),

              // Web Market Trends Section
              _buildWebMarketTrendsSection(marketTrendData!.webMarketTrends),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text('No data available'));
    }
  }

  Widget _buildMarketAnalysisSection(MarketAnalysis analysis) {
    final totalParameters = analysis.parameterAnalysis.length;
    final risingParameters = analysis.parameterAnalysis.values
        .where((data) => data == 'True')
        .length;
    final isOverallRising = risingParameters > (totalParameters / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
            const SizedBox(width: 8),
            Text(
              "Market Analysis",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isOverallRising
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverallRising ? Icons.trending_up : Icons.trending_down,
                    color: isOverallRising
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isOverallRising
                        ? "Overall Rising Trend"
                        : "Overall Non-Rising Trend",
                    style: GoogleFonts.barlow(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isOverallRising
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
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
                "Market Parameter Trends",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              _buildTrendIndicatorsGrid(analysis),
              const SizedBox(height: 20),
              Text(
                "Parameter Trend Distribution",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: _buildTrendBarChart(analysis),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicatorsGrid(MarketAnalysis analysis) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8, 
        mainAxisSpacing: 8,
      ),
      itemCount: analysis.parameterAnalysis.length,
      itemBuilder: (context, index) {
        final paramName = analysis.parameterAnalysis.keys.elementAt(index);
        final paramValue = analysis.parameterAnalysis[paramName]!;
        final isTrending = paramValue == 'True';

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isTrending ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isTrending ? Colors.green.shade300 : Colors.red.shade300,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isTrending ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isTrending ? 'TRUE' : 'FALSE',
                  style: GoogleFonts.barlow(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getShortName(paramName),
                textAlign: TextAlign.center,
                style: GoogleFonts.barlow(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Icon
              Icon(
                isTrending ? Icons.trending_up : Icons.trending_down,
                color: isTrending ? Colors.green.shade700 : Colors.red.shade700,
                size: 14,
              ),
            ],
          ),
        );
      },
    );
  }

  String _getShortName(String paramName) {
    final words = paramName.split('_');
    if (words.length <= 2) return paramName.replaceAll('_', ' ');

    final result = words.sublist(0, words.length - 1)
        .map((word) => word[0])
        .join('')
        .toUpperCase();
    return '$result ${words.last}';
  }

  Widget _buildTrendBarChart(MarketAnalysis analysis) {
    int risingCount = 0;
    int nonRisingCount = 0;

    analysis.parameterAnalysis.values.forEach((value) {
      if (value == 'True') {
        risingCount++;
      } else {
        nonRisingCount++;
      }
    });

    final total = risingCount + nonRisingCount;
    final percentRising = (risingCount / total) * 100;
    final percentNonRising = (nonRisingCount / total) * 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = groupIndex == 0
                  ? 'Rising: ${percentRising.toStringAsFixed(1)}%'
                  : 'Non-Rising: ${percentNonRising.toStringAsFixed(1)}%';
              return BarTooltipItem(
                label,
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
                    value == 0 ? 'Rising' : 'Non-Rising',
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
              reservedSize: 30,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString() + '%',
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
          horizontalInterval: 20,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: percentRising,
                color: Colors.blue.shade400,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: percentNonRising,
                color: Colors.red.shade400,
                width: 40,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCropsComparisonSection(Top3MarketComparison comparison) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.amber.shade700, size: 24),
            const SizedBox(width: 8),
            Text(
              "Top Crops Market Comparison",
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

        // Market price comparison chart
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
                "Market Price Comparison (per ton)",
                style: GoogleFonts.barlow(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 250,
                child: _buildMarketPriceChart(comparison),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Detailed comparison cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.32,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: comparison.crops.length,
          itemBuilder: (context, index) {
            final cropName = comparison.crops.keys.elementAt(index);
            final cropData = comparison.crops[cropName]!;

            // Choose color based on crop name
            Color cardColor;
            if (cropName == 'Barley') {
              cardColor = Colors.amber.shade700;
            } else if (cropName == 'Oats') {
              cardColor = Colors.orange.shade700;
            } else {
              cardColor = Colors.brown.shade700;
            }

            return _buildCropComparisonCard(cropName, cropData, cardColor);
          },
        ),
      ],
    );
  }

  Widget _buildMarketPriceChart(Top3MarketComparison comparison) {
    final crops = comparison.crops;
    final cropNames = crops.keys.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 350,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cropName = cropNames[groupIndex];
              final price = crops[cropName]!['Market_Price_per_ton'];
              return BarTooltipItem(
                '$cropName: \$${price.toString()}',
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
                if (value >= cropNames.length || value < 0)
                  return const Text('');
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    cropNames[value.toInt()],
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
              interval: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
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
          horizontalInterval: 50,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(
          cropNames.length,
          (index) {
            final cropName = cropNames[index];
            final marketPrice =
                (crops[cropName]!['Market_Price_per_ton'] as num).toDouble();

            // Different colors for different crops
            Color barColor;
            if (cropName == 'Barley') {
              barColor = Colors.amber.shade400;
            } else if (cropName == 'Oats') {
              barColor = Colors.orange.shade400;
            } else {
              barColor = Colors.brown.shade400;
            }

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: marketPrice,
                  color: barColor,
                  width: 30,
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

  Widget _buildCropComparisonCard(
      String cropName, Map<String, dynamic> cropData, Color color) {
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
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  cropName[0].toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cropName,
                  style: GoogleFonts.barlow(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCropDataRow(
                      'Market Price', '\$${cropData['Market_Price_per_ton']}'),
                  _buildCropDataRow(
                      'Demand Index', '${cropData['Demand_Index']}'),
                  _buildCropDataRow(
                      'Supply Index', '${cropData['Supply_Index']}'),
                  _buildCropDataRow('Competitor Price',
                      '\$${cropData['Competitor_Price_per_ton']}'),
                  _buildCropDataRow(
                      'Consumer Trend', '${cropData['Consumer_Trend_Index']}'),
                  _buildCropDataRow('Economic Indicator',
                      '${cropData['Economic_Indicator']}'),
                  _buildCropDataRow(
                      'Weather Impact', '${cropData['Weather_Impact_Score']}'),
                  _buildCropDataRow(
                      'Seasonal Factor', '${cropData['Seasonal_Factor']}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.barlow(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.barlow(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebMarketTrendsSection(WebMarketTrends trends) {
    final List<String> cropNames = trends.crops.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.public, color: Colors.indigo.shade400, size: 24),
            const SizedBox(width: 8),
            Text(
              "Web Market Trends",
              style: GoogleFonts.barlow(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 180, // Fixed height for the row
          child: ListView.builder(
            scrollDirection: Axis.horizontal, // Horizontal scrolling
            physics: const BouncingScrollPhysics(),
            itemCount: cropNames.length,
            itemBuilder: (context, index) {
              final cropName = cropNames[index];
              final cropData = trends.crops[cropName]!;

              // Different colors for different crops
              Color cardColor;
              if (cropName == 'Barley') {
                cardColor = Colors.indigo.shade400;
              } else if (cropName == 'Oats') {
                cardColor = Colors.purple.shade400;
              } else {
                cardColor = Colors.blue.shade400;
              }

              return Padding(
                padding:
                    const EdgeInsets.only(right: 15), // Space between cards
                child: SizedBox(
                  width: 200, // Fixed width for each card
                  child:
                      _buildCompactWebTrendCard(cropName, cropData, cardColor),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // More compact version of the web trend card
  Widget _buildCompactWebTrendCard(
      String cropName, Map<String, dynamic> cropData, Color color) {
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
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      style: GoogleFonts.barlow(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Rising ${cropData['rising_percentage']}',
                      style: GoogleFonts.barlow(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.source_rounded,
                        size: 12, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cropData['source'],
                        style: GoogleFonts.barlow(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Strength: ${cropData['strength']}',
                  style: GoogleFonts.barlow(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Key metrics in compact row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactMetric(
                      '\$${cropData['Market_Price_per_ton']}',
                      Icons.attach_money,
                      Colors.green.shade400,
                    ),
                    _buildCompactMetric(
                      '${cropData['Demand_Index']}',
                      Icons.people,
                      Colors.blue.shade400,
                    ),
                    _buildCompactMetric(
                      '${cropData['Supply_Index']}',
                      Icons.inventory_2,
                      Colors.amber.shade400,
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

  Widget _buildCompactMetric(String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.barlow(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class MarketTrendData {
  final MarketAnalysis marketAnalysis;
  final Top3MarketComparison top3MarketComparison;
  final WebMarketTrends webMarketTrends;

  MarketTrendData({
    required this.marketAnalysis,
    required this.top3MarketComparison,
    required this.webMarketTrends,
  });

  factory MarketTrendData.fromJson(Map<String, dynamic> json) {
    return MarketTrendData(
      marketAnalysis: MarketAnalysis.fromJson(json['market_analysis'] ?? {}),
      top3MarketComparison:
          Top3MarketComparison.fromJson(json['top3_market_comparison'] ?? {}),
      webMarketTrends: WebMarketTrends.fromJson(json['web_market_trends'] ?? {}),
    );
  }
}

class MarketAnalysis {
  final Map<String, String> parameterAnalysis;

  MarketAnalysis({
    required this.parameterAnalysis,
  });

  factory MarketAnalysis.fromJson(Map<String, dynamic> json) {
    final Map<String, String> paramAnalysis = {};

    json.forEach((key, value) {
      paramAnalysis[key] = value.toString();
    });

    return MarketAnalysis(
      parameterAnalysis: paramAnalysis,
    );
  }
}

class Top3MarketComparison {
  final String insights;
  final Map<String, Map<String, dynamic>> crops;

  Top3MarketComparison({
    required this.insights,
    required this.crops,
  });

  factory Top3MarketComparison.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, dynamic>> cropsMap = {};

    if (json['parameters_comparison'] != null) {
      (json['parameters_comparison'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          cropsMap[key] = value;
        }
      });
    }

    return Top3MarketComparison(
      insights: json['insights'] ?? 'No insights available',
      crops: cropsMap,
    );
  }
}

class WebMarketTrends {
  final Map<String, Map<String, dynamic>> crops;

  WebMarketTrends({
    required this.crops,
  });

  factory WebMarketTrends.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, dynamic>> cropsMap = {};

    if (json['crops'] != null) {
      (json['crops'] as Map<String, dynamic>).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          cropsMap[key] = value;
        }
      });
    }

    return WebMarketTrends(
      crops: cropsMap,
    );
  }
}