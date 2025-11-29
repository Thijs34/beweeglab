import 'package:flutter/material.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/empty_state.dart';
import 'package:my_app/widgets/project_card.dart';

class ProjectsPanel extends StatelessWidget {
  final List<Project> projects;
  final List<Project> filteredProjects;
  final TextEditingController searchController;
  final ValueChanged<Project> onProjectTap;
  final VoidCallback onRefresh;

  const ProjectsPanel({
    super.key,
    required this.projects,
    required this.filteredProjects,
    required this.searchController,
    required this.onProjectTap,
    required this.onRefresh,
  });

  bool get _hasSearchQuery => searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: AppTheme.gray200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            _ProjectsPanelHeader(
              projectCount: projects.length,
              onRefresh: onRefresh,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  if (filteredProjects.isNotEmpty)
                    ...List.generate(
                      filteredProjects.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index < filteredProjects.length - 1 ? 10 : 0,
                        ),
                        child: ProjectCard(
                          project: filteredProjects[index],
                          onTap: () => onProjectTap(filteredProjects[index]),
                        ),
                      ),
                    )
                  else if (_hasSearchQuery)
                    const EmptyStateMessage(
                      icon: Icons.search,
                      title: 'No projects found',
                      subtitle: 'Try adjusting your search terms',
                    )
                  else
                    const EmptyStateMessage(
                      icon: Icons.assignment_outlined,
                      title: 'No Projects Assigned',
                      subtitle:
                          "You don't have any observation projects assigned yet.\nPlease contact your administrator to get access to projects.",
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: searchController,
        style: const TextStyle(fontSize: 14, color: AppTheme.gray900),
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: const TextStyle(fontSize: 14, color: AppTheme.gray400),
          prefixIcon: const Icon(
            Icons.search,
            size: 16,
            color: AppTheme.gray400,
          ),
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
            borderSide: const BorderSide(
              color: AppTheme.primaryOrange,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectsPanelHeader extends StatelessWidget {
  final int projectCount;
  final VoidCallback onRefresh;

  const _ProjectsPanelHeader({
    required this.projectCount,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.gray200, width: 1)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Projects',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamilyHeading,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$projectCount ${projectCount == 1 ? 'project' : 'projects'} available',
                style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
              ),
            ],
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, size: 16, color: AppTheme.gray500),
            tooltip: 'Refresh projects',
          ),
        ],
      ),
    );
  }
}
