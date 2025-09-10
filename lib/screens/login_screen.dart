// File: lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthLib;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_button/sign_in_button.dart';

// Import các file cần thiết
import 'main_screen.dart';
import '../services/auth_api.dart'; // Giả sử bạn có API service
import '../models/user.dart';      // Import model User của bạn

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginView = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // === CÁC HÀM XỬ LÝ LOGIC ===

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if(mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final FirebaseAuthLib.AuthCredential credential = FirebaseAuthLib.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuthLib.FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _authenticateWithBackend(userCredential);
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi đăng nhập Google: ${e.toString()}");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final credential = FirebaseAuthLib.FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCredential = await FirebaseAuthLib.FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          await _authenticateWithBackend(userCredential);
        }
      } else {
        _showErrorSnackBar("Đăng nhập Facebook thất bại: ${result.message}");
      }
    } catch (e) {
      _showErrorSnackBar("Lỗi đăng nhập Facebook: ${e.toString()}");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticateWithBackend(FirebaseAuthLib.UserCredential userCredential) async {
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) return;

    final String idToken = await firebaseUser.getIdToken(true) ?? "";

    // ---- PHẦN GIẢ LẬP CHO ĐẾN KHI BẠN CÓ API ----
    final Map<String, dynamic> result = {
      'ok': true,
      'token': 'your_backend_jwt_token_here',
      'user': User(
        // SỬA TẠI ĐÂY: Dùng một số giả lập thay vì firebaseUser.uid (String)
          id: 0,
          fullName: firebaseUser.displayName ?? "No Name",
          email: firebaseUser.email ?? "no-email@example.com",
          points: 100 // ví dụ
      )
    };
    // ---- KẾT THÚC PHẦN GIẢ LẬP ----

    if (result['ok'] == true && mounted) {
      final String token = result['token'];
      final User user = result['user'];

      _showErrorSnackBar('Đăng nhập thành công!');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen(loginToken: token, user: user)),
      );
    } else if(mounted) {
      _showErrorSnackBar(result['error'] ?? 'Lỗi xác thực với server');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // ... (Phần code còn lại của bạn không thay đổi) ...

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (_loginFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng đang phát triển')));
    }
  }

  void _handleSignUp() {
    FocusScope.of(context).unfocus();
    if (_signUpFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng đang phát triển')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildLoginForm() {
    return Form( key: _loginFormKey, child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24), TextFormField( controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập email'; if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ'; return null; }, ), const SizedBox(height: 16), TextFormField( controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration( labelText: 'Password', suffixIcon: IconButton( icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible), ), ), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu'; return null; }, ), const SizedBox(height: 16), Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Row(children: [ Checkbox(value: false, onChanged: (v) {}), const Text('Remember me')]), TextButton(onPressed: () {}, child: const Text('Forgot Password?')), ], ), const SizedBox(height: 24), ElevatedButton( onPressed: _isLoading ? null : _handleLogin, child: _isLoading ? const SizedBox(width:24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) : const Text('Log In', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), ), ], ), );
  }

  Widget _buildSignUpForm() {
    return Form( key: _signUpFormKey, child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24), TextFormField( controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập email'; if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ'; return null; }, ), const SizedBox(height: 16), TextFormField( controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration( labelText: 'Password', suffixIcon: IconButton( icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible), ), ), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu'; if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự'; return null; }, ), const SizedBox(height: 16), TextFormField( controller: _confirmPasswordController, obscureText: !_isPasswordVisible, decoration: const InputDecoration(labelText: 'Confirm Password'), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu'; if (value != _passwordController.text) return 'Mật khẩu không khớp'; return null; }, ), const SizedBox(height: 24), ElevatedButton( onPressed: _isLoading ? null : _handleSignUp, child: const Text('Sign Up', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), ), ], ), );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer( child: ListView( padding: EdgeInsets.zero, children: const [ DrawerHeader(decoration: BoxDecoration(color: Colors.blue), child: Text('Menu')), ListTile(title: Text('Mục 1')), ListTile(title: Text('Mục 2')), ], ), ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration( image: DecorationImage( image: AssetImage("assets/images/background.jpg"), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken), ), ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Builder( builder: (context) => IconButton( icon: const Icon(Icons.menu, color: Colors.white, size: 30), onPressed: () => Scaffold.of(context).openDrawer(), ), ), const SizedBox(height: 20), const Row( children: [ Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 28), SizedBox(width: 8), Text( 'Hunter Point', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), ), ], ), const SizedBox(height: 30), const Text('Get Started now', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)), const SizedBox(height: 10), const Text('Create an account or log in to explore our app', style: TextStyle(color: Colors.white70, fontSize: 16)), ], ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration( color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)), ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _isLoginView = true),
                                  child: const Text('Log In'),
                                  style: ElevatedButton.styleFrom( backgroundColor: _isLoginView ? Colors.white : Colors.grey.shade200, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 16), elevation: _isLoginView ? 2 : 0, ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                    onPressed: () => setState(() => _isLoginView = false),
                                    child: const Text('Sign Up'),
                                    style: TextButton.styleFrom( backgroundColor: !_isLoginView ? Colors.white : Colors.transparent, foregroundColor: Colors.grey.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 16), )),
                              )
                            ]),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLoginView ? _buildLoginForm() : _buildSignUpForm(),
                          ),
                          const SizedBox(height: 24),
                          Row(children: [ const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('Or', style: TextStyle(color: Colors.grey.shade600))), const Expanded(child: Divider()), ]),
                          const SizedBox(height: 24),
                          SignInButton(
                            Buttons.google,
                            text: "Continue with Google",
                            onPressed: _isLoading ? (){} : _handleGoogleSignIn,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          const SizedBox(height: 16),
                          SignInButton(
                            Buttons.facebookNew,
                            text: "Continue with Facebook",
                            onPressed: _isLoading ? (){} : _handleFacebookSignIn,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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