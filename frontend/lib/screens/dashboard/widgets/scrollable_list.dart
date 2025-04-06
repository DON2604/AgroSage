import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ScrollableList extends StatelessWidget {
  const ScrollableList({super.key});

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
  Widget build(BuildContext context) {
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
        itemCount: crops.length,
        itemBuilder: (context, index, realIndex) {
          final crop = crops[index];
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
}
