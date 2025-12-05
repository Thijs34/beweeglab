import 'package:flutter/material.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/l10n/l10n.dart';
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
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isSubmitting) return;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final displayName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    try {
      final credential = await AuthService.instance.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName.isEmpty ? null : displayName,
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
        () => _errorMessage =
            'Unable to create an account right now. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthFormLayout(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
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
                  Text(
                    l10n.signupTitle,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamilyHeading,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: l10n.signupFirstNameLabel,
                    placeholder: l10n.signupFirstNamePlaceholder,
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.signupLastNameLabel,
                    placeholder: l10n.signupLastNamePlaceholder,
                    controller: _lastNameController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.signupEmailLabel,
                    placeholder: l10n.signupEmailPlaceholder,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return l10n.signupEmailRequired;
                      }
                      if (!text.contains('@')) {
                        return l10n.signupEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.signupPasswordLabel,
                    placeholder: l10n.signupPasswordPlaceholder,
                    controller: _passwordController,
                    isPassword: true,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) {
                        return l10n.signupPasswordRequired;
                      }
                      if (text.length < 6) {
                        return l10n.signupPasswordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: l10n.signupPasswordConfirmLabel,
                    placeholder: l10n.signupPasswordConfirmPlaceholder,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return l10n.signupPasswordConfirmRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: l10n.signupSubmit,
                    onPressed: _handleSignUp,
                    isLoading: _isSubmitting,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
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
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.gray700,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: l10n.signupRoleInfoPrefix),
                                TextSpan(
                                  text: l10n.signupRoleName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: l10n.signupRoleInfoSuffix),
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
                    TextSpan(text: l10n.signupAlreadyHaveAccountPrefix),
                    WidgetSpan(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _navigateToLogin,
                          child: Text(
                            l10n.signupLoginCta,
                            style: const TextStyle(
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
