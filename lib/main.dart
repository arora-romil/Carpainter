import 'package:carpainter/screens/carpenter/homePage.dart';
import 'package:carpainter/screens/auth/phoneNumber.dart';
import 'package:carpainter/screens/carpenter/registrationScreen.dart';
import 'package:carpainter/screens/splashScreen.dart';
import 'package:carpainter/screens/auth/verifyOtp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: 'splashScreen',
        routes: {
          'phone': (context) => const PhoneNumberScreen(),
          'splashScreen': (context) => SplashScreen(),
          'verify': (context) => const VerifyOtpScreen(),
          'home': (context) => const HomePage(),
          'registration': (context) => RegistrationScreen(),
        },
      ),
    );
  }
}
