import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:authen/screens/reward_screen.dart';
import 'package:authen/screens/main_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          filled: false,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // === CÁC BIẾN QUẢN LÝ ===
  // true: Hiển thị form đăng nhập, false: Hiển thị form đăng ký
  bool _isLoginView = true;

  // Keys cho 2 form khác nhau để validate riêng biệt
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Controllers cho các ô nhập liệu
  final _emailController = TextEditingController(text: "loisbecket@gmail.com");
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Controller cho confirm password

  // Trạng thái hiển thị mật khẩu
  bool _isPasswordVisible = false;

  // Dữ liệu mẫu để đăng nhập
  final String _correctEmail = "loisbecket@gmail.com";
  final String _correctPasswordHash =
      "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f";


  // === CÁC HÀM XỬ LÝ LOGIC ===

  // Hàm băm mật khẩu
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Hàm xử lý đăng nhập
  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (_loginFormKey.currentState!.validate()) {
      final enteredEmail = _emailController.text.trim().toLowerCase();
      final enteredPassword = _passwordController.text.trim();

      if (enteredEmail != _correctEmail) {
        // ... (giữ nguyên logic báo lỗi)
      } else if (_hashPassword(enteredPassword) != _correctPasswordHash) {
        // ... (giữ nguyên logic báo lỗi)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green),
        );

        // SỬA ĐỔI: Điều hướng đến MainScreen thay vì RewardScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    }
  }

  // *** HÀM MỚI: Xử lý đăng ký ***
  void _handleSignUp() {
    FocusScope.of(context).unfocus();
    if (_signUpFormKey.currentState!.validate()) {
      // Logic đăng ký ở đây (ví dụ: gọi API, lưu vào database...)
      // Hiện tại chỉ hiển thị thông báo thành công
      final enteredEmail = _emailController.text.trim().toLowerCase();
      print('Đăng ký với Email: $enteredEmail');
      print('Mật khẩu: (bảo mật, không in ra)');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng ký tài khoản thành công!'),
            backgroundColor: Colors.green),
      );
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Hủy controller mới
    super.dispose();
  }

  // === CÁC HÀM XÂY DỰNG GIAO DIỆN PHỤ ===

  // *** HÀM MỚI: Xây dựng giao diện form đăng nhập ***
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [ Checkbox(value: false, onChanged: (v) {}), const Text('Remember me')]),
              TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleLogin,
            child: const Text('Log In', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // *** HÀM MỚI: Xây dựng giao diện form đăng ký ***
  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Ô nhập lại mật khẩu
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible, // Đồng bộ hiển thị với ô mật khẩu
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (value != _passwordController.text) return 'Mật khẩu không khớp';
              return null;
            },
          ),
          const SizedBox(height: 24), // Tăng khoảng cách thay cho phần remember/forgot
          ElevatedButton(
            onPressed: _handleSignUp,
            child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }


  // === GIAO DIỆN CHÍNH (BUILD METHOD) ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Text('Menu')),
            ListTile(title: Text('Mục 1')),
            ListTile(title: Text('Mục 2')),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: const [
                            Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'Logoipsum',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text('Get Started now', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Create an account or log in to explore about our app', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // *** CỤM NÚT ĐIỀU KHIỂN ĐÃ ĐƯỢC CẬP NHẬT ***
                          Container(
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!_isLoginView) {
                                      setState(() {
                                        _isLoginView = true;
                                      });
                                    }
                                  },
                                  child: const Text('Log In'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLoginView ? Colors.white : Colors.grey.shade200,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: _isLoginView ? 2 : 0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                    onPressed: () {
                                      if (_isLoginView) {
                                        setState(() {
                                          _isLoginView = false;
                                        });
                                      }
                                    },
                                    child: const Text('Sign Up'),
                                    style: TextButton.styleFrom(
                                      backgroundColor: !_isLoginView ? Colors.white : Colors.transparent,
                                      foregroundColor: Colors.grey.shade600,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    )),
                              )
                            ]),
                          ),

                          // *** HIỂN THỊ FORM TƯƠNG ỨNG VỚI TRẠNG THÁI ***
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLoginView ? _buildLoginForm() : _buildSignUpForm(),
                          ),

                          const SizedBox(height: 24),
                          Row(children: [
                            const Expanded(child: Divider()),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('Or', style: TextStyle(color: Colors.grey.shade600))),
                            const Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: 24),

                          SignInButton(
                            Buttons.google,
                            text: "Continue with Google",
                            onPressed: () {},
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SignInButton(
                            Buttons.facebookNew,
                            text: "Continue with Facebook",
                            onPressed: () {},
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}