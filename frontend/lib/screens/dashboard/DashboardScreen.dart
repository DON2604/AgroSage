import 'package:flutter/material.dart';
import './widgets/background_image.dart';
import './widgets/carousel_section.dart';
import './widgets/greeting_weather.dart';
import './widgets/scrollable_list.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BackgroundImage(),
          Column(
            children: [
              SizedBox(height: 160),
              GreetingWeather(),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 626,
                  child: CarouselSection(),
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 626,
                  child: ScrollableList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
