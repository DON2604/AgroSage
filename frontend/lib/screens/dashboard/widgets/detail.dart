import 'package:flutter/material.dart';

class Detail1 extends StatefulWidget {
  @override
  _Detail1 createState() => _Detail1();
}

class _Detail1 extends State<Detail1> {
  double Moisture=12;
  double soilPh=15;
  double Temperatue=35;
  double CropYield=50;
  double fertilizers=20;
  double pesticides=10;

  @override
  Widget build(BuildContext context) {
    return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Container(
                        height:98,
                        width:250,
                        
                        padding:EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60))
                              ],
                            ),
                            SizedBox(width:5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontSize: 17))
                          
                              ],
                            ),
                            //Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60)),//no. of fields
                            //SizedBox(width:10),
                            //Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontStyle:FontStyle.italic,fontSize: 17))
                          ]
                        )
                      ),
                      SizedBox(height:15),
                      Container(
                        height:98,
                        width:250,
                        
                        padding:EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Text("$soilPh",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60))
                              ],
                            ),
                            SizedBox(width:5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text("Soil pH",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontSize: 17))
                          
                              ],
                            ),
                            //Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60)),//no. of fields
                            //SizedBox(width:10),
                            //Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontStyle:FontStyle.italic,fontSize: 17))
                          ]
                        )
                      ),
                      
                    ],
                  ),
                  
                  Column(
                    children: [
                      Container(
                        height:98,
                        width:250,
                        
                        padding:EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Text("$pesticides",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60))
                              ],
                            ),
                            SizedBox(width:5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text("Pesticide",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontSize: 17))
                          
                              ],
                            ),
                            //Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60)),//no. of fields
                            //SizedBox(width:10),
                            //Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontStyle:FontStyle.italic,fontSize: 17))
                          ]
                        )
                      ),
                      
                      SizedBox(height:10),
                      Container(
                        height:98,
                        width:250,
                        
                        padding:EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Text("$fertilizers",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60))
                              ],
                            ),
                            SizedBox(width:5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text("Fertilizers",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontSize: 17))
                          
                              ],
                            ),
                            //Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60)),//no. of fields
                            //SizedBox(width:10),
                            //Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontStyle:FontStyle.italic,fontSize: 17))
                          ]
                        )
                      ),
                      

                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height:98,
                        width:250,
                        
                        padding:EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Text("$Temperatue K",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60))
                              ],
                            ),
                            SizedBox(width:5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text("Temperature",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontSize: 17))
                          
                              ],
                            ),
                            //Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60)),//no. of fields
                            //SizedBox(width:10),
                            //Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontStyle:FontStyle.italic,fontSize: 17))
                          ]
                        )
                      ),
                      
                      SizedBox(height:10),
                      Container(
                        height:98,
                        width:250,
                        
                        padding:EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              children: [
                                Text("$CropYield",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60))
                              ],
                            ),
                            SizedBox(width:5),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text("Crop Yield",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontSize: 17))
                          
                              ],
                            ),
                            //Text("$Moisture%",style:TextStyle(color:Colors.green,fontWeight: FontWeight.bold,fontSize: 60)),//no. of fields
                            //SizedBox(width:10),
                            //Text("Moisture",style:TextStyle(color:const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold,fontStyle:FontStyle.italic,fontSize: 17))
                          ]
                        )
                      ),
                    ]
                  )
                ]
    );
  }
}