import 'package:flutter/material.dart';
import 'package:tactical_pad/views/pitch/tactical_pad_screen.dart';
// import 'package:tactical_pad/views/pitch/components/pitch_painter.dart';

class MyDuolingo extends StatelessWidget {
  const MyDuolingo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        // '/': (context) => PitchPainter(),
        '/': (context) => TacticalPad(),
        // '/login': (context) => const LoginScreen(),
        // '/choose-language': (context) => const ChooseLanguageScreen(),
        // '/home': (context) => const HomeScreen(),
        // '/subscription': (context) => SubscriptionScreen(),
        // '/intro': (context) => IntroductoryScreen(),
        // '/add_question': (context) => AddQuestionScreen()
      },
      debugShowCheckedModeBanner: false,
      title: 'PLP Tactical Board',
      // home: const WelcomeScreen(),
    );
  }
}
