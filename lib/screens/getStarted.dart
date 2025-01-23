import 'package:flutter/material.dart';

class Getstarted extends StatelessWidget {
  const Getstarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.5, // Maintain image aspect ratio
                child: Image.asset(
                  'assets/images/getstarted.jpg',
                  fit: BoxFit.cover, // Scale to fill container
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Experience the future of App Name',
                style: const TextStyle(
                  fontSize: 24, // Adjust based on font size preferences
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
