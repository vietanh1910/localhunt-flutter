// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Bỏ các import không dùng ở đây
import 'screens/splash_screen.dart'; // Import splash screen
import 'screens/login_screen.dart'; // Import màn hình login

// Hàm main() là điểm khởi đầu của ứng dụng
Future<void> main() async {
  // Đảm bảo các binding của Flutter đã sẵn sàng trước khi chạy các tác vụ async
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase (nếu bạn dùng đăng nhập Google/Facebook)
  // Bạn cần cấu hình file firebase_options.dart cho đúng
  // await Firebase.initializeApp();

  // Chạy widget gốc của ứng dụng
  runApp(const MyApp());
}

// MyApp là widget gốc, không có trạng thái
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Phương thức build sẽ xây dựng giao diện của widget này
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Hunt', // Đổi tên app từ Hunter Point thành Local Hunt
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Đây là nơi bạn định nghĩa theme chung cho toàn bộ ứng dụng
        primarySwatch: Colors.purple, // Đổi thành purple để match với splash screen
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // Đảm bảo bạn đã thêm font này vào pubspec.yaml
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade400)
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade400)
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      // Bắt đầu với splash screen thay vì login page
      home: const AppWrapper(),
    );
  }
}

// Widget wrapper để quản lý việc chuyển đổi giữa splash screen và main app
class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;

  void _onSplashFinished() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onFinished: _onSplashFinished);
    }
    
    // Sau khi splash screen kết thúc, chuyển đến login page
    return const LoginPage();
  }
}