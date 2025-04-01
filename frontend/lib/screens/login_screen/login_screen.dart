import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool rememberMe = false;
  bool otpSent = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        phoneController.text = prefs.getString('phoneNumber') ?? '';
      }
    });
  }

  void _onRememberMeChanged(bool? value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = value ?? false;
    });

    if (rememberMe) {
      prefs.setString('phoneNumber', phoneController.text);
    } else {
      prefs.remove('phoneNumber');
    }
    prefs.setBool('rememberMe', rememberMe);
  }

  void _sendOtp() {
    setState(() {
      otpSent = true;
    });
    print("OTP sent to: ${phoneController.text}");
  }

  void _verifyOtp() {
    print("Verifying OTP: ${otpController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
        Positioned.fill(
          child: Image.asset('assets/bg.png',
          fit:BoxFit.cover,
          )),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/farm_logo.png', height: 80),
              const SizedBox(height:7),
              const Text(
                'FarmGenius AI',
                style: TextStyle(fontSize: 24,color:Colors.black87, fontWeight: FontWeight.bold),
              ),
              
              const Text(
                'Smarter Farming, Greener Planet',
                style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 191, 211, 90),fontWeight:FontWeight.bold,fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
        
              /// **Phone Number Input**
              TextField(
                inputFormatters:[FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number, 
                controller: phoneController,
                //keyboardType: TextInputType.phone,
        
                decoration: const InputDecoration(
                  hintText: "Enter Phone Number",
                  filled: true,
                  fillColor: Color.fromARGB(255, 177, 224, 176),
                  
                  
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: Text(
                      "+91",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 50, minHeight: 0),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 183, 209, 198), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
        
              /// **Send OTP Button**
              ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Send OTP",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
        
              /// **OTP Input Field (Only visible after OTP is sent)**
              if (otpSent)
                Column(
                  children: [
                    TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter OTP",
                        filled: true,
                        fillColor: Color.fromARGB(255, 177, 224, 176),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2D6A4F), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
        
              /// **Remember Me Checkbox**
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    activeColor: const Color(0xFF2D6A4F),
                    onChanged: _onRememberMeChanged,
                  ),
                  const Text("Remember Me", style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 237, 241, 235))),
                ],
              ),
              const SizedBox(height: 20),
        
              /// **Get Started Button**
              ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        ]
      ),
    );
  }
}
