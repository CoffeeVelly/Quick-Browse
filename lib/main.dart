import 'package:flutter/material.dart';
import 'package:quick_browse/splash_screen.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 设置窗口大小
  setWindowMinSize(Size(1200, 800));  // 设置最小窗口大小
  setWindowMaxSize(Size(1200, 800));  // 设置最大窗口大小
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Outfit',
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: SplashScreen(),
    );
  }
}