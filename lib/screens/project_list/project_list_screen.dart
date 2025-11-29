import 'package:flutter/material.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/screens/project_list/widgets/project_list_header.dart';
import 'package:my_app/screens/project_list/widgets/projects_panel.dart';
import 'package:my_app/screens/project_list/widgets/user_info_bar.dart';
import 'package:my_app/screens/project_list/widgets/welcome_section.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu.dart';

/// Project List screen matching the React UI design.
class ProjectListScreen extends StatefulWidget {
  final String? userEmail;

  const ProjectListScreen({super.key, this.userEmail});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Project> _projects = Project.getMockProjects();
  final GlobalKey _profileButtonKey = GlobalKey();
  bool _showProfileMenu = false;
  List<Project> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _filteredProjects = _projects;
    _searchController.addListener(_filterProjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProjects = _projects;
      } else {
        _filteredProjects = _projects.where((project) {
          return project.name.toLowerCase().contains(query) ||
              project.location.toLowerCase().contains(query) ||
              (project.description?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  String _getFirstName() {
    if (widget.userEmail == null) return 'Observer';
    final name = widget.userEmail!.split('@')[0];
    return name[0].toUpperCase() + name.substring(1);
  }

  void _handleRefresh() {
    debugPrint('Refreshing projects...');
  }

  void _handleProjectTap(Project project) {
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: project,
        userEmail: widget.userEmail,
      ),
    );
  }

  void _openObserverFromMenu() {
    final project = _projects.isNotEmpty ? _projects.first : null;
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: project,
        userEmail: widget.userEmail,
      ),
    );
  }

  void _openAdminPage() {
    Navigator.pushNamed(context, '/admin', arguments: widget.userEmail);
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _toggleProfileMenu() {
    setState(() => _showProfileMenu = !_showProfileMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: Column(
                  children: [
                    ProjectListHeader(
                      profileButtonKey: _profileButtonKey,
                      onProfileTap: _toggleProfileMenu,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: const [
                                  Divider(color: AppTheme.gray200, height: 1),
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
                  ],
                ),
              ),
            ),
          ),
          if (_showProfileMenu)
            ProfileMenu(
              profileButtonKey: _profileButtonKey,
              userEmail: widget.userEmail,
              onClose: () => setState(() => _showProfileMenu = false),
              onLogout: _handleLogout,
              onObserverTap: _openObserverFromMenu,
              onAdminTap: _openAdminPage,
              onProjectsTap: () {},
              activeDestination: ProfileMenuDestination.projects,
            ),
        ],
      ),
    );
  }
}
