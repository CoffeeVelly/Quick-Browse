import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';  // 导入随机库
import 'shortcut_app.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late String _logoPath; // 存储随机选择的 logo 路径

  @override
  void initState() {
    super.initState();
    
    // 随机选择 logo 图片路径
    _logoPath = _getRandomLogoPath();

    // 初始化动画控制器
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // 动画持续时间
      vsync: this,
    );

    // 创建动画：透明度渐变
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // 动画效果曲线
      ),
    );

    // 启动动画
    _controller.forward();

    // 延迟 3 秒后跳转到主页
    Timer(const Duration(seconds: 3), () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShortcutApp()), // 跳转到主页
      ));
  }

  // 随机选择 logo 图片路径
  String _getRandomLogoPath() {
    final random = Random();
    // 通过随机数选择 logo
    return random.nextBool() 
      ? 'assets/images/Quick_Browse_logo_1.jpg' 
      : 'assets/images/Quick_Browse_logo_2.jpg';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation, // 将透明度动画应用到背景
        child: Center(
          child: Image.asset(
            _logoPath, // 使用随机选择的 logo 路径
            width: double.infinity, // 使图片的宽度填满屏幕
            height: double.infinity, // 使图片的高度填满屏幕
            fit: BoxFit.cover, // 保持图片比例并填满屏幕
          ),
        ),
      ),
    );
  }
}
