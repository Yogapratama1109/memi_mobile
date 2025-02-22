import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final bool showError;
  final VoidCallback? togglePasswordVisibility;
  final bool isPasswordVisible;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isPassword,
    required this.showError,
    this.togglePasswordVisibility,
    this.isPasswordVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            obscureText: isPassword ? !isPasswordVisible : false,
            keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: togglePasswordVisibility,
                    )
                  : null,
              errorText: showError ? "Invalid email format" : null,
            ),
          ),
        ],
      ),
    );
  }
}
