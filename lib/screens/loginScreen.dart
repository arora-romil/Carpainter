import 'package:carpainter/screens/homePage.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = ''; // Removed unused variable
  String _otp = '';
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
    }
  }

  void _verifyOtp() {
    if (_otp.isNotEmpty) {
      if (_otp == '123456') {
        // Replace with your actual verification logic
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  hintText: 'Enter your 10-digit phone number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
                onChanged: (value) {}, // Removed unused onChanged callback
              ),
              const SizedBox(height: 20),
              if (_isOtpSent)
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'OTP',
                    hintText: 'Enter OTP',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _otp = value;
                  },
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : (_isOtpSent
                          ? const Text('Verify OTP')
                          : const Text('Send OTP')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
