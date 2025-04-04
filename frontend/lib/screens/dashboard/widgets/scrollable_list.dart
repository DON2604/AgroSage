import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ScrollableList extends StatelessWidget {
  const ScrollableList({super.key});

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
          viewportFraction: 1
        ),
        itemCount: 30,
        itemBuilder: (context, index, realIndex) {
          return SizedBox(
            width: cardSize,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  SizedBox(width: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),

                      height:150,
                      width:150,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
              image: AssetImage("assets/asset1.png"),
              fit: BoxFit.cover,
            ),
                      borderRadius:BorderRadius.circular(20),
                      border: Border.all(color: Colors.black) 
                    ),
                    //child: Image.asset('assets/asset1.png'),
                  ),
                  SizedBox(width:2),
                  
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      const SizedBox(height: 10),
                      Text(
                        "Olive Fields",//name of any cropssss
                        style:GoogleFonts.poppins(
                        color: Color.fromARGB(255, 48, 153, 41), fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      Text("Harvest on Day ${index + 1} ", textAlign: TextAlign.center),
                      Row(
                        children: [
                          Icon(
                            size:25,
                            Icons.energy_savings_leaf_rounded,
                            color: Color.fromARGB(255, 48, 153, 41),),
                          Text(
                        "Rs 7500/kg",
                        style:GoogleFonts.poppins(
                        color: Color.fromARGB(255, 48, 153, 41), fontWeight: FontWeight.bold, fontSize: 16),)
                        ],
                      )
                      
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}