import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

class ScrollableList extends StatefulWidget {
  final bool isSocial;

  const ScrollableList({
    super.key,
    this.isSocial = true,
  });

  final List<Map<String, dynamic>> crops = const [
    {
      "name": "Wheat",
      "image": "assets/wheat.jpg",
      "tag": "High Yield Crop",
      "feature": "Sustainable"
    },
    {
      "name": "Soybean",
      "image": "assets/soybean.jpg",
      "tag": "Nutritious Crop",
      "feature": "Low Water Usage"
    },
    {
      "name": "Corn",
      "image": "assets/corn.jpeg",
      "tag": "Versatile Crop",
      "feature": "High Demand"
    },
    {
      "name": "Rice",
      "image": "assets/rice.webp",
      "tag": "Staple Crop",
      "feature": "Sustainable"
    },
  ];

  @override
  State<ScrollableList> createState() => _ScrollableListState();
}

class _ScrollableListState extends State<ScrollableList> {
  late int soilMoisture;
  late int temperature;
  late int humidity;
  late int lightIntensity;

  @override
  void initState() {
    super.initState();
    _updateData();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _updateData();
        });
      }
    });
  }

  void _updateData() {
    final random = Random();
    soilMoisture = 60 + random.nextInt(30);
    temperature = 20 + random.nextInt(15);
    humidity = 40 + random.nextInt(50);
    lightIntensity = 70 + random.nextInt(30);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSocial) {
      return _buildCarousel(context);
    } else {
      return _buildDataCard(context);
    }
  }

  Widget _buildCarousel(BuildContext context) {
    double cardSize = MediaQuery.of(context).size.width * 0.5;

    return Center(
      child: CarouselSlider.builder(
        options: CarouselOptions(
            height: 220,
            scrollDirection: Axis.vertical,
            enlargeCenterPage: true,
            autoPlay: false,
            autoPlayInterval: const Duration(seconds: 3),
            viewportFraction: 1),
        itemCount: widget.crops.length,
        itemBuilder: (context, index, realIndex) {
          final crop = widget.crops[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Container(
              width: cardSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    Hero(
                      tag: "crop-${crop["name"]}",
                      child: Container(
                        height: 220,
                        width: 140,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(crop["image"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6EE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                crop["tag"],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF558B2F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              crop["name"],
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E3A59),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1, thickness: 1, color: Color(0xFFECEEF1)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6EE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.eco_outlined,
                                    color: Color(0xFF558B2F),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  crop["feature"],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF558B2F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Field Conditions",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricTile("Soil Moisture", "$soilMoisture%", Icons.water_drop, Colors.blue),
            const SizedBox(height: 12),
            _buildMetricTile("Temperature", "$temperature°C", Icons.thermostat, Colors.orange),
            const SizedBox(height: 12),
            _buildMetricTile("Humidity", "$humidity%", Icons.water, Colors.cyan),
            const SizedBox(height: 12),
            _buildMetricTile("Light Intensity", "$lightIntensity lux", Icons.wb_sunny, Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2E3A59),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
