import 'package:flutter/material.dart';
import 'package:tactical_pad/views/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyDuolingo());

  // runApp(MultiProvider(
  //   providers: [
  //     ChangeNotifierProvider(create: (_) => UserInfoProvider()),
  //     ChangeNotifierProvider(create: (_) => QuestionProvider()),
  //     ChangeNotifierProvider(create: (_) => UserProgressProvider()),
  //   ],
  //   child: MyDuolingo(),
  // ));
}
