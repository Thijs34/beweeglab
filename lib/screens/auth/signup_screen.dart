import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/auth/auth_brand_header.dart';
import 'package:my_app/widgets/auth/auth_form_card.dart';
import 'package:my_app/widgets/auth/auth_form_layout.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/widgets/custom_text_field.dart';

/// Sign Up screen matching the React UI SignUp component.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    Navigator.pushNamed(
      context,
      '/projects',
      arguments: _emailController.text.isNotEmpty
          ? _emailController.text
          : null,
    );
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandHeader(),
            const SizedBox(height: 32),
            AuthFormCard(
              child: Column(
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamilyHeading,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'First Name',
                    placeholder: 'Enter your first name',
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Last Name',
                    placeholder: 'Enter your last name',
                    controller: _lastNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    placeholder: 'your.email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    placeholder: 'Create a password',
                    controller: _passwordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    placeholder: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.orange50,
                      border: Border.all(color: AppTheme.orange200, width: 1),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusLarge,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 20,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray700,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                  text: 'New accounts are assigned the ',
                                ),
                                TextSpan(
                                  text: 'Observer role',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text:
                                      ' by default. Admin privileges must be granted by the database owner.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
                  children: [
                    const TextSpan(text: "Already have an account? "),
                    WidgetSpan(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _navigateToLogin,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
