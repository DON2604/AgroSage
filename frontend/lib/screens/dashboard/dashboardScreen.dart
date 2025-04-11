import 'package:farm_genius/screens/colab_screen/colab_screen.dart';
import 'package:farm_genius/screens/dashboard/widgets/carbonfoot_dash.dart';
import 'package:farm_genius/screens/dashboard/widgets/dynamic_data_card.dart';
import 'package:farm_genius/screens/dashboard/widgets/market_trend.dart';
import 'package:farm_genius/screens/dashboard/widgets/sustain_dash.dart';
import 'package:farm_genius/screens/dashboard/widgets/water_usage_dash.dart';
import 'package:farm_genius/screens/dashboard/widgets/weather_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/background_image.dart';
import './widgets/carousel_section.dart';
import './widgets/greeting_weather.dart';
import './widgets/scrollable_list.dart';
import './widgets/side_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  int _currentDashboardIndex = 0;

  final List<Widget> _dashboards = const [
    CarbonFootprintDashboard(),
    MarketTrendDashboard(),
    WaterUsageDashboard(),
    RightDashboard(),
    SustainabilityDashboard(),
  ];

  String _username = '';
  bool _showSocialAppWidget = false; // State to toggle SidePanel content

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('userName') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const BackgroundImage(),
          Positioned(
            top: 20,
            left: 20,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _showSocialAppWidget ? Icons.dashboard : Icons.people,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSocialAppWidget = !_showSocialAppWidget;
                    });
                  },
                ),
                Text(
                  _showSocialAppWidget ? 'Switch to Dashboard' : 'Switch to Social',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 160),
                    const GreetingWeather(),
                    const SizedBox(height: 20),
                    // Always show the carousel section
                    const Padding(
                      padding: EdgeInsets.only(left: 13),
                      child: CarouselSection(),
                    ),
                    const SizedBox(height: 15),
                    // Conditionally show either ScrollableList or DynamicDataCard
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width:600,
                        child: Padding(
                          padding: EdgeInsets.only(left: 13.0),
                          child: _showSocialAppWidget
                              ? const ScrollableList()
                              : const SizedBox(
                                  height: 225,
                                  child: DynamicDataCard(),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: SidePanel(
                      widthFactor: 0.55,
                      verticalPadding: 20,
                      horizontalPadding: 16,
                      borderRadius: 20,
                      child: _showSocialAppWidget
                          ? SocialAppWidget(username: _username)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                // Horizontal timeline of dots
                                Center(
                                  child: SizedBox(
                                    height: 40,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Line
                                        Positioned.fill(
                                          top: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 24),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  top: BorderSide(
                                                    color: const Color.fromARGB(
                                                            189, 12, 134, 3)
                                                        .withOpacity(0.4),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Dots
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: List.generate(
                                              _dashboards.length, (index) {
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _currentDashboardIndex =
                                                      index;
                                                  _pageController
                                                      .jumpToPage(index);
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _currentDashboardIndex == index
                                                          ? const Color
                                                                  .fromARGB(
                                                              255, 5, 121, 9)
                                                          : Colors.white,
                                                  border: Border.all(
                                                    color: _currentDashboardIndex == index
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : const Color.fromARGB(
                                                                255, 35, 140, 6)
                                                            .withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                                width: 15,
                                                height: 15,
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // PageView instead of CarouselSlider
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentDashboardIndex = index;
                                      });
                                    },
                                    itemCount: _dashboards.length,
                                    itemBuilder: (context, index) {
                                      return _dashboards[index];
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
