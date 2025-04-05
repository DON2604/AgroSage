import 'package:farm_genius/screens/dashboard/widgets/carbonfoot_dash.dart';
import 'package:farm_genius/screens/dashboard/widgets/market_trend.dart';
import 'package:farm_genius/screens/dashboard/widgets/sustain_dash.dart';
import 'package:farm_genius/screens/dashboard/widgets/water_usage_dash.dart';
import 'package:farm_genius/screens/dashboard/widgets/weather_dashboard.dart';
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
    return const Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          BackgroundImage(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 160),
                    GreetingWeather(),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: CarouselSection(),
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 626,
                        child: Padding(
                          padding: EdgeInsets.only(left:13.0),
                          child: ScrollableList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SidePanel(
                  widthFactor: 0.55,
                  verticalPadding: 20,
                  horizontalPadding: 16,
                  borderRadius: 20,
                  child: WaterUsageDash()), //change.....
            ],
          ),
        ],
      ),
    );
  }
}
