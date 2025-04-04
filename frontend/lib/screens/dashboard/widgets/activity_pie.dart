import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage2 extends StatelessWidget {
  HomePage2({Key? key}) : super(key: key);

  final dataMap = <String, double>{
    "score":7
  };
  int total=10;
  int score_per=70;

  final colorList = <Color>[
    const Color.fromARGB(255, 8, 210, 82),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(15) ),
        height:300,
        width:300,
        padding: EdgeInsets.all(10),
        
        child:Column(
          children: [
            Text("Sustainability Score",style: TextStyle(fontSize: 15,color:Colors.black,fontWeight:FontWeight.bold),),
            SizedBox(height:2),
            Container(
              height:200,
              width:200,
              child: PieChart(
                centerWidget: Container(
                  height:75,
                  child:Center(
                    child: Column(
                    children: [
                      Text("$score_per%",style:TextStyle(color:Colors.black,fontSize:35,fontWeight: FontWeight.bold)),
                      Text("Sustainability",style:TextStyle(color:Color.fromARGB(255, 6, 101, 25),fontSize:15,fontWeight: FontWeight.bold))
                
                    ],
                    ),
                  ) 
                  ),
                ringStrokeWidth: 15,
                dataMap: dataMap,
                chartType: ChartType.disc,
                baseChartColor: const Color.fromARGB(255, 229, 237, 10),
                colorList: colorList,
                legendOptions: LegendOptions(
                showLegendsInRow: true,
                legendPosition: LegendPosition.bottom,
                showLegends: false,
                legendShape:BoxShape.circle ,
                legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,fontSize: 12,color:Colors.black
                ),
                        ),
                        chartValuesOptions: ChartValuesOptions(
              showChartValuesInPercentage: true,
                        ),
                        totalValue: 10,
              
                      ),
            ),
          ],
        ),
        
      );
  }
}