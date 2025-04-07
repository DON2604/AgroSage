import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onLogin;
  final VoidCallback onToggleRegister;
  final ValueChanged<bool?> onRememberMeChanged;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.errorMessage,
    required this.onLogin,
    required this.onToggleRegister,
    required this.onRememberMeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
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
          controller: emailController,
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
          controller: passwordController,
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
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              activeColor: Colors.green,
              onChanged: onRememberMeChanged,
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
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Row(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("Login", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: onToggleRegister,
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
}
