import 'package:flutter/material.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/auth/auth_brand_header.dart';
import 'package:my_app/widgets/auth/auth_form_card.dart';
import 'package:my_app/widgets/auth/auth_form_layout.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/widgets/custom_text_field.dart';

/// Login screen matching the React UI Login component.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return; // all fields must be valid

    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final credential = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      final role = uid != null
          ? await AuthService.instance.getUserRole(uid)
          : 'observer';

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/projects',
        arguments: ProjectListArguments(
          userEmail: credential.user?.email ?? email,
          userRole: role,
        ),
      );
    } on AuthException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (_) {
      setState(
        () => _errorMessage = 'Unable to login right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final dialogEmailController =
        TextEditingController(text: _emailController.text.trim());
    String? dialogError;
    bool isSending = false;

    final didSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Reset password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter the email linked to your account. We will send a reset link if an account exists.',
                    style: TextStyle(fontSize: 13, color: AppTheme.gray600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dialogEmailController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      dialogError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final requestEmail =
                              dialogEmailController.text.trim();
                          if (requestEmail.isEmpty) {
                            setDialogState(
                              () => dialogError =
                                  'Please enter the email tied to your account.',
                            );
                            return;
                          }

                          setDialogState(() {
                            dialogError = null;
                            isSending = true;
                          });

                          final navigator = Navigator.of(dialogContext);
                          try {
                            await AuthService.instance
                                .sendPasswordResetEmail(email: requestEmail);
                            if (!navigator.mounted) return;
                            navigator.pop(true);
                          } on AuthException catch (error) {
                            setDialogState(() {
                              dialogError = error.message;
                              isSending = false;
                            });
                          } catch (_) {
                            setDialogState(() {
                              dialogError =
                                  'Unable to send reset email. Please try again.';
                              isSending = false;
                            });
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send link'),
                ),
              ],
            );
          },
        );
      },
    );

    final requestedEmail = dialogEmailController.text.trim();
    dialogEmailController.dispose();

    if (didSend == true) {
      _showLoginSnack(
        'If an account exists for $requestedEmail, a reset link is on the way.',
      );
    }
  }

  void _showLoginSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildErrorMessageSlot() {
    return SizedBox(
      height: 32,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchOutCurve: Curves.easeInOut,
        switchInCurve: Curves.easeInOut,
        child: _errorMessage == null
            ? const SizedBox.shrink(key: ValueKey('login-error-empty'))
            : Align(
                key: const ValueKey('login-error-active'),
                alignment: Alignment.centerLeft,
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormLayout(
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
                    'Login',
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
                    label: 'Email',
                    placeholder: 'your.email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Email is required';
                      }
                      if (!text.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    placeholder: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _handleForgotPassword,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Login',
                    onPressed: _handleLogin,
                    isLoading: _isSubmitting,
                  ),
                  const SizedBox(height: 12),
                  _buildErrorMessageSlot(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
                    WidgetSpan(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _navigateToSignUp,
                          child: const Text(
                            'Sign Up',
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
