import 'package:flutter/material.dart';

class ScrollableList extends StatelessWidget {
  const ScrollableList({super.key});

  @override
  Widget build(BuildContext context) {
    double cardSize = MediaQuery.of(context).size.width * 0.5; 

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.centerLeft, 
          child: SizedBox(
            width: cardSize,
            height: 200, 
            child: Card(
              color: Colors.white, 
              margin: const EdgeInsets.only(bottom: 7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Image.asset('assets/asset1.png', width: 50, height: 50, fit: BoxFit.cover),
                  const SizedBox(height: 10), // Spacing
                  Text(
                    "Day ${index + 1}",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const Text("Practice Sustainable Farming", textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
