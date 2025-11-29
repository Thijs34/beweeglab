import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/models/project.dart';

/// Project card widget matching React UI design
class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            border: Border.all(
              color: _isHovered ? AppTheme.primaryOrange : AppTheme.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.05),
                blurRadius: _isHovered ? 6 : 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Name
                    Text(
                      widget.project.name,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamilyHeading,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.project.location,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Description
                    if (widget.project.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.project.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron Icon
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: _isHovered ? AppTheme.primaryOrange : AppTheme.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
