import 'package:farm_genius/screens/register_screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/dashboardScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  final String apiBaseUrl = 'https://accenture-hack.onrender.com/api';

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

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await saveCredentials();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', data['name']);
        await prefs.setInt('userId', data['user_id']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
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

  void handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password are required';
      });
      return;
    }

    await _login();
  }

  void toggleRegister() {
    setState(() {
      isRegistering = !isRegistering;
    });
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
                  child: isRegistering
                      ? const RegisterScreen()
                      : LoginForm(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          rememberMe: rememberMe,
                          isLoading: _isLoading,
                          errorMessage: _errorMessage,
                          onLogin: handleLogin,
                          onToggleRegister: toggleRegister,
                          onRememberMeChanged: (value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
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
}
