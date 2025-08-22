import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:authen/services/auth_api.dart';
import 'package:authen/screens/main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginView = true;
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==== LOGIN ====
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await AuthApi.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (result['ok'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Đăng nhập thất bại'), backgroundColor: Colors.red),
      );
    }
  }

  // ==== SIGN UP (demo) ====
  void _handleSignUp() {
    if (!_signUpFormKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký thành công (demo)!'), backgroundColor: Colors.green),
    );
  }

  // ==== FORM LOGIN ====
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Log In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==== FORM SIGNUP ====
  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập email';
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Email không hợp lệ';
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
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible,
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (v != _passwordController.text) return 'Mật khẩu không khớp';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSignUp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==== UI ====
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
                            Text('Logoipsum',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text('Get Started now',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text(
                          'Create an account or log in to explore about our app',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Switch login/signup
                          Container(
                            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _isLoginView = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isLoginView ? Colors.white : Colors.grey.shade200,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: _isLoginView ? 2 : 0,
                                  ),
                                  child: const Text('Log In'),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() => _isLoginView = false),
                                  style: TextButton.styleFrom(
                                    backgroundColor: !_isLoginView ? Colors.white : Colors.transparent,
                                    foregroundColor: Colors.grey.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Sign Up'),
                                ),
                              ),
                            ]),
                          ),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isLoginView ? _buildLoginForm() : _buildSignUpForm(),
                          ),

                          const SizedBox(height: 24),
                          Row(children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('Or', style: TextStyle(color: Colors.grey.shade600)),
                            ),
                            const Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: 24),

                          SignInButton(Buttons.google, text: "Continue with Google", onPressed: () {}),
                          const SizedBox(height: 16),
                          SignInButton(Buttons.facebookNew, text: "Continue with Facebook", onPressed: () {}),
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
