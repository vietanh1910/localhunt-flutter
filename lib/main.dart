// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Bỏ các import không dùng ở đây
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
      title: 'Hunter Point', // Đổi tên app của bạn
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Đây là nơi bạn định nghĩa theme chung cho toàn bộ ứng dụng
        primarySwatch: Colors.blue,
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
      // Màn hình đầu tiên mà người dùng nhìn thấy khi mở app
      home: const LoginPage(),
    );
  }
}