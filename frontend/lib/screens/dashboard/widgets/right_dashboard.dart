import 'package:farm_genius/screens/dashboard/widgets/activity_pie.dart';
import 'detail.dart';
import 'package:farm_genius/screens/dashboard/widgets/chart2.dart';
import 'package:farm_genius/screens/dashboard/widgets/detail.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';


class RightDashboard extends StatelessWidget {
  const RightDashboard({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromARGB(245, 235, 234, 234)


      ),
      child:Column(
        children: [
          Text(
            "Dashboard",
            style:GoogleFonts.barlow(
                  fontSize: 32,
                  color: Colors.black
                  )
          ),
          SizedBox(height: 20),
          Detail1(),
              
          
                      

                    
                  
                  
                  
                  
                
              SizedBox(height:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: [
                     //LineChartWidget(),
                     SizedBox(width: 2),
                     HomePage2()
                 ]
                ),
              ]
    )

        
      

    );
  }
}