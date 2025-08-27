// --- CÁC GÓI IMPORT CẦN THIẾT ---
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'main_screen.dart'; // Import màn hình chính

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // === CÁC BIẾN QUẢN LÝ ===
  bool _isLoginView = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;

  // === CÁC HÀM XỬ LÝ LOGIC ===

  // HÀM XỬ LÝ ĐĂNG NHẬP GOOGLE
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // Người dùng đã hủy đăng nhập

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        _navigateToMainScreen(
            "Đăng nhập Google thành công: ${userCredential.user!.displayName}");
      }
    } catch (e) {
      _showErrorSnackBar("Đã xảy ra lỗi khi đăng nhập Google: ${e.toString()}");
    }
  }

  // HÀM XỬ LÝ ĐĂNG NHẬP FACEBOOK
  Future<void> _handleFacebookSignIn() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null && mounted) {
          _navigateToMainScreen(
              "Đăng nhập Facebook thành công: ${userCredential.user!.displayName}");
        }
      } else {
        _showErrorSnackBar("Đăng nhập Facebook thất bại: ${result.message}");
      }
    } catch (e) {
      _showErrorSnackBar(
          "Đã xảy ra lỗi khi đăng nhập Facebook: ${e.toString()}");
    }
  }

  // === CÁC HÀM TIỆN ÍCH ===

  void _navigateToMainScreen(String successMessage) {
    print(successMessage);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  // Các hàm đăng nhập/đăng ký bằng email (chưa hoàn thiện)
  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (_loginFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Chức năng đang phát triển')));
    }
  }

  void _handleSignUp() {
    FocusScope.of(context).unfocus();
    if (_signUpFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Chức năng đang phát triển')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // === CÁC WIDGET GIAO DIỆN ===

  Widget _buildLoginForm() {
    return Form( key: _loginFormKey, child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24), TextFormField( controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập email'; if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ'; return null; }, ), const SizedBox(height: 16), TextFormField( controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration( labelText: 'Password', suffixIcon: IconButton( icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible), ), ), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu'; return null; }, ), const SizedBox(height: 16), Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Row(children: [ Checkbox(value: false, onChanged: (v) {}), const Text('Remember me')]), TextButton(onPressed: () {}, child: const Text('Forgot Password?')), ], ), const SizedBox(height: 24), ElevatedButton( onPressed: _handleLogin, child: const Text('Log In', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), ), ], ), );
  }

  Widget _buildSignUpForm() {
    return Form( key: _signUpFormKey, child: Column( crossAxisAlignment: CrossAxisAlignment.stretch, children: [ const SizedBox(height: 24), TextFormField( controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập email'; if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Email không hợp lệ'; return null; }, ), const SizedBox(height: 16), TextFormField( controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration( labelText: 'Password', suffixIcon: IconButton( icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible), ), ), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu'; if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự'; return null; }, ), const SizedBox(height: 16), TextFormField( controller: _confirmPasswordController, obscureText: !_isPasswordVisible, decoration: const InputDecoration(labelText: 'Confirm Password'), validator: (value) { if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu'; if (value != _passwordController.text) return 'Mật khẩu không khớp'; return null; }, ), const SizedBox(height: 24), ElevatedButton( onPressed: _handleSignUp, child: const Text('Sign Up', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom( padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), ), ), ], ), );
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
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Builder( builder: (context) => IconButton( icon: const Icon(Icons.menu, color: Colors.white, size: 30), onPressed: () => Scaffold.of(context).openDrawer(), ), ), const SizedBox(height: 20), const Row( children: [ Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 28), SizedBox(width: 8), Text( 'Logoipsum', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), ), ], ), const SizedBox(height: 30), const Text('Get Started now', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)), const SizedBox(height: 10), const Text('Create an account or log in to explore about our app', style: TextStyle(color: Colors.white70, fontSize: 16)), ], ),
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
                            onPressed: _handleGoogleSignIn,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          const SizedBox(height: 16),
                          SignInButton(
                            Buttons.facebookNew,
                            text: "Continue with Facebook",
                            onPressed: _handleFacebookSignIn,
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