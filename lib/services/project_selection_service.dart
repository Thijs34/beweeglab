import 'package:flutter/foundation.dart';
import 'package:my_app/models/project.dart';

/// Simple in-memory store for tracking the active observer project selection.
class ProjectSelectionService {
  ProjectSelectionService._();

  static final ProjectSelectionService instance = ProjectSelectionService._();

  final ValueNotifier<Project?> _selectedProject = ValueNotifier<Project?>(null);

  ValueListenable<Project?> get selectedProjectListenable => _selectedProject;

  Project? get currentProject => _selectedProject.value;

  void setActiveProject(Project? project) {
    _selectedProject.value = project;
  }

  void clearSelection() {
    setActiveProject(null);
  }

  bool isSelected(String projectId) {
    return _selectedProject.value?.id == projectId;
  }

  /// Keeps the currently selected project in sync with the latest Firestore data.
  void syncWithProjects(List<Project> projects) {
    final current = _selectedProject.value;
    if (current == null) {
      return;
    }

    Project? updated;
    for (final project in projects) {
      if (project.id == current.id) {
        updated = project;
        break;
      }
    }

    if (updated != null) {
      if (!identical(updated, current)) {
        _selectedProject.value = updated;
      }
      return;
    }

    // User may have been unassigned; reset selection to avoid stale state.
    clearSelection();
  }
}
