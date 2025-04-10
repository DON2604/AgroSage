import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final String apiBaseUrl = 'https://dd0a-45-112-68-139.ngrok-free.app/api';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PostmanRuntime/7.36.0',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.pop(context); // Go back to login screen after successful registration
      } else {
        setState(() {
          _errorMessage = data['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Center(
                child: SingleChildScrollView(
                  child: _buildRegisterForm(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.white,
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
          controller: _nameController,
          style: const TextStyle(color: Colors.black),
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
          controller: _emailController,
          style: const TextStyle(color: Colors.black),
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
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Register",
                      style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ],
    );
  }
}
