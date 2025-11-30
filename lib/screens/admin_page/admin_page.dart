import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/screens/admin_page/widgets/admin_header.dart';
import 'package:my_app/screens/admin_page/widgets/observation_edit_dialog.dart';
import 'package:my_app/screens/admin_page/widgets/project_detail_view.dart';
import 'package:my_app/screens/admin_page/widgets/project_list_view.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/project_service.dart';
import 'package:my_app/services/user_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu.dart';

/// Admin Page that mirrors the React Admin Panel UI
class AdminPage extends StatefulWidget {
  final String? userEmail;
  final String userRole;

  const AdminPage({super.key, this.userEmail, this.userRole = 'admin'});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey _profileButtonKey = GlobalKey();
  bool _showProfileMenu = false;

  List<AdminProject> _projects = const [];
  bool _projectsLoading = true;
  ProjectStatus _statusFilter = ProjectStatus.active;
  String? _selectedProjectId;
  final Set<String> _statusUpdatesInFlight = <String>{};

  bool _showDeleteDialog = false;
  String? _projectPendingDelete;

  bool _showProjectSuccess = false;
  String _lastCreatedProjectName = '';

  StreamSubscription<List<AdminProject>>? _projectSubscription;
  StreamSubscription<List<AppUserRecord>>? _observerSubscription;
  StreamSubscription<int>? _notificationCountSubscription;
  List<AdminObserver> _observers = const [];
  bool _observersLoading = true;
  int _unreadNotificationCount = 0;
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;

  // New project form state
  bool _showNewProjectForm = false;
  final TextEditingController _newProjectNameController =
      TextEditingController();
  final TextEditingController _newProjectMainLocationController =
      TextEditingController();
  final TextEditingController _newProjectDescriptionController =
      TextEditingController();
  final TextEditingController _customLocationController =
      TextEditingController();
  List<String> _newProjectLocationTypeIds = [];
  List<String> _customLocations = [];
  List<String> _hiddenDefaultLocationIds = [];
  List<String> _newProjectObserverIds = [];
  bool _showNewProjectObserverSelector = false;
  String _newProjectObserverSearch = '';
  bool _isCreatingProject = false;
  Map<String, String> _newProjectErrors = {};

  // Detail view state
  bool _showObserverSelector = false;
  String _observerSearchQuery = '';
  bool _showAddLocationField = false;
  final TextEditingController _addLocationController = TextEditingController();
  final TextEditingController _projectMainLocationController =
      TextEditingController();
  bool _isSavingMainLocation = false;
  String? _projectMainLocationError;
  Map<String, String> _filters = {
    'gender': 'all',
    'ageGroup': 'all',
    'socialContext': 'all',
    'locationType': 'all',
    'activityLevel': 'all',
    'activityType': 'all',
  };

  @override
  void initState() {
    super.initState();
    _startProjectSubscription();
    _startObserverSubscription();
    if (_isAdmin) {
      _startNotificationCountSubscription();
    }
  }

  @override
  void dispose() {
    _projectSubscription?.cancel();
    _observerSubscription?.cancel();
    _notificationCountSubscription?.cancel();
    _newProjectNameController.dispose();
    _newProjectMainLocationController.dispose();
    _newProjectDescriptionController.dispose();
    _customLocationController.dispose();
    _addLocationController.dispose();
    _projectMainLocationController.dispose();
    super.dispose();
  }

  AdminProject? get _selectedProject {
    if (_selectedProjectId == null) return null;
    return _findProjectById(_selectedProjectId!);
  }

  bool get _isAdmin => widget.userRole == 'admin';

  AdminProject? _findProjectById(String projectId) {
    for (final project in _projects) {
      if (project.id == projectId) {
        return project;
      }
    }
    return null;
  }

  void _syncMainLocationController(AdminProject project) {
    final value = project.mainLocation;
    if (_projectMainLocationController.text != value) {
      _projectMainLocationController.text = value;
    }
  }

  void _startProjectSubscription() {
    _projectSubscription = ProjectService.instance.watchProjects().listen(
      (projects) {
        setState(() {
          _projects = projects;
          _projectsLoading = false;
          if (_selectedProjectId != null) {
            final matches = projects
                .where((project) => project.id == _selectedProjectId)
                .toList();
            if (matches.isEmpty) {
              _selectedProjectId = null;
              _projectMainLocationController.clear();
              _projectMainLocationError = null;
              _isSavingMainLocation = false;
            } else {
              _syncMainLocationController(matches.first);
            }
          }
        });
      },
      onError: (error) {
        debugPrint('Failed to load projects: $error');
        setState(() => _projectsLoading = false);
        _showSnackMessage('Unable to load projects right now', isError: true);
      },
    );
  }

  void _startObserverSubscription() {
    _observerSubscription = UserService.instance.watchObservers().listen(
      (records) {
        setState(() {
          _observers = records
              .map(
                (record) => AdminObserver(
                  id: record.uid,
                  name: _deriveObserverName(record.displayName, record.email),
                  email: record.email ?? 'unknown@innobeweeglab.nl',
                ),
              )
              .toList();
          _observersLoading = false;
        });
      },
      onError: (error) {
        debugPrint('Failed to load observers: $error');
        setState(() => _observersLoading = false);
        _showSnackMessage('Unable to load observers right now', isError: true);
      },
    );
  }

  void _startNotificationCountSubscription() {
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

  String _deriveObserverName(String? displayName, String? email) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }
    final fallback = (email ?? 'observer').split('@').first;
    if (fallback.isEmpty) return 'Observer';
    return fallback
        .split(RegExp(r'[._-]+'))
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              segment[0].toUpperCase() + segment.substring(1).toLowerCase(),
        )
        .join(' ')
        .trim();
  }

  void _showSnackMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleProfileMenu() {
    setState(() {
      _showProfileMenu = !_showProfileMenu;
    });
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _navigateToProjects() {
    Navigator.pushNamed(
      context,
      '/projects',
      arguments: ProjectListArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _navigateToObserver() {
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: null,
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _navigateToAdmin() {
    _showProfileMenu = false;
    setState(() {});
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

  void _toggleNewProjectForm() {
    setState(() => _showNewProjectForm = !_showNewProjectForm);
  }

  void _resetNewProjectForm({bool rebuild = true}) {
    void clearState() {
      _newProjectNameController.clear();
      _newProjectMainLocationController.clear();
      _newProjectDescriptionController.clear();
      _customLocationController.clear();
      _newProjectLocationTypeIds = [];
      _customLocations = [];
      _hiddenDefaultLocationIds = [];
      _newProjectObserverIds = [];
      _showNewProjectObserverSelector = false;
      _newProjectObserverSearch = '';
      _newProjectErrors = {};
      _showNewProjectForm = false;
    }

    if (rebuild) {
      setState(clearState);
    } else {
      clearState();
    }
  }

  void _toggleLocationTypeInNewProject(String id) {
    setState(() {
      if (_newProjectLocationTypeIds.contains(id)) {
        _newProjectLocationTypeIds.remove(id);
      } else {
        _newProjectLocationTypeIds.add(id);
      }
      _newProjectErrors.remove('locationTypes');
    });
  }

  void _handleAddCustomLocation() {
    final value = _customLocationController.text.trim();
    if (value.isEmpty) return;

    final existsCustom = _customLocations.any(
      (loc) => loc.toLowerCase() == value.toLowerCase(),
    );
    final existsDefault = AdminDataRepository.locationOptions.any(
      (option) => option.label.toLowerCase().contains(value.toLowerCase()),
    );

    if (existsCustom || existsDefault) {
      _customLocationController.clear();
      return;
    }

    setState(() {
      _customLocations = [..._customLocations, value];
      final customId = 'custom:$value';
      _newProjectLocationTypeIds = [..._newProjectLocationTypeIds, customId];
      _customLocationController.clear();
      _newProjectErrors.remove('locationTypes');
    });
  }

  void _removeCustomLocation(String label) {
    setState(() {
      _customLocations = _customLocations.where((loc) => loc != label).toList();
      _newProjectLocationTypeIds = _newProjectLocationTypeIds
          .where((id) => id != 'custom:$label')
          .toList();
    });
  }

  void _hideDefaultLocation(String id) {
    setState(() {
      if (!_hiddenDefaultLocationIds.contains(id)) {
        _hiddenDefaultLocationIds = [..._hiddenDefaultLocationIds, id];
      }
      _newProjectLocationTypeIds = _newProjectLocationTypeIds
          .where((typeId) => typeId != id)
          .toList();
    });
  }

  void _restoreDefaultLocation(String id) {
    setState(() {
      _hiddenDefaultLocationIds = _hiddenDefaultLocationIds
          .where((locId) => locId != id)
          .toList();
    });
  }

  void _toggleNewProjectObserverSelector() {
    setState(
      () => _showNewProjectObserverSelector = !_showNewProjectObserverSelector,
    );
  }

  void _addObserverToNewProject(String id) {
    setState(() {
      if (!_newProjectObserverIds.contains(id)) {
        _newProjectObserverIds = [..._newProjectObserverIds, id];
      }
    });
  }

  void _removeObserverFromNewProject(String id) {
    setState(() {
      _newProjectObserverIds = _newProjectObserverIds
          .where((obsId) => obsId != id)
          .toList();
    });
  }

  List<AdminObserver> get _availableObserversForNewProject {
    if (_observersLoading) return [];
    final query = _newProjectObserverSearch.toLowerCase();
    return _observers.where((observer) {
      final alreadySelected = _newProjectObserverIds.contains(observer.id);
      if (alreadySelected) return false;
      if (query.isEmpty) return true;
      return observer.name.toLowerCase().contains(query) ||
          observer.email.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _handleCreateProject() async {
    final errors = <String, String>{};
    if (_newProjectNameController.text.trim().isEmpty) {
      errors['name'] = 'Please enter a project name';
    }
    if (_newProjectMainLocationController.text.trim().isEmpty) {
      errors['mainLocation'] = 'Please enter a main location';
    }
    if (_newProjectLocationTypeIds.isEmpty) {
      errors['locationTypes'] = 'Please select at least one location type';
    }

    setState(() => _newProjectErrors = errors);
    if (errors.isNotEmpty) return;

    setState(() => _isCreatingProject = true);

    final project = AdminProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _newProjectNameController.text.trim(),
      description: _newProjectDescriptionController.text.trim(),
      mainLocation: _newProjectMainLocationController.text.trim(),
      status: ProjectStatus.active,
      locationTypeIds: List<String>.from(_newProjectLocationTypeIds),
      assignedObserverIds: List<String>.from(_newProjectObserverIds),
      observations: const [],
    );

    try {
      await ProjectService.instance.saveProject(
        projectId: project.id,
        name: project.name,
        mainLocation: project.mainLocation,
        description: project.description,
        locationTypeIds: project.locationTypeIds,
        assignedObserverIds: project.assignedObserverIds,
        status: project.status,
      );

      setState(() {
        _projects = [..._projects, project];
        _statusFilter = ProjectStatus.active;
        _isCreatingProject = false;
        _lastCreatedProjectName = project.name;
        _showProjectSuccess = true;
        _resetNewProjectForm(rebuild: false);
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showProjectSuccess = false);
        }
      });
    } catch (error) {
      debugPrint('Failed to create project: $error');
      if (mounted) {
        setState(() => _isCreatingProject = false);
      }
      _showSnackMessage(
        'Failed to create project. Please try again.',
        isError: true,
      );
    }
  }

  void _clearNewProjectError(String key) {
    if (!_newProjectErrors.containsKey(key)) return;
    setState(() {
      _newProjectErrors.remove(key);
    });
  }

  void _handleDetailMainLocationChanged(String value) {
    setState(() {
      if (_projectMainLocationError != null && value.trim().isNotEmpty) {
        _projectMainLocationError = null;
      }
    });
  }

  Future<void> _handleSaveMainLocation() async {
    final project = _selectedProject;
    if (project == null) return;
    final value = _projectMainLocationController.text.trim();
    if (value.isEmpty) {
      setState(() {
        _projectMainLocationError = 'Please enter a main location';
      });
      return;
    }
    if (value == project.mainLocation) {
      return;
    }

    setState(() {
      _isSavingMainLocation = true;
      _projectMainLocationError = null;
    });

    try {
      await ProjectService.instance.updateMainLocation(project.id, value);
      _updateProject(project.copyWith(mainLocation: value));
      _showSnackMessage('Main location updated');
    } catch (error) {
      debugPrint('Failed to update main location: $error');
      _showSnackMessage(
        'Unable to update main location right now.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingMainLocation = false);
      }
    }
  }

  void _handleProjectTap(AdminProject project) {
    setState(() {
      _selectedProjectId = project.id;
      _showObserverSelector = false;
      _observerSearchQuery = '';
      _showAddLocationField = false;
      _addLocationController.clear();
      _syncMainLocationController(project);
      _projectMainLocationError = null;
      _isSavingMainLocation = false;
      _filters = {
        'gender': 'all',
        'ageGroup': 'all',
        'socialContext': 'all',
        'locationType': 'all',
        'activityLevel': 'all',
        'activityType': 'all',
      };
    });
  }

  void _handleBackToProjects() {
    setState(() {
      _selectedProjectId = null;
      _showDeleteDialog = false;
      _projectPendingDelete = null;
      _projectMainLocationController.clear();
      _projectMainLocationError = null;
      _isSavingMainLocation = false;
    });
  }

  void _requestProjectDeletion(String projectId) {
    setState(() {
      _projectPendingDelete = projectId;
      _showDeleteDialog = true;
    });
  }

  void _cancelProjectDeletion() {
    setState(() {
      _showDeleteDialog = false;
      _projectPendingDelete = null;
    });
  }

  Future<void> _confirmProjectDeletion() async {
    final projectId = _projectPendingDelete;
    if (projectId == null) return;

    try {
      await ProjectService.instance.deleteProject(projectId);
      if (!mounted) return;
      setState(() {
        _projects =
            _projects.where((project) => project.id != projectId).toList();
        if (_selectedProjectId == projectId) {
          _selectedProjectId = null;
        }
        _showDeleteDialog = false;
        _projectPendingDelete = null;
      });
      _showSnackMessage('Project deleted permanently.');
    } catch (error) {
      debugPrint('Failed to delete project: $error');
      _showSnackMessage(
        'Unable to delete this project right now.',
        isError: true,
      );
    }
  }

  void _toggleObserverSelector() {
    setState(() => _showObserverSelector = !_showObserverSelector);
  }

  bool _isStatusUpdating(String projectId) {
    return _statusUpdatesInFlight.contains(projectId);
  }

  void _handleStatusFilterChanged(ProjectStatus status) {
    if (_statusFilter == status) return;
    setState(() => _statusFilter = status);
  }

  List<AdminObserver> get _availableObserversForProject {
    final project = _selectedProject;
    if (project == null) return [];
    if (_observersLoading) return [];
    final query = _observerSearchQuery.toLowerCase();
    return _observers.where((observer) {
      final alreadyAssigned = project.assignedObserverIds.contains(observer.id);
      if (alreadyAssigned) return false;
      if (query.isEmpty) return true;
      return observer.name.toLowerCase().contains(query) ||
          observer.email.toLowerCase().contains(query);
    }).toList();
  }

  void _addObserverToProject(String id) {
    final project = _selectedProject;
    if (project == null) return;
    if (project.assignedObserverIds.contains(id)) return;
    final updatedObserverIds = [...project.assignedObserverIds, id];
    final updated = project.copyWith(assignedObserverIds: updatedObserverIds);
    _updateProject(updated);
    _persistObserverAssignments(project.id, updatedObserverIds);
  }

  void _removeObserverFromProject(String id) {
    final project = _selectedProject;
    if (project == null) return;
    final updatedObserverIds = project.assignedObserverIds
        .where((obsId) => obsId != id)
        .toList();
    final updated = project.copyWith(assignedObserverIds: updatedObserverIds);
    _updateProject(updated);
    _persistObserverAssignments(project.id, updatedObserverIds);
  }

  void _toggleAddLocationField() {
    setState(() => _showAddLocationField = !_showAddLocationField);
  }

  void _handleAddLocationToProject() {
    final project = _selectedProject;
    if (project == null) return;
    final input = _addLocationController.text.trim();
    if (input.isEmpty) return;

    final customId = 'custom:$input';
    if (project.locationTypeIds.contains(customId)) {
      _addLocationController.clear();
      setState(() => _showAddLocationField = false);
      return;
    }

    final updated = project.copyWith(
      locationTypeIds: [...project.locationTypeIds, customId],
    );
    _updateProject(updated);
    _addLocationController.clear();
    setState(() => _showAddLocationField = false);
  }

  void _removeLocationFromProject(String id) {
    final project = _selectedProject;
    if (project == null) return;
    final updated = project.copyWith(
      locationTypeIds: project.locationTypeIds
          .where((locId) => locId != id)
          .toList(),
    );
    _updateProject(updated);
  }

  void _updateProject(AdminProject updated) {
    setState(() {
      _projects = _projects.map((project) {
        if (project.id == updated.id) {
          return AdminProject(
            id: updated.id,
            name: updated.name,
            description: updated.description,
            mainLocation: updated.mainLocation,
            status: updated.status,
            locationTypeIds: List<String>.from(updated.locationTypeIds),
            assignedObserverIds: List<String>.from(updated.assignedObserverIds),
            observations: List<ObservationRecord>.from(updated.observations),
          );
        }
        return project;
      }).toList();
    });
  }

  void _persistObserverAssignments(String projectId, List<String> observerIds) {
    ProjectService.instance
        .updateAssignedObservers(projectId, observerIds)
        .catchError((error) {
          debugPrint('Failed to update observer assignments: $error');
          _showSnackMessage(
            'Unable to update observers for this project.',
            isError: true,
          );
        });
  }

  void _updateFilter(String key, String value) {
    setState(() {
      _filters = {..._filters, key: value};
    });
  }

  void _clearFilters() {
    setState(() {
      _filters = {
        'gender': 'all',
        'ageGroup': 'all',
        'socialContext': 'all',
        'locationType': 'all',
        'activityLevel': 'all',
        'activityType': 'all',
      };
    });
  }

  Future<void> _handleProjectStatusChange(
    AdminProject project,
    ProjectStatus status,
  ) async {
    if (project.status == status) {
      return;
    }

    setState(() {
      _statusUpdatesInFlight.add(project.id);
    });

    try {
      await ProjectService.instance.updateProjectStatus(project.id, status);
      _updateProject(project.copyWith(status: status));
      _showSnackMessage('Project marked as ${status.label}.');
    } catch (error) {
      debugPrint('Failed to update project status: $error');
      _showSnackMessage(
        'Unable to update project status right now.',
        isError: true,
      );
    } finally {
      if (!mounted) {
        _statusUpdatesInFlight.remove(project.id);
      } else {
        setState(() {
          _statusUpdatesInFlight.remove(project.id);
        });
      }
    }
  }

  Map<ProjectStatus, int> get _statusCounts {
    final counts = {
      for (final status in ProjectStatus.values) status: 0,
    };
    for (final project in _projects) {
      counts[project.status] = counts[project.status]! + 1;
    }
    return counts;
  }

  List<AdminProject> get _filteredProjectsByStatus {
    return _projects
        .where((project) => project.status == _statusFilter)
        .toList(growable: false);
  }

  List<ObservationRecord> _filteredObservations(AdminProject project) {
    return project.observations.where((record) {
      if (_filters['gender'] != 'all' && record.gender != _filters['gender']) {
        return false;
      }
      if (_filters['ageGroup'] != 'all' &&
          record.ageGroup != _filters['ageGroup']) {
        return false;
      }
      if (_filters['socialContext'] != 'all' &&
          record.socialContext != _filters['socialContext']) {
        return false;
      }
      if (_filters['locationType'] != 'all' &&
          record.locationTypeId != _filters['locationType']) {
        return false;
      }
      if (_filters['activityLevel'] != 'all' &&
          record.activityLevel != _filters['activityLevel']) {
        return false;
      }
      if (_filters['activityType'] != 'all' &&
          record.activityType != _filters['activityType']) {
        return false;
      }
      return true;
    }).toList();
  }

  void _handleDownloadObservations(AdminProject project) {
    debugPrint('Downloading observations for ${project.name}');
  }

  Future<void> _openObservationEditor(ObservationRecord record) async {
    final project = _selectedProject;
    if (project == null) return;

    final updatedRecord = await showDialog<ObservationRecord>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ObservationEditDialog(record: record),
    );

    if (updatedRecord == null) return;

    final updatedObservations = project.observations
        .map((obs) => obs.id == updatedRecord.id ? updatedRecord : obs)
        .toList();

    _updateProject(project.copyWith(observations: updatedObservations));
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject = _selectedProject;
    final bool mainLocationHasChanges =
        selectedProject != null &&
        _projectMainLocationController.text.trim() !=
            selectedProject.mainLocation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppTheme.maxContentWidth,
                ),
                child: Column(
                  children: [
                    AdminHeader(
                      profileButtonKey: _profileButtonKey,
                      onProfileTap: _toggleProfileMenu,
                      title: 'Admin Panel',
                      unreadNotificationCount: _isAdmin
                          ? _unreadNotificationCount
                          : 0,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: selectedProject == null
                              ? (_projectsLoading && _projects.isEmpty
                                    ? const _AdminLoadingState()
                                    : AdminProjectListView(
                                    projects: _filteredProjectsByStatus,
                                        locationOptions:
                                            AdminDataRepository.locationOptions,
                                        showNewProjectForm: _showNewProjectForm,
                                        showProjectSuccess: _showProjectSuccess,
                                        lastCreatedProjectName:
                                            _lastCreatedProjectName,
                                    statusFilter: _statusFilter,
                                    statusCounts: _statusCounts,
                                    onStatusFilterChanged:
                                      _handleStatusFilterChanged,
                                        newProjectNameController:
                                            _newProjectNameController,
                                        newProjectMainLocationController:
                                            _newProjectMainLocationController,
                                        newProjectDescriptionController:
                                            _newProjectDescriptionController,
                                        customLocationController:
                                            _customLocationController,
                                        selectedLocationTypeIds:
                                            _newProjectLocationTypeIds,
                                        customLocations: _customLocations,
                                        hiddenDefaultLocationIds:
                                            _hiddenDefaultLocationIds,
                                        showObserverSelector:
                                            _showNewProjectObserverSelector,
                                        newProjectObserverSearch:
                                            _newProjectObserverSearch,
                                        selectedObserverIds:
                                            _newProjectObserverIds,
                                        allObservers: _observers,
                                        availableObserverOptions:
                                            _availableObserversForNewProject,
                                        newProjectErrors: _newProjectErrors,
                                        isCreatingProject: _isCreatingProject,
                                        onProjectNameChanged: () =>
                                            _clearNewProjectError('name'),
                                        onMainLocationChanged: () =>
                                            _clearNewProjectError(
                                              'mainLocation',
                                            ),
                                        onToggleForm: _toggleNewProjectForm,
                                        onAddCustomLocation:
                                            _handleAddCustomLocation,
                                        onRemoveCustomLocation:
                                            _removeCustomLocation,
                                        onToggleLocationType:
                                            _toggleLocationTypeInNewProject,
                                        onHideDefaultLocation:
                                            _hideDefaultLocation,
                                        onRestoreDefaultLocation:
                                            _restoreDefaultLocation,
                                        onObserverSelectorToggle:
                                            _toggleNewProjectObserverSelector,
                                        onObserverSearchChanged: (value) =>
                                            setState(
                                              () => _newProjectObserverSearch =
                                                  value,
                                            ),
                                        onAddObserver: _addObserverToNewProject,
                                        onRemoveObserver:
                                            _removeObserverFromNewProject,
                                        onSubmitProject: _handleCreateProject,
                                        onCancelForm: _resetNewProjectForm,
                                        onProjectTap: _handleProjectTap,
                                      ))
                              : ProjectDetailView(
                                  project: selectedProject,
                                  observers: _observers,
                                  locationOptions:
                                      AdminDataRepository.locationOptions,
                                  mainLocationController:
                                      _projectMainLocationController,
                                  mainLocationError: _projectMainLocationError,
                                  onMainLocationChanged:
                                      _handleDetailMainLocationChanged,
                                  onSaveMainLocation: _handleSaveMainLocation,
                                  isSavingMainLocation: _isSavingMainLocation,
                                  hasMainLocationChanges:
                                      mainLocationHasChanges,
                                  filters: _filters,
                                  showObserverSelector: _showObserverSelector,
                                  observerSearchQuery: _observerSearchQuery,
                                  showAddLocationField: _showAddLocationField,
                                  addLocationController: _addLocationController,
                                  availableObservers:
                                      _availableObserversForProject,
                                  onBack: _handleBackToProjects,
                                  onDelete: () => _requestProjectDeletion(
                                    selectedProject.id,
                                  ),
                                  onStatusChange: (status) =>
                                      _handleProjectStatusChange(
                                    selectedProject,
                                    status,
                                  ),
                                  isStatusUpdating:
                                      _isStatusUpdating(selectedProject.id),
                                  onToggleAddLocation: _toggleAddLocationField,
                                  onAddLocation: _handleAddLocationToProject,
                                  onRemoveLocation: _removeLocationFromProject,
                                  onToggleObserverSelector:
                                      _toggleObserverSelector,
                                  onObserverSearchChanged: (value) => setState(
                                    () => _observerSearchQuery = value,
                                  ),
                                  onAddObserver: _addObserverToProject,
                                  onRemoveObserver: _removeObserverFromProject,
                                  onDownload: () => _handleDownloadObservations(
                                    selectedProject,
                                  ),
                                  onFilterChanged: _updateFilter,
                                  onClearFilters: _clearFilters,
                                  filteredObservations: _filteredObservations(
                                    selectedProject,
                                  ),
                                  onEditObservation: _openObservationEditor,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showProfileMenu)
              ProfileMenu(
                profileButtonKey: _profileButtonKey,
                userEmail: widget.userEmail,
                onClose: () => setState(() => _showProfileMenu = false),
                onLogout: _handleLogout,
                onObserverTap: _navigateToObserver,
                onAdminTap: _isAdmin ? _navigateToAdmin : null,
                onProjectsTap: _navigateToProjects,
                onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
                activeDestination: ProfileMenuDestination.admin,
                showAdminOption: _isAdmin,
                showNotificationsOption: _isAdmin,
                unreadNotificationCount: _unreadNotificationCount,
              ),
            if (_showDeleteDialog && _projectPendingDelete != null)
              Builder(
                builder: (context) {
                  final projectForDialog = _findProjectById(
                    _projectPendingDelete!,
                  );
                  if (projectForDialog == null) {
                    return const SizedBox.shrink();
                  }
                  return _DeleteDialogOverlay(
                    project: projectForDialog,
                    observationCount: projectForDialog.observations.length,
                    onCancel: _cancelProjectDeletion,
                    onConfirm: () => _confirmProjectDeletion(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminLoadingState extends StatelessWidget {
  const _AdminLoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(color: AppTheme.primaryOrange),
          SizedBox(height: 16),
          Text(
            'Loading projects...',
            style: TextStyle(
              color: AppTheme.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteDialogOverlay extends StatelessWidget {
  final AdminProject project;
  final int observationCount;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DeleteDialogOverlay({
    required this.project,
    required this.observationCount,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusXL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.red100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.warning_rounded,
                  size: 36,
                  color: AppTheme.red600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Project?',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: AppTheme.fontFamilyHeading,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                project.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.red50,
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusLarge,
                  ),
                  border: Border.all(color: AppTheme.red200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ WARNING: This action cannot be reversed!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.red800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are about to permanently delete this project. This will remove:',
                      style: TextStyle(fontSize: 13, color: AppTheme.red700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• $observationCount observation${observationCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.red700,
                      ),
                    ),
                    const Text(
                      '• All assigned observers',
                      style: TextStyle(fontSize: 13, color: AppTheme.red700),
                    ),
                    const Text(
                      '• All project data and settings',
                      style: TextStyle(fontSize: 13, color: AppTheme.red700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This data cannot be recovered once deleted.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.red800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Are you absolutely sure you want to continue?',
                style: TextStyle(fontSize: 13, color: AppTheme.gray600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.gray700,
                        side: const BorderSide(color: AppTheme.gray300),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.red600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Yes, Delete Project'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
