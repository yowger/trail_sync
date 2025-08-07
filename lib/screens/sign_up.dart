import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:trail_sync/screens/auth_header.dart';

import 'package:trail_sync/widgets/custom_button.dart';
import 'package:trail_sync/widgets/custom_form_text_field.dart';
import 'package:trail_sync/widgets/text_divider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final focusEmail = FocusNode();
  final focusPassword = FocusNode();
  final focusConfirmPassword = FocusNode();

  bool isPasswordVisible = false;

  void _validateAndSignUp() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    debugPrint("Registering: ${emailController.text}");
  }

  void _signUpWithGoogle() {
    print("Sign up with Google");
  }

  void _signUpWithFacebook() {
    print("Sign up with Facebook");
  }

  void _signUpWithTwitter() {
    print("Sign up with Twitter");
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    focusEmail.dispose();
    focusPassword.dispose();
    focusConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('LOGO HERE'),
                  const AuthHeader(text: 'Create your Trail Sync account'),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomFormTextField(
                      controller: emailController,
                      focusNode: focusEmail,
                      hintText: 'Email',
                      icon: Icons.email,
                      obscure: false,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setStateSB) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomFormTextField(
                          controller: passwordController,
                          focusNode: focusPassword,
                          hintText: 'Password',
                          icon: Icons.key,
                          obscure: true,
                          isPasswordVisible: isPasswordVisible,
                          onToggleVisibility: () {
                            setStateSB(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomFormTextField(
                      controller: confirmPasswordController,
                      focusNode: focusConfirmPassword,
                      hintText: 'Confirm Password',
                      icon: Icons.lock,
                      obscure: true,
                      isPasswordVisible: false,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomButton(
                      text: 'Sign Up',
                      onPressed: _validateAndSignUp,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextDivider(label: 'Or continue with'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: _signUpWithGoogle,
                        borderRadius: BorderRadius.circular(100),
                        child: Brand(Brands.google),
                      ),
                      InkWell(
                        onTap: _signUpWithFacebook,
                        borderRadius: BorderRadius.circular(100),
                        child: Brand(Brands.facebook),
                      ),
                      InkWell(
                        onTap: _signUpWithTwitter,
                        borderRadius: BorderRadius.circular(100),
                        child: Brand(Brands.twitter),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _HaveAccount(onTap: () => context.goNamed('sign_in')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HaveAccount extends StatelessWidget {
  final VoidCallback onTap;
  const _HaveAccount({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?  ",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              "Login",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
