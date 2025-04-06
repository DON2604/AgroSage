import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboardScreen.dart'; // Import the DashboardScreen

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool isRegistering = false; // Track whether the user is on the register screen

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email');
    final savedPassword = prefs.getString('password');
    final savedRemember = prefs.getBool('rememberMe') ?? false;

    if (savedRemember) {
      _emailController.text = savedEmail ?? '';
      _passwordController.text = savedPassword ?? '';
    }
    setState(() {
      rememberMe = savedRemember;
    });
  }

  Future<void> saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('email', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  void handleLogin() async {
    await saveCredentials();
    // Navigate to DashboardScreen after login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  void toggleRegister() {
    setState(() {
      isRegistering = !isRegistering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color to white
      body: Row(
        children: [
          // Left side (Login/Register form)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Center(
                child: SingleChildScrollView(
                  child: isRegistering ? _buildRegisterForm() : _buildLoginForm(),
                ),
              ),
            ),
          ),

          // Right side (Background image)
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white, // Set the right side background to white
              child: Image.asset(
                'assets/bg.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.local_florist, color: Colors.green),
            SizedBox(width: 8),
            Text("AgroSage",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
        const SizedBox(height: 40),
        const Text("Welcome Back!",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        const Text("Please Log in to your account.",
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 30),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.black), // Set text color to black
          decoration: const InputDecoration(
            labelText: "Email Address",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.black), // Set text color to black
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  rememberMe = value!;
                });
              },
            ),
            const Text("Remember me"),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text("Forgot password?",
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
              ),
              child: const Text("Login",style: TextStyle(color: Colors.white),),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: toggleRegister, // Switch to the register form
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
              child: const Text("Create account"),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          "By signing up you agree to our terms and that you have read our data policy.",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        )
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.local_florist, color: Colors.green),
            SizedBox(width: 8),
            Text("AgroSage",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
        const SizedBox(height: 40),
        const Text("Create an Account",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        const SizedBox(height: 10),
        const Text("Please fill in the details to register.",
            style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 30),
        TextField(
          style: const TextStyle(color: Colors.black), // Set text color to black
          decoration: const InputDecoration(
            labelText: "Full Name",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          style: const TextStyle(color: Colors.black), // Set text color to black
          decoration: const InputDecoration(
            labelText: "Email Address",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          style: const TextStyle(color: Colors.black), // Set text color to black
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle registration logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration attempted')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
              ),
              child: const Text("Register"),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: toggleRegister, // Switch back to the login form
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ],
    );
  }
}
