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
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentDashboardIndex = 0;
  
  final List<Widget> _dashboards = const [
    CarbonFootprintDashboard(),
    MarketTrendDashboard(),
    WaterUsageDashboard(),
    RightDashboard(), 
    SustainabilityDashboard(),
  ];
  
  final List<String> _dashboardTitles = const [
    "Carbon Footprint",
    "Market Trends",
    "Water Usage",
    "Weather Forecast",
    "Sustainability",
  ];

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
                    Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: CarouselSection(),
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 700,
                        child: Padding(
                          padding: EdgeInsets.only(left: 13.0),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _dashboardTitles[_currentDashboardIndex],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, size: 18),
                                onPressed: _currentDashboardIndex > 0 
                                  ? () {
                                      _carouselController.previousPage();
                                    }
                                  : null,
                                color: _currentDashboardIndex > 0 ? Colors.black54 : Colors.grey.withOpacity(0.3),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                                onPressed: _currentDashboardIndex < _dashboards.length - 1 
                                  ? () {
                                      _carouselController.nextPage();
                                    }
                                  : null,
                                color: _currentDashboardIndex < _dashboards.length - 1 ? Colors.black54 : Colors.grey.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: double.infinity,
                          viewportFraction: 1.0,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentDashboardIndex = index;
                            });
                          },
                        ),
                        items: _dashboards.map((dashboard) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: dashboard,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: _currentDashboardIndex,
                        count: _dashboards.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Theme.of(context).primaryColor,
                          dotColor: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
