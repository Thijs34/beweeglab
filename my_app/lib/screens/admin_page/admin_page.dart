import 'package:flutter/material.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/screens/admin_page/widgets/admin_header.dart';
import 'package:my_app/screens/admin_page/widgets/observation_edit_dialog.dart';
import 'package:my_app/screens/admin_page/widgets/project_detail_view.dart';
import 'package:my_app/screens/admin_page/widgets/project_list_view.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu.dart';

/// Admin Page that mirrors the React Admin Panel UI
class AdminPage extends StatefulWidget {
  final String? userEmail;

  const AdminPage({super.key, this.userEmail});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey _profileButtonKey = GlobalKey();
  bool _showProfileMenu = false;

  late List<AdminProject> _projects;
  String? _selectedProjectId;

  bool _showDeleteDialog = false;
  String? _projectPendingDelete;

  bool _showProjectSuccess = false;
  String _lastCreatedProjectName = '';

  // New project form state
  bool _showNewProjectForm = false;
  final TextEditingController _newProjectNameController =
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
    _projects = AdminDataRepository.initialProjects();
  }

  @override
  void dispose() {
    _newProjectNameController.dispose();
    _newProjectDescriptionController.dispose();
    _customLocationController.dispose();
    _addLocationController.dispose();
    super.dispose();
  }

  AdminProject? get _selectedProject {
    if (_selectedProjectId == null) return null;
    return _projects.firstWhere(
      (project) => project.id == _selectedProjectId,
      orElse: () => _projects.first,
    );
  }

  void _toggleProfileMenu() {
    setState(() => _showProfileMenu = !_showProfileMenu);
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _navigateToProjects() {
    Navigator.pushNamed(context, '/projects', arguments: widget.userEmail);
  }

  void _navigateToObserver() {
    Navigator.pushNamed(
      context,
      '/observer',
      arguments: ObserverPageArguments(
        project: null,
        userEmail: widget.userEmail,
      ),
    );
  }

  void _navigateToAdmin() {
    _showProfileMenu = false;
    setState(() {});
  }

  void _toggleNewProjectForm() {
    setState(() => _showNewProjectForm = !_showNewProjectForm);
  }

  void _resetNewProjectForm({bool rebuild = true}) {
    void clearState() {
      _newProjectNameController.clear();
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
    final query = _newProjectObserverSearch.toLowerCase();
    return AdminDataRepository.observers.where((observer) {
      final alreadySelected = _newProjectObserverIds.contains(observer.id);
      if (alreadySelected) return false;
      if (query.isEmpty) return true;
      return observer.name.toLowerCase().contains(query) ||
          observer.email.toLowerCase().contains(query);
    }).toList();
  }

  void _handleCreateProject() {
    final errors = <String, String>{};
    if (_newProjectNameController.text.trim().isEmpty) {
      errors['name'] = 'Please enter a project name';
    }
    if (_newProjectLocationTypeIds.isEmpty) {
      errors['locationTypes'] = 'Please select at least one location type';
    }

    setState(() => _newProjectErrors = errors);
    if (errors.isNotEmpty) return;

    setState(() => _isCreatingProject = true);

    Future.delayed(const Duration(milliseconds: 400), () {
      final project = AdminProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _newProjectNameController.text.trim(),
        description: _newProjectDescriptionController.text.trim(),
        locationTypeIds: List<String>.from(_newProjectLocationTypeIds),
        assignedObserverIds: List<String>.from(_newProjectObserverIds),
        observations: const [],
      );

      setState(() {
        _projects = [..._projects, project];
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
    });
  }

  void _clearNewProjectError(String key) {
    if (!_newProjectErrors.containsKey(key)) return;
    setState(() {
      _newProjectErrors.remove(key);
    });
  }

  void _handleProjectTap(AdminProject project) {
    setState(() {
      _selectedProjectId = project.id;
      _showObserverSelector = false;
      _observerSearchQuery = '';
      _showAddLocationField = false;
      _addLocationController.clear();
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

  void _confirmProjectDeletion() {
    if (_projectPendingDelete == null) return;
    setState(() {
      _projects = _projects
          .where((project) => project.id != _projectPendingDelete)
          .toList();
      if (_selectedProjectId == _projectPendingDelete) {
        _selectedProjectId = null;
      }
      _showDeleteDialog = false;
      _projectPendingDelete = null;
    });
  }

  void _toggleObserverSelector() {
    setState(() => _showObserverSelector = !_showObserverSelector);
  }

  List<AdminObserver> get _availableObserversForProject {
    final project = _selectedProject;
    if (project == null) return [];
    final query = _observerSearchQuery.toLowerCase();
    return AdminDataRepository.observers.where((observer) {
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
    final updated = project.copyWith(
      assignedObserverIds: [...project.assignedObserverIds, id],
    );
    _updateProject(updated);
  }

  void _removeObserverFromProject(String id) {
    final project = _selectedProject;
    if (project == null) return;
    final updated = project.copyWith(
      assignedObserverIds: project.assignedObserverIds
          .where((obsId) => obsId != id)
          .toList(),
    );
    _updateProject(updated);
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
            locationTypeIds: List<String>.from(updated.locationTypeIds),
            assignedObserverIds: List<String>.from(updated.assignedObserverIds),
            observations: List<ObservationRecord>.from(updated.observations),
          );
        }
        return project;
      }).toList();
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
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: selectedProject == null
                              ? AdminProjectListView(
                                  projects: _projects,
                                  locationOptions:
                                      AdminDataRepository.locationOptions,
                                  showNewProjectForm: _showNewProjectForm,
                                  showProjectSuccess: _showProjectSuccess,
                                  lastCreatedProjectName:
                                      _lastCreatedProjectName,
                                  newProjectNameController:
                                      _newProjectNameController,
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
                                  selectedObserverIds: _newProjectObserverIds,
                                  allObservers: AdminDataRepository.observers,
                                  availableObserverOptions:
                                      _availableObserversForNewProject,
                                  newProjectErrors: _newProjectErrors,
                                  isCreatingProject: _isCreatingProject,
                                  onProjectNameChanged: () =>
                                      _clearNewProjectError('name'),
                                  onToggleForm: _toggleNewProjectForm,
                                  onAddCustomLocation: _handleAddCustomLocation,
                                  onRemoveCustomLocation: _removeCustomLocation,
                                  onToggleLocationType:
                                      _toggleLocationTypeInNewProject,
                                  onHideDefaultLocation: _hideDefaultLocation,
                                  onRestoreDefaultLocation:
                                      _restoreDefaultLocation,
                                  onObserverSelectorToggle:
                                      _toggleNewProjectObserverSelector,
                                  onObserverSearchChanged: (value) => setState(
                                    () => _newProjectObserverSearch = value,
                                  ),
                                  onAddObserver: _addObserverToNewProject,
                                  onRemoveObserver:
                                      _removeObserverFromNewProject,
                                  onSubmitProject: _handleCreateProject,
                                  onCancelForm: _resetNewProjectForm,
                                  onProjectTap: _handleProjectTap,
                                )
                              : ProjectDetailView(
                                  project: selectedProject,
                                  observers: AdminDataRepository.observers,
                                  locationOptions:
                                      AdminDataRepository.locationOptions,
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
                onAdminTap: _navigateToAdmin,
                onProjectsTap: _navigateToProjects,
                activeDestination: ProfileMenuDestination.admin,
              ),
            if (_showDeleteDialog && _projectPendingDelete != null)
              Builder(
                builder: (context) {
                  final projectForDialog = _projects.firstWhere(
                    (project) => project.id == _projectPendingDelete,
                    orElse: () => _projects.first,
                  );
                  return _DeleteDialogOverlay(
                    project: projectForDialog,
                    observationCount: projectForDialog.observations.length,
                    onCancel: _cancelProjectDeletion,
                    onConfirm: _confirmProjectDeletion,
                  );
                },
              ),
          ],
        ),
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
        color: Colors.black.withOpacity(0.4),
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
