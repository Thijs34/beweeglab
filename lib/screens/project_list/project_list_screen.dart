import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/screens/project_list/widgets/projects_panel.dart';
import 'package:my_app/screens/project_list/widgets/user_info_bar.dart';
import 'package:my_app/screens/project_list/widgets/welcome_section.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/project_selection_service.dart';
import 'package:my_app/services/project_service.dart';
import 'package:my_app/services/user_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_page_header.dart';
import 'package:my_app/widgets/profile_menu_shell.dart';

/// Project List screen matching the React UI design.
class ProjectListScreen extends StatefulWidget {
  final String? userEmail;
  final String userRole;

  const ProjectListScreen({
    super.key,
    this.userEmail,
    this.userRole = 'observer',
  });

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Project> _projects = const [];
  List<Project> _filteredProjects = const [];
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  final ProjectService _projectService = ProjectService.instance;
  final ProjectSelectionService _selectionService =
      ProjectSelectionService.instance;
  final UserService _userService = UserService.instance;
  StreamSubscription<int>? _notificationCountSubscription;
  StreamSubscription<List<Project>>? _projectsSubscription;
  VoidCallback? _selectionListener;
  int _unreadNotificationCount = 0;
  bool _isLoadingProjects = true;
  bool _isRefreshingProjects = false;
  String? _projectsError;
  String? _displayName;

  bool get _isAdmin => widget.userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProjects);
    _startProjectsWatcher();
    if (_isAdmin) {
      _startNotificationWatcher();
    }
    _loadUserProfile();
    _selectionListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _selectionService.selectedProjectListenable.addListener(
      _selectionListener!,
    );
  }

  @override
  void dispose() {
    _notificationCountSubscription?.cancel();
    _projectsSubscription?.cancel();
    _searchController.dispose();
    if (_selectionListener != null) {
      _selectionService.selectedProjectListenable.removeListener(
        _selectionListener!,
      );
    }
    super.dispose();
  }

  void _startProjectsWatcher() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoadingProjects = false;
        _projectsError = 'Please sign in again to load your projects.';
      });
      return;
    }

    _projectsSubscription?.cancel();
    _projectsSubscription = _projectService
        .watchObserverProjects(uid)
        .listen(
          (projects) {
            if (!mounted) return;
            _selectionService.syncWithProjects(projects);
            setState(() {
              _projects = projects;
              _filteredProjects = _applyProjectFilter(
                projects,
                _searchController.text,
              );
              _isLoadingProjects = false;
              _projectsError = null;
            });
          },
          onError: (error) {
            debugPrint('Failed to watch projects: $error');
            if (!mounted) return;
            setState(() {
              _isLoadingProjects = false;
              _projectsError =
                  'Something went wrong while loading your projects.';
            });
          },
        );
  }

  void _startNotificationWatcher() {
    _notificationCountSubscription = _notificationService
        .watchUnreadCount()
        .listen(
          (count) {
            if (!mounted) return;
            setState(() => _unreadNotificationCount = count);
          },
          onError: (error) =>
              debugPrint('Failed to watch unread count: $error'),
        );
  }

  void _loadUserProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final authDisplayName = FirebaseAuth.instance.currentUser?.displayName
        ?.trim();
    if (authDisplayName != null && authDisplayName.isNotEmpty) {
      setState(() => _displayName = authDisplayName);
    }

    void applyRecord(AppUserRecord? record) {
      if (!mounted || record == null) {
        return;
      }
      final preferred = (record.displayName?.trim().isNotEmpty ?? false)
          ? record.displayName!.trim()
          : record.email;
      if (preferred == null || preferred == _displayName) {
        return;
      }
      setState(() => _displayName = preferred);
    }

    final cached = _userService.getCachedUser(uid);
    var needsRefresh = true;
    if (cached != null) {
      applyRecord(cached);
      needsRefresh =
          (cached.displayName == null ||
          (cached.displayName?.trim().isEmpty ?? true));
    }

    _userService
        .getUserProfile(uid, forceRefresh: needsRefresh)
        .then(applyRecord)
        .catchError((error) => debugPrint('Failed to load user name: $error'));
  }

  void _filterProjects() {
    setState(() {
      _filteredProjects = _applyProjectFilter(
        _projects,
        _searchController.text,
      );
    });
  }

  List<Project> _applyProjectFilter(List<Project> projects, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List<Project>.from(projects);
    }
    return projects
        .where((project) {
          final name = project.name.toLowerCase();
          final location = project.mainLocation.toLowerCase();
          final description = project.description?.toLowerCase() ?? '';
          return name.contains(normalizedQuery) ||
              location.contains(normalizedQuery) ||
              description.contains(normalizedQuery);
        })
        .toList(growable: false);
  }

  String _getFirstName() {
    final name = _displayName?.trim();
    if (name == null || name.isEmpty) {
      return 'Observer';
    }
    return name;
  }

  void _handleRefresh() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _isRefreshingProjects) {
      return;
    }
    setState(() => _isRefreshingProjects = true);
    _projectService
        .fetchObserverProjects(uid)
        .then((projects) {
          if (!mounted) return;
          _selectionService.syncWithProjects(projects);
          setState(() {
            _projects = projects;
            _filteredProjects = _applyProjectFilter(
              projects,
              _searchController.text,
            );
            _projectsError = null;
          });
        })
        .catchError((error) {
          debugPrint('Manual refresh failed: $error');
          if (!mounted) return;
          setState(() {
            _projectsError =
                'Unable to refresh projects right now. Please try again.';
          });
        })
        .whenComplete(() {
          if (mounted) {
            setState(() => _isRefreshingProjects = false);
          }
        });
  }

  void _handleProjectTap(Project project) {
    _selectionService.setActiveProject(project);
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: project,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openObserverFromMenu() {
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: _selectionService.currentProject,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openAdminPage() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin',
      arguments: AdminPageArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openNotificationsPage() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin-notifications',
      arguments: AdminNotificationsArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openProjectMap() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin-project-map',
      arguments: AdminProjectMapArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _handleLogout() async {
    try {
      await AuthService.instance.signOut();
    } on AuthException catch (error) {
      _showLogoutError(error.message);
      return;
    } catch (error) {
      debugPrint('Failed to sign out: $error');
      _showLogoutError('Unable to logout right now. Please try again.');
      return;
    }

    _selectionService.clearSelection();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _showLogoutError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileMenuShell(
      userEmail: widget.userEmail,
      activeDestination: ProfileMenuDestination.projects,
      onLogout: _handleLogout,
      onObserverTap: _openObserverFromMenu,
      onAdminTap: _isAdmin ? _openAdminPage : null,
      onProjectsTap: () {},
      onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
      onProjectMapTap: _isAdmin ? _openProjectMap : null,
      showAdminOption: _isAdmin,
      showNotificationsOption: _isAdmin,
      showProjectMapOption: _isAdmin,
      unreadNotificationCount: _isAdmin ? _unreadNotificationCount : 0,
      builder: (context, controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      AppPageHeader(
                        profileButtonKey: controller.profileButtonKey,
                        onProfileTap: controller.toggleMenu,
                        subtitle: 'Field Observation System',
                        unreadNotificationCount: _isAdmin
                            ? _unreadNotificationCount
                            : 0,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppTheme.pageGutter,
                              8,
                              AppTheme.pageGutter,
                              0,
                            ),
                            child: Column(
                              children: [
                                UserInfoBar(
                                  userEmail: widget.userEmail,
                                  onLogout: _handleLogout,
                                ),
                                Container(height: 1, color: AppTheme.gray200),
                                WelcomeSection(firstName: _getFirstName()),
                                ProjectsPanel(
                                  projects: _projects,
                                  filteredProjects: _filteredProjects,
                                  searchController: _searchController,
                                  onProjectTap: _handleProjectTap,
                                  onRefresh: _handleRefresh,
                                  isLoading: _isLoadingProjects,
                                  isRefreshing: _isRefreshingProjects,
                                  errorMessage: _projectsError,
                                  selectedProjectId:
                                      _selectionService.currentProject?.id,
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    AppTheme.pageGutter,
                                    16,
                                    AppTheme.pageGutter,
                                    16,
                                  ),
                                  child: Column(
                                    children: const [
                                      Divider(
                                        color: AppTheme.gray200,
                                        height: 1,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Need help? Contact your administrator for support',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.gray400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
