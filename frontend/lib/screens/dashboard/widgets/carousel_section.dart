import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSection extends StatelessWidget {
  const CarouselSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 125,
        enlargeCenterPage: false,
        autoPlay: false,
        enableInfiniteScroll: false,
        viewportFraction: 0.25, 
        padEnds: false, 
      ),
      items: [
        _carouselItem("🕒 8:00 AM", "Watering of crops", "On-Progress",
            const Color.fromARGB(255, 148, 212, 95)),
        _carouselItem("🕒 10:00 AM", "Weed Removal", "Not-Started", Colors.white),
        _carouselItem("🕒 12:00", "Take a Break & Hydrate", "Not-Started",
            Colors.white),
        _carouselItem("🕒 4:00 PM", "Pack harvested crops", "Not-Started",
            Colors.white),
        _carouselItem("🕒 4:00 PM", "Pack harvested crops", "Not-Started",
            Colors.white),
      ],
    );
  }

  Widget _carouselItem(
      String head, String title, String progress, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  head,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 74, 73, 73)),
                  textAlign: TextAlign.right,
                )
              ],
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                    color: Color.fromARGB(255, 29, 28, 28),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: const EdgeInsets.all(1),
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.black12.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(progress,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13))),
            )
          ],
        ),
      ),
    );
  }
}
