import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/locale_service.dart';
import 'package:my_app/services/user_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_page_header.dart';
import 'package:my_app/widgets/custom_button.dart';
import 'package:my_app/widgets/profile_menu_shell.dart';

class ProfileSettingsPage extends StatefulWidget {
  final ProfileSettingsArguments? arguments;

  const ProfileSettingsPage({super.key, this.arguments});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final UserService _userService = UserService.instance;
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  final LocaleService _localeService = LocaleService.instance;
  StreamSubscription<int>? _notificationSubscription;
  late final VoidCallback _localeListener;
  bool _isSavingName = false;
  bool _isSendingReset = false;
  bool _hasLoadedInitialName = false;
  String _language = 'en';
  int _unreadNotificationCount = 0;
  String? _userEmail;
  String _userRole = 'observer';
  String? _lastSavedName;

  bool get _isAdmin => _userRole == 'admin';

  String _localizedRole(AppLocalizations l10n) {
    switch (_userRole.toLowerCase()) {
      case 'admin':
        return l10n.profileRoleAdmin;
      case 'observer':
        return l10n.profileRoleObserver;
      default:
        return l10n.profileRoleUnknown;
    }
  }

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    _userEmail = widget.arguments?.userEmail ?? currentUser?.email;
    _userRole = widget.arguments?.userRole ?? 'observer';
    final initialName = currentUser?.displayName?.trim();
    if (initialName != null && initialName.isNotEmpty) {
      _nameController.text = initialName;
      _lastSavedName = initialName;
      _hasLoadedInitialName = true;
    }
    if (_isAdmin) {
      _startNotificationWatcher();
    }
    _language = _localeService.locale.languageCode;
    _localeListener = () {
      if (!mounted) return;
      final code = _localeService.locale.languageCode;
      if (code != _language) {
        setState(() => _language = code);
      }
    };
    _localeService.addListener(_localeListener);
    _loadProfile();
  }

  @override
  void dispose() {
    _localeService.removeListener(_localeListener);
    _notificationSubscription?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    void applyRecord(AppUserRecord? record) {
      if (!mounted || record == null) return;
      setState(() {
        _userRole = record.role;
        _userEmail ??= record.email;
        if (!_hasLoadedInitialName && (record.displayName?.isNotEmpty ?? false)) {
          _nameController.text = record.displayName!.trim();
          _lastSavedName = record.displayName!.trim();
          _hasLoadedInitialName = true;
        }
      });
    }

    final cached = _userService.getCachedUser(uid);
    if (cached != null) {
      applyRecord(cached);
    }

    try {
      final fresh = await _userService.getUserProfile(uid, forceRefresh: true);
      applyRecord(fresh);
    } catch (error) {
      debugPrint('Failed to load profile: $error');
    }
  }

  void _startNotificationWatcher() {
    _notificationSubscription = _notificationService
        .watchUnreadCount()
        .listen((count) {
      if (!mounted) return;
      setState(() => _unreadNotificationCount = count);
    }, onError: (error) => debugPrint('Failed to watch unread count: $error'));
  }

  Future<void> _saveDisplayName() async {
    final l10n = context.l10n;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _showSnack(
        l10n.profileReauthRequired,
        isError: true,
      );
      return;
    }
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      _showSnack(l10n.profileNameEmptyError, isError: true);
      return;
    }
    if (trimmedName == (_lastSavedName ?? '').trim()) {
      _showSnack(l10n.profileNothingToUpdate);
      return;
    }

    setState(() => _isSavingName = true);
    try {
      await _userService.updateDisplayName(uid: uid, displayName: trimmedName);
      if (mounted) {
        setState(() => _lastSavedName = trimmedName);
      }
      if (!mounted) return;
      _showSnack(l10n.profileNameUpdated);
    } catch (error) {
      debugPrint('Failed to update name: $error');
      if (!mounted) return;
      _showSnack(l10n.profileUpdateNameError, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSavingName = false);
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final l10n = context.l10n;
    final email = _userEmail;
    if (email == null || email.isEmpty) {
      _showSnack(l10n.profileNoEmailError, isError: true);
      return;
    }
    if (_isSendingReset) return;
    setState(() => _isSendingReset = true);
    try {
      await AuthService.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      _showSnack(l10n.profileResetLinkSent(email));
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnack(error.message, isError: true);
    } catch (error) {
      debugPrint('Failed to send password reset: $error');
      if (!mounted) return;
      _showSnack(l10n.profileResetFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSendingReset = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final l10n = context.l10n;
    try {
      await AuthService.instance.signOut();
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnack(error.message, isError: true);
      return;
    } catch (error) {
      debugPrint('Failed to sign out: $error');
      if (!mounted) return;
      _showSnack(l10n.profileLogoutError, isError: true);
      return;
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openProjectsPage() {
    Navigator.pushNamed(
      context,
      '/projects',
      arguments: ProjectListArguments(
        userEmail: _userEmail,
        userRole: _userRole,
      ),
    );
  }

  void _openObserverPage() {
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        userEmail: _userEmail,
        userRole: _userRole,
      ),
    );
  }

  void _openAdminPage() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin',
      arguments: AdminPageArguments(
        userEmail: _userEmail,
        userRole: _userRole,
      ),
    );
  }

  void _openNotificationsPage() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin-notifications',
      arguments: AdminNotificationsArguments(
        userEmail: _userEmail,
        userRole: _userRole,
      ),
    );
  }

  void _openProjectMap() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin-project-map',
      arguments: AdminProjectMapArguments(
        userEmail: _userEmail,
        userRole: _userRole,
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateLanguage(String code) async {
    setState(() => _language = code);
    await _localeService.setLocale(Locale(code));
  }

  bool get _canSaveName {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) return false;
    return trimmed != (_lastSavedName ?? '').trim();
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.gray200),
      ),
      padding: const EdgeInsets.all(4),
      child: ToggleButtons(
        isSelected: [
          _language == 'en',
          _language == 'nl',
        ],
        onPressed: (index) {
          final code = index == 0 ? 'en' : 'nl';
          _updateLanguage(code);
        },
        borderRadius: BorderRadius.circular(999),
        renderBorder: false,
        fillColor: AppTheme.white,
        selectedColor: AppTheme.primaryOrange,
        color: AppTheme.gray600,
        constraints: const BoxConstraints(minHeight: 36, minWidth: 110),
        children: [
          Text(context.l10n.languageEnglish),
          Text(context.l10n.languageDutch),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileMenuShell(
      userEmail: _userEmail,
      activeDestination: ProfileMenuDestination.profile,
      onLogout: _handleLogout,
      onObserverTap: _openObserverPage,
      onAdminTap: _isAdmin ? _openAdminPage : null,
      onProjectsTap: _openProjectsPage,
      onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
      onProjectMapTap: _isAdmin ? _openProjectMap : null,
      onProfileSettingsTap: () {},
      showAdminOption: _isAdmin,
      showNotificationsOption: _isAdmin,
      showProjectMapOption: _isAdmin,
      unreadNotificationCount: _isAdmin ? _unreadNotificationCount : 0,
      builder: (context, controller) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: Column(
                  children: [
                    AppPageHeader(
                      profileButtonKey: controller.profileButtonKey,
                      onProfileTap: controller.toggleMenu,
                      subtitle: context.l10n.profileSettingsTitle,
                      subtitleIcon: Icons.settings_outlined,
                      unreadNotificationCount:
                          _isAdmin ? _unreadNotificationCount : 0,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          AppTheme.pageGutter,
                          24,
                          AppTheme.pageGutter,
                          32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SettingsCard(
                              title: context.l10n.profileSectionTitle,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.profileNameLabel,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppTheme.gray700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 44,
                                            child: TextField(
                                              controller: _nameController,
                                              onChanged: (_) => setState(() {}),
                                              style: const TextStyle(fontSize: 14, color: AppTheme.gray900),
                                              decoration: InputDecoration(
                                                hintText: context.l10n.profileNameHint,
                                                hintStyle: const TextStyle(fontSize: 14, color: AppTheme.gray400),
                                                filled: true,
                                                fillColor: AppTheme.gray50,
                                                contentPadding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 12,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                                  borderSide: const BorderSide(color: AppTheme.gray300, width: 1),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                                  borderSide: const BorderSide(color: AppTheme.gray300, width: 1),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                                  borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 150,
                                          height: 44,
                                          child: IgnorePointer(
                                            ignoring: !_canSaveName || _isSavingName,
                                            child: AnimatedOpacity(
                                              duration: const Duration(milliseconds: 200),
                                              opacity: _canSaveName && !_isSavingName ? 1 : 0.4,
                                              child: CustomButton(
                                                text: context.l10n.profileSaveName,
                                                onPressed: _saveDisplayName,
                                                isLoading: _isSavingName,
                                                isFullWidth: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _ReadOnlyField(
                                  label: context.l10n.profileEmailLabel,
                                  value: _userEmail ??
                                      context.l10n.profileUnavailable,
                                ),
                                const SizedBox(height: 10),
                                _ReadOnlyField(
                                  label: context.l10n.profileRoleLabel,
                                  value: _localizedRole(context.l10n),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsCard(
                              title: context.l10n.profilePreferencesTitle,
                              children: [
                                Text(
                                  context.l10n.profileLanguagePreference,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.gray700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildLanguageToggle(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsCard(
                              title: context.l10n.profileSecurityTitle,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _isSendingReset
                                        ? null
                                        : _sendPasswordReset,
                                    icon: const Icon(Icons.lock_reset),
                                    label: Text(
                                      _isSendingReset
                                          ? context.l10n.profileSendingReset
                                          : context.l10n.profileChangePassword,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryOrange,
                                      side: const BorderSide(
                                        color: AppTheme.primaryOrange,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.borderRadiusLarge,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: _handleLogout,
                                  icon: const Icon(Icons.logout),
                                  label: Text(context.l10n.profileLogout),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.gray700,
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ],
                            ),
                            if (_isAdmin) ...[
                              const SizedBox(height: 12),
                              _SettingsCard(
                                title: context.l10n.profileShortcutsTitle,
                                children: [
                                  _SettingsTile(
                                    icon: Icons.shield_outlined,
                                    title: context.l10n.profileOpenAdminPanel,
                                    subtitle: context.l10n
                                        .profileAdminPanelSubtitle,
                                    onTap: _openAdminPage,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXL),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.gray50,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: AppTheme.gray200),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppTheme.primaryOrange,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppTheme.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.gray50,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: AppTheme.gray200),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray900,
            ),
          ),
        ),
      ],
    );
  }
}
