import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../api/auth_api.dart';
import '../components/input/text_field.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmailValid = true;
  bool _hasTypedEmail = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validateForm);
  }

  void _validateEmail() {
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    setState(() {
      _hasTypedEmail = _emailController.text.isNotEmpty;
      _isEmailValid =
          emailRegExp.hasMatch(_emailController.text) || !_hasTypedEmail;
    });
  }

  void _validateForm() {
    setState(() {});
  }

  void _showErrorAlert(String message) {
    toastification.show(
      context: context,
      title: Text("Error"),
      style: ToastificationStyle.fillColored,
      description: Text(message),
      type: ToastificationType.error,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  void _showSuccessAlert(String message) {
    toastification.show(
      context: context,
      title: Text("Success"),
      style: ToastificationStyle.fillColored,
      description: Text(message),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await AuthAPI.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response["success"]) {
      final userData = response["data"];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('X-USER-MEMO', userData["user_id"].toString());

      _showSuccessAlert("Login successful! Welcome.");

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    } else {
      _showErrorAlert(response["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 120), // Logo
            const SizedBox(height: 24),
            CustomTextField(
              label: "Email",
              controller: _emailController,
              isPassword: false,
              showError: !_isEmailValid && _hasTypedEmail,
            ),
            CustomTextField(
              label: "Password",
              controller: _passwordController,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              togglePasswordVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              showError: false,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _isEmailValid &&
                            _passwordController.text.isNotEmpty &&
                            !_isLoading
                        ? _login
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isEmailValid && _passwordController.text.isNotEmpty
                          ? const Color(0xFFCBA851)
                          : const Color.fromARGB(255, 200, 200, 200),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
