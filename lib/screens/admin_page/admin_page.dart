import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/screens/admin_page/widgets/observation_edit_dialog.dart';
import 'package:my_app/screens/admin_page/widgets/observation_field_editor_sheet.dart';
import 'package:my_app/screens/admin_page/widgets/project_detail_view.dart';
import 'package:my_app/screens/admin_page/widgets/project_list_view.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/observation_service.dart';
import 'package:my_app/services/location_autocomplete_service.dart';
import 'package:my_app/services/observation_export_service.dart';
import 'package:my_app/models/observation_field_registry.dart';
import 'package:my_app/services/project_service.dart';
import 'package:my_app/services/user_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_page_header.dart';
import 'package:my_app/widgets/profile_menu_shell.dart';

/// Admin Page that mirrors the React Admin Panel UI
class AdminPage extends StatefulWidget {
  final String? userEmail;
  final String userRole;
  final String? initialProjectId;
  final ProjectStatus? initialProjectStatus;

  const AdminPage({
    super.key,
    this.userEmail,
    this.userRole = 'admin',
    this.initialProjectId,
    this.initialProjectStatus,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

enum _PendingFieldChangeAction { save, discard }

class _AdminPageState extends State<AdminPage> {
  List<AdminProject> _projects = const [];
  bool _projectsLoading = true;
  ProjectStatus _statusFilter = ProjectStatus.active;
  String? _selectedProjectId;
  final Set<String> _statusUpdatesInFlight = <String>{};

  bool _showDeleteDialog = false;
  String? _projectPendingDelete;

  bool _showProjectSuccess = false;
  String _lastCreatedProjectName = '';

  List<AdminObserver> _observers = const [];
  bool _observersLoading = true;
  int _unreadNotificationCount = 0;
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  final Map<String, List<ObservationRecord>> _observationCache = {};
  final ObservationExportService _observationExportService =
      ObservationExportService.instance;
  final LocationAutocompleteService _locationAutocompleteService =
      LocationAutocompleteService();
  static const int _projectFetchLimit = 40;
  static const int _defaultObservationPageSize = 5;
  static const List<int> _observationPageSizeOptions = [5, 10, 20, 50];
  int _observationPageSize = _defaultObservationPageSize;
  bool _isLoadingMoreObservations = false;
  bool _canLoadMoreObservations = true;
  String? _observationsProjectId;
  final Map<String, DocumentSnapshot<Map<String, dynamic>>?>
  _observationCursors = {};
  final Set<String> _observationExhausted = <String>{};
  final Set<String> _countBackfillInFlight = <String>{};
  final Map<String, int> _lastSyncedCounts = <String, int>{};
  String? _exportingProjectId;
  Map<ProjectStatus, int> _statusCounts = {
    for (final status in ProjectStatus.values) status: 0,
  };

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
  final ScrollController _detailScrollController = ScrollController();

  // Detail view state
  bool _showObserverSelector = false;
  String _observerSearchQuery = '';
  bool _showAddLocationField = false;
  final TextEditingController _addLocationController = TextEditingController();
  final TextEditingController _projectMainLocationController =
      TextEditingController();
  bool _isSavingMainLocation = false;
  String? _projectMainLocationError;
  ProjectDetailSection _projectDetailSection = ProjectDetailSection.general;
  Map<String, String> _filters = {
    'gender': 'all',
    'ageGroup': 'all',
    'socialContext': 'all',
    'locationType': 'all',
    'activityLevel': 'all',
  };

  // Observation field editor state
  List<ObservationField> _fieldDrafts = const [];
  String? _fieldDraftProjectId;
  bool _fieldEditsDirty = false;
  ObservationFieldAudience _fieldAudienceFilter =
      ObservationFieldAudience.individual;
  bool _isSavingFieldEdits = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProjectStatus != null) {
      _statusFilter = widget.initialProjectStatus!;
    }
    _selectedProjectId = widget.initialProjectId;
    _loadStatusCounts();
    _loadProjects();
    _loadObservers();
    if (_isAdmin) {
      _loadUnreadNotificationCount();
    }
  }

  @override
  void dispose() {
    _newProjectNameController.dispose();
    _newProjectMainLocationController.dispose();
    _newProjectDescriptionController.dispose();
    _customLocationController.dispose();
    _addLocationController.dispose();
    _projectMainLocationController.dispose();
    _detailScrollController.dispose();
    _locationAutocompleteService.dispose();
    super.dispose();
  }

  AdminProject? get _selectedProject {
    if (_selectedProjectId == null) return null;
    return _findProjectById(_selectedProjectId!);
  }

  bool get _isAdmin => widget.userRole == 'admin';

  List<ObservationField> get _visibleFieldDrafts {
    return _fieldDrafts
        .where((field) => _fieldMatchesAudience(field, _fieldAudienceFilter))
        .toList(growable: false);
  }

  Map<ObservationFieldAudience, int> get _fieldCountsByAudience {
    return {
      ObservationFieldAudience.individual: _fieldDrafts
          .where(
            (field) =>
                _fieldMatchesAudience(field, ObservationFieldAudience.individual),
          )
          .length,
      ObservationFieldAudience.group: _fieldDrafts
          .where(
            (field) =>
                _fieldMatchesAudience(field, ObservationFieldAudience.group),
          )
          .length,
    };
  }

  bool _fieldMatchesAudience(
    ObservationField field,
    ObservationFieldAudience audience,
  ) {
    if (field.audience == ObservationFieldAudience.all) {
      return true;
    }
    return field.audience == audience;
  }

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

  void _hydrateFieldDrafts(AdminProject project, {bool force = false}) {
    if (!force &&
        _fieldDraftProjectId == project.id &&
        _fieldDrafts.isNotEmpty) {
      return;
    }
    final sourceFields = project.fields.isEmpty
        ? ObservationFieldRegistry.defaultFields()
        : project.fields;
    // Always sort by displayOrder to avoid nondeterministic ordering when
    // Firestore data has equal or missing displayOrder values.
    final sorted = [...sourceFields]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final normalized = _normalizeGroupDemographicFields(
      sorted.map((field) => field.copyWith()).toList(),
    );
    _fieldDraftProjectId = project.id;
    _fieldDrafts = normalized.fields;
    _fieldEditsDirty = normalized.changed;
  }

  _FieldNormalizationResult _normalizeGroupDemographicFields(
    List<ObservationField> drafts,
  ) {
    bool changed = false;
    final demographicTemplate = ObservationFieldRegistry.defaultFields()
        .firstWhere(
          (field) =>
              field.id == ObservationFieldRegistry.groupGenderMixFieldId,
        );

    final filtered = drafts
        .where((field) {
          final isLegacyAgeMix =
              field.id == ObservationFieldRegistry.groupAgeMixFieldId;
          if (isLegacyAgeMix) changed = true;
          return !isLegacyAgeMix;
        })
        .map((field) {
          if (field.id == ObservationFieldRegistry.groupSizeFieldId &&
              field.isEnabled == false) {
            changed = true;
            return field.copyWith(isEnabled: true);
          }
          return field;
        })
        .toList();

    final demographicIndex = filtered.indexWhere(
      (field) => field.id == ObservationFieldRegistry.groupGenderMixFieldId,
    );

    if (demographicIndex >= 0) {
      final existing = filtered[demographicIndex];
      final merged = _mergeDemographicField(existing, demographicTemplate);
      if (!_fieldsEquivalent(existing, merged)) {
        changed = true;
      }
      filtered[demographicIndex] = merged;
    } else {
      final insertIndex = filtered.indexWhere(
        (field) => field.id == ObservationFieldRegistry.locationTypeFieldId,
      );
      final targetIndex = insertIndex == -1 ? filtered.length : insertIndex;
      filtered.insert(targetIndex, demographicTemplate);
      changed = true;
    }

    return _FieldNormalizationResult(fields: filtered, changed: changed);
  }

  ObservationField _mergeDemographicField(
    ObservationField existing,
    ObservationField template,
  ) {
    return existing.copyWith(
      label: template.label,
      helperText: template.helperText,
      type: template.type,
      audience: template.audience,
      isRequired: template.isRequired,
      config: template.config,
    );
  }

  bool _fieldsEquivalent(ObservationField a, ObservationField b) {
    return a.id == b.id &&
        _localizedEquals(a.label, b.label) &&
        _localizedEquals(a.helperText, b.helperText) &&
        a.type == b.type &&
        a.audience == b.audience &&
        a.isRequired == b.isRequired &&
        _configEquals(a.config, b.config);
  }

  bool _localizedEquals(LocalizedText? a, LocalizedText? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.nl == b.nl && (a.en ?? '') == (b.en ?? '');
  }

  bool _configEquals(
    ObservationFieldConfig? a,
    ObservationFieldConfig? b,
  ) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return jsonEncode(a.toJson()) == jsonEncode(b.toJson());
  }

  Future<void> _loadProjects() async {
    setState(() => _projectsLoading = true);
    try {
      final projects = await ProjectService.instance.fetchProjects(
        status: _statusFilter,
        limit: _projectFetchLimit,
      );
      final hydratedProjects = projects
          .map((project) {
            final cached = _observationCache[project.id];
            if (cached == null) {
              return project;
            }
            return project.copyWith(observations: cached);
          })
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _projects = hydratedProjects;
        _projectsLoading = false;
        if (_selectedProjectId != null && !_fieldEditsDirty) {
          for (final project in hydratedProjects) {
            if (project.id == _selectedProjectId) {
              _hydrateFieldDrafts(project, force: true);
              break;
            }
          }
        }
      });
      if (_selectedProjectId != null) {
        final selected = hydratedProjects
            .where((project) => project.id == _selectedProjectId)
            .toList();
        if (selected.isEmpty) {
          _handleBackToProjects();
        } else {
          _syncMainLocationController(selected.first);
        }
      }
      for (final project in projects) {
        if (project.totalObservationCount == 0) {
          _refreshObservationCount(project.id, force: true);
        }
      }
    } catch (error) {
      debugPrint('Failed to load projects: $error');
      if (!mounted) return;
      setState(() => _projectsLoading = false);
      _showSnackMessage('Unable to load projects right now', isError: true);
    }
  }

  Future<void> _loadStatusCounts() async {
    try {
      final counts = await ProjectService.instance.fetchStatusCounts();
      if (!mounted) return;
      setState(() => _statusCounts = counts);
    } catch (error) {
      debugPrint('Failed to load project status counts: $error');
    }
  }

  void _refreshObservationCount(String projectId, {bool force = false}) {
    if (!force &&
        (_countBackfillInFlight.contains(projectId) ||
            _lastSyncedCounts.containsKey(projectId))) {
      return;
    }
    if (_countBackfillInFlight.contains(projectId)) {
      return;
    }
    _countBackfillInFlight.add(projectId);
    ObservationService.instance
        .countObservations(projectId: projectId)
        .then((observationCount) async {
          _lastSyncedCounts[projectId] = observationCount;
          if (mounted) {
            setState(() {
              _projects = _projects.map((project) {
                if (project.id == projectId) {
                  return project.copyWith(
                    totalObservationCount: observationCount,
                  );
                }
                return project;
              }).toList();
            });
          }
          await ProjectService.instance.syncObservationCount(
            projectId,
            observationCount,
          );
        })
        .catchError((error, stackTrace) {
          debugPrint(
            'Failed to refresh observation count for $projectId: $error',
          );
          return null;
        })
        .whenComplete(() {
          _countBackfillInFlight.remove(projectId);
        });
  }

  Future<void> _loadObservers() async {
    try {
      final records = await UserService.instance.fetchObservers();
      if (!mounted) return;
      setState(() {
        _observers = records
            .map(
              (record) => AdminObserver(
                id: record.uid,
                name: _deriveObserverName(record.displayName, record.email),
                email: record.email ?? 'unknown@innobeweeglab.nl',
              ),
            )
            .toList(growable: false);
        _observersLoading = false;
      });
    } catch (error) {
      debugPrint('Failed to load observers: $error');
      if (!mounted) return;
      setState(() => _observersLoading = false);
      _showSnackMessage('Unable to load observers right now', isError: true);
    }
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await _notificationService.fetchUnreadCount();
      if (!mounted) return;
      setState(() => _unreadNotificationCount = count);
    } catch (error) {
      debugPrint('Failed to load unread notifications: $error');
    }
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

  void _handleLogout() async {
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) return;
    try {
      await AuthService.instance.signOut();
    } on AuthException catch (error) {
      _showSnackMessage(error.message, isError: true);
      return;
    } catch (error) {
      debugPrint('Failed to sign out: $error');
      _showSnackMessage(
        'Unable to logout right now. Please try again.',
        isError: true,
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _navigateToProjects() async {
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/projects',
      arguments: ProjectListArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _navigateToObserver() async {
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) return;
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
    // Already on the admin page; nothing to do beyond closing the menu.
  }

  void _navigateToProjectMap() async {
    if (!_isAdmin) return;
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/admin-project-map',
      arguments: AdminProjectMapArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openNotificationsPage() async {
    if (!_isAdmin) return;
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/admin-notifications',
      arguments: AdminNotificationsArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openProfileSettings() async {
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/profile-settings',
      arguments: ProfileSettingsArguments(
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
      fields: ObservationFieldRegistry.defaultFields(),
      observations: const [],
      totalObservationCount: 0,
    );

    try {
      await ProjectService.instance.saveProject(
        projectId: project.id,
        name: project.name,
        mainLocation: project.mainLocation,
        description: project.description,
        locationTypeIds: project.locationTypeIds,
        assignedObserverIds: project.assignedObserverIds,
        fields: project.fields,
        status: project.status,
      );
      if (_statusFilter != ProjectStatus.active) {
        setState(() => _statusFilter = ProjectStatus.active);
      }
      await _loadProjects();
      await _loadStatusCounts();
      if (!mounted) return;
      setState(() {
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
      _showSnackMessage(
        'Failed to create project. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingProject = false);
      }
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

  void _handleProjectTap(AdminProject project) async {
    if (_selectedProjectId == project.id) {
      return;
    }
    if (_selectedProjectId != null && !await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedProjectId = project.id;
      _showObserverSelector = false;
      _observerSearchQuery = '';
      _showAddLocationField = false;
      _addLocationController.clear();
      _syncMainLocationController(project);
      _hydrateFieldDrafts(project, force: true);
      _projectMainLocationError = null;
      _isSavingMainLocation = false;
      _projectDetailSection = ProjectDetailSection.general;
      _filters = {
        'gender': 'all',
        'ageGroup': 'all',
        'socialContext': 'all',
        'locationType': 'all',
        'activityLevel': 'all',
      };
      _observationsProjectId = project.id;
      _canLoadMoreObservations = !_observationExhausted.contains(project.id);
    });
    if (!_observationCache.containsKey(project.id)) {
      _loadObservationPage(project.id, reset: true);
    }
  }

  void _handleBackToProjects() async {
    if (!await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) {
      return;
    }
    _resetProjectDetailState();
  }

  void _resetProjectDetailState() {
    setState(() {
      _selectedProjectId = null;
      _showDeleteDialog = false;
      _projectPendingDelete = null;
      _projectMainLocationController.clear();
      _projectMainLocationError = null;
      _isSavingMainLocation = false;
      _fieldDrafts = const [];
      _fieldEditsDirty = false;
      _fieldDraftProjectId = null;
      _fieldAudienceFilter = ObservationFieldAudience.individual;
      _projectDetailSection = ProjectDetailSection.general;
    });
    _observationsProjectId = null;
    _observationPageSize = _defaultObservationPageSize;
    _isLoadingMoreObservations = false;
    _canLoadMoreObservations = true;
  }

  Future<bool> _handleWillPop() async {
    if (_selectedProjectId != null) {
      if (!await _ensureFieldChangesHandled()) {
        return false;
      }
      _resetProjectDetailState();
      return false;
    }
    return await _ensureFieldChangesHandled();
  }

  void _handleProjectSectionChanged(ProjectDetailSection section) async {
    if (_projectDetailSection == section) {
      return;
    }
    final leavingFields =
        _projectDetailSection == ProjectDetailSection.fields &&
        section != ProjectDetailSection.fields;
    if (leavingFields && !await _ensureFieldChangesHandled()) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _projectDetailSection = section);
  }

  void _handleFieldAudienceChanged(ObservationFieldAudience audience) {
    if (_fieldAudienceFilter == audience) {
      return;
    }
    setState(() => _fieldAudienceFilter = audience);
  }

  String _generateFieldId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'custom-field-$timestamp';
  }

  ObservationField _createNewFieldTemplate() {
    return ObservationField(
      id: _generateFieldId(),
      label: const LocalizedText(nl: 'Nieuw veld', en: 'New Field'),
      type: ObservationFieldType.text,
      audience: _fieldAudienceFilter,
      isStandard: false,
      isRequired: false,
      isEnabled: true,
      displayOrder: (_fieldDrafts.length + 1) * 10,
      config: const TextObservationFieldConfig(multiline: false),
    );
  }

  void _handleFieldReorder(int oldIndex, int newIndex) {
    final visibleFields = _visibleFieldDrafts;
    if (oldIndex < 0 || oldIndex >= visibleFields.length) {
      return;
    }

    var targetIndex = newIndex;
    if (targetIndex > visibleFields.length) {
      targetIndex = visibleFields.length;
    }
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }
    if (targetIndex < 0) {
      targetIndex = 0;
    }
    if (targetIndex >= visibleFields.length) {
      targetIndex = visibleFields.length - 1;
    }
    if (oldIndex == targetIndex) {
      return;
    }

    setState(() {
      final reorderedSubset = List<ObservationField>.from(visibleFields);
      final movedField = reorderedSubset.removeAt(oldIndex);
      reorderedSubset.insert(targetIndex, movedField);

      final List<ObservationField> nextDrafts = [];
      int subsetCursor = 0;
      for (final field in _fieldDrafts) {
        if (_fieldMatchesAudience(field, _fieldAudienceFilter)) {
          nextDrafts.add(reorderedSubset[subsetCursor++]);
        } else {
          nextDrafts.add(field);
        }
      }
      _fieldDrafts = nextDrafts;
      _fieldEditsDirty = true;
    });
  }

  void _handleFieldEnabledChange(String fieldId, bool isEnabled) {
    setState(() {
      _fieldDrafts = _fieldDrafts
          .map(
            (field) => field.id == fieldId
                ? field.copyWith(isEnabled: isEnabled)
                : field,
          )
          .toList(growable: false);
      _fieldEditsDirty = true;
    });
  }

  void _handleDeleteField(String fieldId) {
    setState(() {
      _fieldDrafts = _fieldDrafts
          .where((field) => field.id != fieldId)
          .toList(growable: false);
      _fieldEditsDirty = true;
    });
  }

  void _handleResetFieldsToDefaults() {
    setState(() {
      _fieldDrafts = ObservationFieldRegistry.defaultFields();
      _fieldEditsDirty = true;
    });
  }

  void _handleDiscardFieldChanges() {
    final project = _selectedProject;
    if (project == null) return;
    setState(() {
      _hydrateFieldDrafts(project, force: true);
    });
  }

  Future<void> _handleAddField(BuildContext context) async {
    final template = _createNewFieldTemplate();
    final updated = await showObservationFieldEditorSheet(
      context,
      field: template,
      canEditType: true,
    );
    if (updated == null) return;
    setState(() {
      _fieldDrafts = [..._fieldDrafts, updated];
      _fieldEditsDirty = true;
    });
  }

  Future<void> _handleEditField(
    BuildContext context,
    ObservationField field,
  ) async {
    final updated = await showObservationFieldEditorSheet(
      context,
      field: field,
      canEditType: !field.isStandard,
    );
    if (updated == null) return;
    setState(() {
      final drafts = [..._fieldDrafts];
      final index = drafts.indexWhere((item) => item.id == field.id);
      if (index != -1) {
        drafts[index] = updated;
        _fieldDrafts = drafts;
        _fieldEditsDirty = true;
      }
    });
  }

  List<ObservationField> _normalizedFieldDraftsForSaving() {
    int order = 0;
    return _fieldDrafts
        .map((field) {
          final normalized = field.copyWith(displayOrder: order);
          order += 10;
          return normalized;
        })
        .toList(growable: false);
  }

  Future<void> _handleSaveFieldEdits() async {
    final project = _selectedProject;
    if (project == null || _fieldDraftProjectId != project.id) {
      return;
    }
    final payload = _normalizedFieldDraftsForSaving();
    setState(() => _isSavingFieldEdits = true);
    try {
      await ProjectService.instance.updateProjectFields(project.id, payload);
      _updateProject(project.copyWith(fields: payload));
      setState(() {
        _fieldDrafts = payload;
        _fieldEditsDirty = false;
      });
      _showSnackMessage('Observation fields updated');
    } catch (error) {
      debugPrint('Failed to update observation fields: $error');
      _showSnackMessage(
        'Unable to save observation fields right now.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingFieldEdits = false);
      }
    }
  }

  Future<bool> _ensureFieldChangesHandled() async {
    if (!_fieldEditsDirty) {
      return true;
    }
    final project = _selectedProject;
    if (project == null) {
      if (mounted) {
        setState(() => _fieldEditsDirty = false);
      }
      return true;
    }
    if (!mounted) {
      return true;
    }
    final l10n = context.l10n;
    final decision = await showDialog<_PendingFieldChangeAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.adminUnsavedFieldsTitle),
        content: Text(l10n.adminUnsavedFieldsDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context)
                .pop(_PendingFieldChangeAction.discard),
            child: Text(l10n.adminDiscardChanges),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context)
                .pop(_PendingFieldChangeAction.save),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(l10n.adminSaveChanges),
          ),
        ],
      ),
    );

    switch (decision) {
      case _PendingFieldChangeAction.save:
        await _handleSaveFieldEdits();
        return !_fieldEditsDirty;
      case _PendingFieldChangeAction.discard:
        _handleDiscardFieldChanges();
        return true;
      case null:
        return false;
    }
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
        _projects = _projects
            .where((project) => project.id != projectId)
            .toList();
        if (_selectedProjectId == projectId) {
          _selectedProjectId = null;
        }
        _showDeleteDialog = false;
        _projectPendingDelete = null;
        _observationCache.remove(projectId);
      });
      _showSnackMessage('Project deleted permanently.');
      await _loadStatusCounts();
      await _loadProjects();
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

  void _handleStatusFilterChanged(ProjectStatus status) async {
    if (_statusFilter == status) return;
    if (_selectedProjectId != null && !await _ensureFieldChangesHandled()) {
      return;
    }
    if (_selectedProjectId != null) {
      if (!mounted) return;
      _resetProjectDetailState();
    }
    if (!mounted) return;
    setState(() => _statusFilter = status);
    _loadProjects();
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
            fields: List<ObservationField>.from(updated.fields),
            observations: List<ObservationRecord>.from(updated.observations),
            totalObservationCount: updated.totalObservationCount,
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
      };
    });
  }

  void _handleObservationPageSizeChange(int size) {
    if (_observationPageSize == size) {
      return;
    }
    setState(() {
      _observationPageSize = size;
    });
    final projectId = _selectedProjectId;
    if (projectId != null) {
      _observationCache.remove(projectId);
      _observationCursors.remove(projectId);
      _observationExhausted.remove(projectId);
      _loadObservationPage(projectId, reset: true);
    }
  }

  Future<void> _loadObservationPage(
    String projectId, {
    bool reset = false,
  }) async {
    _observationsProjectId = projectId;
    if (_isLoadingMoreObservations) {
      return;
    }
    if (!reset &&
        (_observationExhausted.contains(projectId) ||
            (_observationCache[projectId]?.isEmpty == false &&
                _observationCursors[projectId] == null))) {
      return;
    }

    setState(() {
      _isLoadingMoreObservations = true;
      if (reset) {
        _observationCache.remove(projectId);
        _observationCursors.remove(projectId);
        _observationExhausted.remove(projectId);
      }
    });

    try {
      final result = await ObservationService.instance.fetchObservationPage(
        projectId: projectId,
        limit: _observationPageSize,
        startAfter: reset ? null : _observationCursors[projectId],
      );

      if (!mounted || _observationsProjectId != projectId) {
        return;
      }

      setState(() {
        final existing = reset
            ? <ObservationRecord>[]
            : (_observationCache[projectId] ?? const <ObservationRecord>[]);
        final updated = [...existing, ...result.records];
        _observationCache[projectId] = updated;
        _observationCursors[projectId] = result.lastDocument;
        _canLoadMoreObservations = result.hasMore;
        if (!result.hasMore) {
          _observationExhausted.add(projectId);
        } else {
          _observationExhausted.remove(projectId);
        }
        _isLoadingMoreObservations = false;
        _projects = _projects.map((project) {
          if (project.id == projectId) {
            return project.copyWith(observations: updated);
          }
          return project;
        }).toList();
      });
    } catch (error) {
      debugPrint('Failed to load observations: $error');
      if (!mounted) return;
      setState(() {
        _isLoadingMoreObservations = false;
      });
      _showSnackMessage(
        'Unable to load observations right now.',
        isError: true,
      );
    }
  }

  void _handleLoadMoreObservations() {
    final projectId = _selectedProjectId;
    if (projectId == null || !_canLoadMoreObservations) {
      return;
    }
    _loadObservationPage(projectId);
  }

  Future<void> _handleRefreshObservations(AdminProject project) async {
    _observationCache.remove(project.id);
    _observationCursors.remove(project.id);
    _observationExhausted.remove(project.id);
    _observationsProjectId = project.id;
    setState(() {
      _canLoadMoreObservations = true;
    });
    await _loadObservationPage(project.id, reset: true);
    _refreshObservationCount(project.id, force: true);
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
      await _loadStatusCounts();
      await _loadProjects();
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

  List<AdminProject> get _filteredProjectsByStatus {
    return List<AdminProject>.from(_projects);
  }

  List<ObservationRecord> _filteredObservations(
    List<ObservationRecord> observations,
  ) {
    return observations.where((record) {
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
      return true;
    }).toList();
  }

  List<ObservationRecord> _projectObservations(AdminProject project) {
    return _observationCache[project.id] ?? project.observations;
  }

  Future<void> _handleDownloadObservations(AdminProject project) async {
    final l10n = context.l10n;
    if (_exportingProjectId != null) {
      return;
    }
    setState(() => _exportingProjectId = project.id);
    try {
      await _observationExportService.exportProjectObservations(
        project: project,
        l10n: l10n,
      );
      _showSnackMessage(l10n.exportSuccessMessage);
    } catch (error) {
      debugPrint('Failed to export observations: $error');
      _showSnackMessage(
        l10n.exportErrorMessage,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _exportingProjectId = null);
      }
    }
  }

  Future<void> _openObservationEditor(ObservationRecord record) async {
    final project = _selectedProject;
    if (project == null && record.projectId.isEmpty) {
      return;
    }

    final targetProjectId = record.projectId.isNotEmpty
        ? record.projectId
        : project?.id ?? '';
    if (targetProjectId.isEmpty) return;

    final updatedRecord = await showDialog<ObservationRecord>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ObservationEditDialog(
        record: record,
        fields: project?.fields ?? const [],
      ),
    );

    if (updatedRecord == null) return;

    try {
      await ObservationService.instance.updateObservation(
        projectId: targetProjectId,
        record: updatedRecord,
      );
      if (mounted) {
        setState(() {
          final existing = _observationCache[targetProjectId];
          if (existing != null) {
            final updatedList = existing
                .map(
                  (item) => item.id == updatedRecord.id ? updatedRecord : item,
                )
                .toList();
            _observationCache[targetProjectId] = updatedList;
            _projects = _projects.map((project) {
              if (project.id == targetProjectId) {
                return project.copyWith(observations: updatedList);
              }
              return project;
            }).toList();
          }
        });
      }
      _showSnackMessage('Observation updated.');
    } catch (error) {
      debugPrint('Failed to update observation: $error');
      _showSnackMessage(
        'Unable to update observation right now.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedProject = _selectedProject;
    final AdminProject? hydratedProject = selectedProject?.copyWith(
      observations: _projectObservations(selectedProject),
    );
    final List<ObservationRecord> filteredObservationList =
        hydratedProject == null
        ? const []
        : _filteredObservations(hydratedProject.observations);
    final bool mainLocationHasChanges =
        selectedProject != null &&
        _projectMainLocationController.text.trim() !=
            selectedProject.mainLocation;

    return ProfileMenuShell(
      userEmail: widget.userEmail,
      activeDestination: ProfileMenuDestination.admin,
      onLogout: _handleLogout,
      onProfileSettingsTap: _openProfileSettings,
      onObserverTap: _navigateToObserver,
      onAdminTap: _isAdmin ? _navigateToAdmin : null,
      onProjectsTap: _navigateToProjects,
      onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
      onProjectMapTap: _isAdmin ? _navigateToProjectMap : null,
      showAdminOption: _isAdmin,
      showNotificationsOption: _isAdmin,
      showProjectMapOption: _isAdmin,
      unreadNotificationCount: _unreadNotificationCount,
      builder: (context, controller) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              return;
            }
            final navigator = Navigator.of(context);
            final shouldPop = await _handleWillPop();
            if (shouldPop) {
              navigator.maybePop(result);
            }
          },
          child: Scaffold(
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
                  AppPageHeader(
                  profileButtonKey: controller.profileButtonKey,
                  onProfileTap: controller.toggleMenu,
                  subtitle: context.l10n.adminPanelTitle,
                  subtitleIcon: Icons.shield_outlined,
                  unreadNotificationCount:
                    _isAdmin ? _unreadNotificationCount : 0,
                  ),
                  Expanded(
                  child: SingleChildScrollView(
                    controller: _detailScrollController,
                    child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.pageGutter,
                      0,
                      AppTheme.pageGutter,
                      32,
                    ),
                    child: hydratedProject == null
                      ? (_projectsLoading && _projects.isEmpty
                        ? const _AdminLoadingState()
                        : AdminProjectListView(
                          projects:
                            _filteredProjectsByStatus,
                          locationOptions:
                            AdminDataRepository
                              .locationOptions,
                          locationAutocompleteService:
                            _locationAutocompleteService,
                          showNewProjectForm:
                            _showNewProjectForm,
                          showProjectSuccess:
                            _showProjectSuccess,
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
                          isCreatingProject:
                            _isCreatingProject,
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
                              () =>
                                _newProjectObserverSearch =
                                  value,
                            ),
                          onAddObserver:
                            _addObserverToNewProject,
                          onRemoveObserver:
                            _removeObserverFromNewProject,
                          onSubmitProject:
                            _handleCreateProject,
                          onCancelForm: _resetNewProjectForm,
                          onProjectTap: _handleProjectTap,
                          ))
                      : ProjectDetailView(
                        project: hydratedProject,
                        observers: _observers,
                        locationOptions:
                          AdminDataRepository
                            .locationOptions,
                        locationAutocompleteService:
                          _locationAutocompleteService,
                        activeSection: _projectDetailSection,
                        onSectionChange:
                          _handleProjectSectionChanged,
                        scrollController: _detailScrollController,
                        mainLocationController:
                          _projectMainLocationController,
                        mainLocationError:
                          _projectMainLocationError,
                        onMainLocationChanged:
                          _handleDetailMainLocationChanged,
                        onSaveMainLocation:
                          _handleSaveMainLocation,
                        isSavingMainLocation:
                          _isSavingMainLocation,
                        hasMainLocationChanges:
                          mainLocationHasChanges,
                        filters: _filters,
                        showObserverSelector:
                          _showObserverSelector,
                        observerSearchQuery:
                          _observerSearchQuery,
                        showAddLocationField:
                          _showAddLocationField,
                        addLocationController:
                          _addLocationController,
                        availableObservers:
                          _availableObserversForProject,
                        entriesPageSize: _observationPageSize,
                        pageSizeOptions:
                          _observationPageSizeOptions,
                        onPageSizeChange:
                          _handleObservationPageSizeChange,
                        onBack: _handleBackToProjects,
                        onDelete: () => _requestProjectDeletion(
                          hydratedProject.id,
                        ),
                        onStatusChange: (status) =>
                          _handleProjectStatusChange(
                            hydratedProject,
                            status,
                          ),
                        isStatusUpdating: _isStatusUpdating(
                          hydratedProject.id,
                        ),
                        onToggleAddLocation:
                          _toggleAddLocationField,
                        onAddLocation:
                          _handleAddLocationToProject,
                        onRemoveLocation:
                          _removeLocationFromProject,
                        onToggleObserverSelector:
                          _toggleObserverSelector,
                        onObserverSearchChanged: (value) =>
                          setState(
                            () =>
                              _observerSearchQuery = value,
                          ),
                        onAddObserver: _addObserverToProject,
                        onRemoveObserver:
                          _removeObserverFromProject,
                        onDownload: () =>
                          _handleDownloadObservations(
                            hydratedProject,
                          ),
                        fieldDrafts: _visibleFieldDrafts,
                        fieldAudienceFilter: _fieldAudienceFilter,
                        fieldCounts: _fieldCountsByAudience,
                        onFieldAudienceChanged:
                          _handleFieldAudienceChanged,
                        fieldEditsDirty: _fieldEditsDirty,
                        isSavingFieldEdits: _isSavingFieldEdits,
                        onAddField: (context) =>
                          _handleAddField(context),
                        onEditField: (context, field) =>
                          _handleEditField(context, field),
                        onReorderField: _handleFieldReorder,
                        onToggleField:
                          _handleFieldEnabledChange,
                        onDeleteField: _handleDeleteField,
                        onResetFields:
                          _handleResetFieldsToDefaults,
                        onSaveFields: _handleSaveFieldEdits,
                        onDiscardFieldChanges:
                          _handleDiscardFieldChanges,
                        onFilterChanged: _updateFilter,
                        onClearFilters: _clearFilters,
                        filteredObservations:
                          filteredObservationList,
                        isExportingObservations:
                          _exportingProjectId ==
                          hydratedProject.id,
                        onEditObservation:
                          _openObservationEditor,
                        onRefreshObservations: () =>
                          _handleRefreshObservations(
                            hydratedProject,
                          ),
                        canLoadMoreObservations:
                          _canLoadMoreObservations,
                        isLoadingMoreObservations:
                          _isLoadingMoreObservations,
                        onLoadMoreObservations:
                          _handleLoadMoreObservations,
                        ),
                    ),
                  ),
                  ),
                ],
                ),
              ),
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
                  observationCount:
                    projectForDialog.totalObservationCount,
                  onCancel: _cancelProjectDeletion,
                  onConfirm: _confirmProjectDeletion,
                );
                },
              ),
            ],
            ),
          ),
          ),
        );
      },
    );
  }
}

class _FieldNormalizationResult {
  final List<ObservationField> fields;
  final bool changed;

  const _FieldNormalizationResult({
    required this.fields,
    required this.changed,
  });
}

class _AdminLoadingState extends StatelessWidget {
  const _AdminLoadingState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.primaryOrange),
          const SizedBox(height: 16),
          Text(
            l10n.adminLoadingProjects,
            style: const TextStyle(
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
    final l10n = context.l10n;
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
              Text(
                l10n.adminDeleteDialogTitle,
                style: const TextStyle(
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
                    Text(
                      l10n.adminDeleteWarningHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.red800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.adminDeleteWarningTitle,
                      style:
                          const TextStyle(fontSize: 13, color: AppTheme.red700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.adminDeleteRemoveObservations(observationCount),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.red700,
                      ),
                    ),
                    Text(
                      l10n.adminDeleteRemoveObservers,
                      style:
                          const TextStyle(fontSize: 13, color: AppTheme.red700),
                    ),
                    Text(
                      l10n.adminDeleteRemoveData,
                      style:
                          const TextStyle(fontSize: 13, color: AppTheme.red700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.adminDeleteIrreversible,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.red800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.adminDeleteConfirmQuestion,
                style: const TextStyle(fontSize: 13, color: AppTheme.gray600),
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
                      child: Text(l10n.commonCancel),
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
                      child: Text(l10n.adminDeleteConfirmButton),
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
