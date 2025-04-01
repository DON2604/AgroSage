import 'package:flutter/material.dart';
import 'package:farm_genius/widgets/carousal_slider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 🌿 **Dynamic Data (Can be updated in real-time)**
  double moisture = 45.0;
  double soilPh = 6.5;
  double temperature = 16;
  double humidity = 60.0;
  String getCurrentDate() {
    return DateFormat('dd MMMM yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Ensures image fills the top
      body: Stack(
        children: [
          /// **1️⃣ Background Image (Farm)**
          Positioned.fill(
            child: Image.asset(
              'assets/asset1.png',
              fit: BoxFit.cover,
              
            ),
          ),

          /// **2️⃣ UI Structure**
          Column(
            children: [
              const SizedBox(height: 2),
              //location box
              const SizedBox(height: 100),
              const SizedBox(height: 5),
              Row(
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 18),
                        child: Text(
                          "Hi,Good Morning.....",
                          style: TextStyle(fontSize: 25, color: Color.fromARGB(255, 244, 241, 241)),
                        ),
                      ),
                      Text(
                        "16.0°C",
                        style: const TextStyle(fontSize: 75,color: Color.fromARGB(255, 255, 255, 255), letterSpacing: -3.5,),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.water_drop,
                              color: Color.fromARGB(255, 227, 229, 230)),
                          Text(
                            "${moisture.toStringAsFixed(1)}%",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Container(
                              child: Row(
                            children: [
                              const Icon(Icons.air_rounded,
                                  color: Color.fromARGB(255, 154, 196, 230)),
                              Text(
                                "${humidity.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          )),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(width: 25),
                  Column(
                    children: [
                      const Text("☁️ Partly Cloudy",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700,color: Color.fromARGB(255, 228, 230, 230))),
                      _buildDate()
                    ],
                  )
                ],
              ),

              //_buildTopStats(),
              const SizedBox(height: 20),

              /// **3️⃣ Carousel**

              CarouselSliderWidget(),

              const SizedBox(height: 7),

              /// **4️⃣ Scrollable List**
              Expanded(
                child: Container(
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(234, 236, 229, 1),
                        borderRadius: BorderRadius.circular(15)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            SizedBox(width: 7),
                            Text(
                              "Our Agriculture Field",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 160),
                            Text("View Map",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(255, 29, 94, 206))),
                            SizedBox(width: 2),
                          ],
                        ),
                        Expanded(child: _buildScrollableList()),
                      ],
                    )),
              ),
              _bottomNavBar()
            ],
          ),
        ],
      ),

      /// **5️⃣ Floating Navigation Bar**
    );
  }

  Widget _buildDate() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Text(
        getCurrentDate(), // 🗓️ Fetch and display current date
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 250, 250, 250)),
      ),
    );
  }

  /// **Top Stats UI**
  Widget _buildTopStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard("Moisture", "${moisture.toStringAsFixed(1)}%",
                  Icons.water_drop, const Color.fromARGB(255, 11, 114, 199)),
              _statCard("Soil pH", soilPh.toStringAsFixed(1), Icons.science,
                  Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statCard("Temp", "${temperature.toStringAsFixed(1)}°C",
                  Icons.thermostat, Colors.red),
              _buildDate(),
              _statCard("Humidity", "${humidity.toStringAsFixed(1)}%",
                  Icons.cloud, const Color.fromARGB(255, 103, 104, 176)),
            ],
          )
        ],
      ),
    );
  }

  /// **Reusable Stat Box**
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 2),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 19, 17, 17))),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 28, 13, 13))),
      ],
    );
  }

  /// **Scrollable List (Dynamic)**
  Widget _buildScrollableList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      itemCount: 30, // Example count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 7),
          child: ListTile(
            minTileHeight: 50,
            tileColor:
                const Color.fromARGB(255, 236, 234, 230).withOpacity(0.5),
            leading: Image.asset('assets/bg.png'),
            title: Text("Day ${index + 1}"),
            subtitle: const Text("Practice Sustainable Farming"),
          ),
        );
      },
    );
  }

  Widget _bottomNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 19, 18, 18),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 132, 124, 124).withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: const Icon(Icons.home, size: 32, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.search, size: 32, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.notifications,
                    size: 32, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.person, size: 32, color: Colors.white),
                onPressed: () {}),
          ],
        ),
      ),
    );
  }

  /// **🔄 Function to Update Stats (Simulated)**
  void _updateStats() {
    setState(() {
      moisture = (40 + (10 * _randomFactor()));
      soilPh = (6.0 + (1.0 * _randomFactor()));
      temperature = (25 + (10 * _randomFactor()));
      humidity = (50 + (20 * _randomFactor()));
    });
  }

  /// **📊 Random Factor for Data Change**
  double _randomFactor() {
    return (0.5 + (0.5 * (DateTime.now().millisecondsSinceEpoch % 10) / 10));
  }
}
