import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:trail_sync/providers/auth_provider.dart';
import 'package:trail_sync/widgets/custom_button.dart';
import 'package:trail_sync/widgets/custom_form_text_field.dart';
import 'package:trail_sync/features/auth/widgets/auth_header.dart';
import 'package:trail_sync/widgets/floating_snackbar.dart';
import 'package:trail_sync/widgets/text_divider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _validateAndLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      context.goNamed('home');
    } on FirebaseAuthException catch (error) {
      String errorMessage;

      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Contact support.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection.';
          break;
        default:
          errorMessage = error.message ?? 'Authentication failed.';
          break;
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      showFloatingSnackBar(context, errorMessage);
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      showFloatingSnackBar(context, 'An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loginWithGoogle() {
    print("Login with Google");
  }

  void _loginWithFacebook() {
    print("Login with Facebook");
  }

  void _loginWithTwitter() {
    print("Login with Twitter");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _focusEmail.dispose();
    _focusPassword.dispose();
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
                  const AuthHeader(text: 'Sign in to Trail Sync'),
                  const SizedBox(height: 44),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomFormTextField(
                      controller: _emailController,
                      focusNode: _focusEmail,
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

                  // Password field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomFormTextField(
                      controller: _passwordController,
                      focusNode: _focusPassword,
                      hintText: 'Password',
                      icon: Icons.key,
                      obscure: !_isPasswordVisible,
                      isPasswordVisible: _isPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomButton(
                      text: _isLoading ? 'Logging in...' : 'Login',
                      onPressed: _validateAndLogin,
                      isDisabled: _isLoading,
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
                        onTap: _loginWithGoogle,
                        borderRadius: BorderRadius.circular(100),
                        child: Brand(Brands.google),
                      ),
                      InkWell(
                        onTap: _loginWithFacebook,
                        borderRadius: BorderRadius.circular(100),
                        child: Brand(Brands.facebook),
                      ),
                      InkWell(
                        onTap: _loginWithTwitter,
                        borderRadius: BorderRadius.circular(100),
                        child: Brand(Brands.twitter),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _HaveAccount(onTap: () => context.goNamed('sign_up')),
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
            "Don't have an account?  ",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              "Sign up",
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
