import 'package:flutter/material.dart';

class NodeCommunicationAnimation extends StatelessWidget {
  const NodeCommunicationAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header with gradient text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
            ).createShader(bounds),
            child: const Text(
              'Agent Communication Network',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Divider with gradient
          Container(
            height: 2.0,
            width: 100.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          // Animation with border
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SizedBox(
              width: 480,
              child: Image.asset(
                'assets/agent.gif',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Description text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Visualizing real-time communication between AgroSage AI agents as they collaborate to provide agricultural insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
