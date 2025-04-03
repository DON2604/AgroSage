import 'package:flutter/material.dart';
import './widgets/background_image.dart';
import './widgets/carousel_section.dart';
import './widgets/greeting_weather.dart';
import './widgets/scrollable_list.dart';
import './widgets/side_panel.dart'; 

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const BackgroundImage(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
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
              ),
              const SidePanel(
                widthFactor: 0.55,
                verticalPadding: 20,
                horizontalPadding: 16,
                borderRadius: 20,
                child: Text("sjdfghjgdfjkas",style: TextStyle(color: Colors.black),),//sample ke liye hata dena🫡🫡
                // child: idhar lagao apna dashboard,
              ),
            ],
          ),
        ],
      ),
    );
  }
}