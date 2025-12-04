import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/screens/observer_page/observer_page.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/google_maps_web_loader.dart';
import 'package:my_app/services/location_autocomplete_service.dart';
import 'package:my_app/services/project_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_page_header.dart';
import 'package:my_app/widgets/profile_menu_shell.dart';

class ProjectMapScreen extends StatefulWidget {
  final String? userEmail;
  final String userRole;

  const ProjectMapScreen({super.key, this.userEmail, this.userRole = 'admin'});

  @override
  State<ProjectMapScreen> createState() => _ProjectMapScreenState();
}

class _ProjectMapScreenState extends State<ProjectMapScreen> {
  static const CameraPosition _netherlandsCamera = CameraPosition(
    target: LatLng(52.1326, 5.2913),
    zoom: 6.2,
  );
  static const int _projectFetchLimit = 100;

  final ProjectService _projectService = ProjectService.instance;
  final LocationAutocompleteService _locationService =
      LocationAutocompleteService();
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;

  final Map<String, LatLng> _locationCache = {};
  List<_ProjectMapPin> _pins = const [];
  _ProjectMapPin? _selectedPin;
  bool _isLoading = true;
  bool _hasError = false;
  int _unreadNotificationCount = 0;
  bool _isMapSdkReady = !kIsWeb;
  String? _mapSdkError;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _bootstrapMap();
    if (_isAdmin) {
      _loadUnreadNotificationCount();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationService.dispose();
    super.dispose();
  }

  bool get _isAdmin => widget.userRole.toLowerCase() == 'admin';

  Future<void> _bootstrapMap() async {
    if (kIsWeb) {
      setState(() {
        _isMapSdkReady = false;
        _mapSdkError = null;
      });
      try {
        await ensureGoogleMapsSdkInitialized();
        if (!mounted) return;
        setState(() => _isMapSdkReady = true);
      } catch (error) {
        debugPrint('Failed to initialize Google Maps SDK: $error');
        if (!mounted) return;
        setState(() {
          _mapSdkError =
              'Unable to load Google Maps right now. Please check your API key.';
          _isLoading = false;
          _hasError = true;
        });
        return;
      }
    }
    await _loadProjects();
  }

  Future<void> _loadProjects() async {
    if (kIsWeb && !_isMapSdkReady) {
      return;
    }
    setState(() {
      _isLoading = true;
      _hasError = false;
      _selectedPin = null;
    });
    try {
      final projects = await _projectService.fetchProjects(
        limit: _projectFetchLimit,
      );
      final pins = await _buildPins(projects);
      if (!mounted) return;
      setState(() {
        _pins = pins;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Failed to load project map: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<List<_ProjectMapPin>> _buildPins(List<AdminProject> projects) async {
    final pins = <_ProjectMapPin>[];
    for (final project in projects) {
      if (!mounted) break;
      final position = await _lookupLatLng(project.mainLocation);
      if (position != null) {
        pins.add(_ProjectMapPin(project: project, position: position));
      }
    }
    return pins;
  }

  Future<LatLng?> _lookupLatLng(String rawLocation) async {
    final location = rawLocation.trim();
    if (location.isEmpty) return null;
    final cached = _locationCache[location];
    if (cached != null) {
      return cached;
    }
    try {
      final coordinates = await _locationService.resolveCoordinates(location);
      if (coordinates == null) {
        return null;
      }
      final position = LatLng(coordinates.latitude, coordinates.longitude);
      _locationCache[location] = position;
      return position;
    } catch (error) {
      debugPrint('Failed to geocode "$location": $error');
      return null;
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

  void _handleLogout() async {
    try {
      await AuthService.instance.signOut();
    } on AuthException catch (error) {
      _showSnack(error.message, isError: true);
      return;
    } catch (error) {
      debugPrint('Failed to sign out: $error');
      _showSnack(
        'Unable to logout right now. Please try again.',
        isError: true,
      );
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
        userEmail: widget.userEmail,
        userRole: widget.userRole,
      ),
    );
  }

  void _openObserverPage() {
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

  void _openAdminPage() {
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

  void _openAdminForProject(AdminProject project) {
    Navigator.pushNamed(
      context,
      '/admin',
      arguments: AdminPageArguments(
        userEmail: widget.userEmail,
        userRole: widget.userRole,
        initialProjectId: project.id,
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

  @override
  Widget build(BuildContext context) {
    return ProfileMenuShell(
      userEmail: widget.userEmail,
      activeDestination: ProfileMenuDestination.projectMap,
      onLogout: _handleLogout,
      onObserverTap: _openObserverPage,
      onAdminTap: _isAdmin ? _openAdminPage : null,
      onProjectsTap: _openProjectsPage,
      onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
      onProjectMapTap: () {},
      showAdminOption: _isAdmin,
      showNotificationsOption: _isAdmin,
      showProjectMapOption: _isAdmin,
      unreadNotificationCount: _unreadNotificationCount,
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
                      subtitle: 'Project Map',
                      subtitleIcon: Icons.map_outlined,
                      unreadNotificationCount: _isAdmin
                          ? _unreadNotificationCount
                          : 0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppTheme.pageGutter,
                          24,
                          AppTheme.pageGutter,
                          24,
                        ),
                        child: _buildMapContainer(),
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

  Widget _buildMapContainer() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusXL),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: _buildMapBody(),
    );
  }

  Widget _buildMapBody() {
    if (_mapSdkError != null) {
      return _MapStatusView(
        message: _mapSdkError!,
        actionLabel: 'Retry',
        onAction: _bootstrapMap,
      );
    }
    if (!_isMapSdkReady) {
      return const _MapStatusView(
        message: 'Preparing map...',
        child: CircularProgressIndicator(),
      );
    }
    if (_isLoading) {
      return const _MapStatusView(
        message: 'Loading project locations...',
        child: CircularProgressIndicator(),
      );
    }
    if (_hasError) {
      return _MapStatusView(
        message: 'Unable to load the project map right now.',
        actionLabel: 'Retry',
        onAction: _loadProjects,
      );
    }
    if (_pins.isEmpty) {
      return const _MapStatusView(
        message: 'No projects with mappable locations yet.',
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: _netherlandsCamera,
            markers: _buildMarkers(),
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => setState(() => _selectedPin = null),
            onMapCreated: (controller) => _mapController = controller,
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _MapSummaryChip(projectCount: _pins.length),
        ),
        if (_selectedPin != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _ProjectPreviewCard(
              pin: _selectedPin!,
              onClose: () => setState(() => _selectedPin = null),
              onOpenProject: () => _openAdminForProject(_selectedPin!.project),
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    return _pins
        .map(
          (pin) => Marker(
            markerId: MarkerId(pin.project.id),
            position: pin.position,
            onTap: () => setState(() => _selectedPin = pin),
          ),
        )
        .toSet();
  }
}

class _ProjectMapPin {
  final AdminProject project;
  final LatLng position;

  const _ProjectMapPin({required this.project, required this.position});
}

class _MapStatusView extends StatelessWidget {
  final String message;
  final Widget? child;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MapStatusView({
    required this.message,
    this.child,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (child != null) child!,
          if (child != null) const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppTheme.gray600),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: AppTheme.white,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectPreviewCard extends StatelessWidget {
  final _ProjectMapPin pin;
  final VoidCallback onClose;
  final VoidCallback onOpenProject;

  const _ProjectPreviewCard({
    required this.pin,
    required this.onClose,
    required this.onOpenProject,
  });

  @override
  Widget build(BuildContext context) {
    final locationLabel = pin.project.mainLocation.isEmpty
        ? 'Location unavailable'
        : pin.project.mainLocation;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: AppTheme.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pin.project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamilyHeading,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppTheme.gray500,
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              locationLabel,
              style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusPill(status: pin.project.status),
                const Spacer(),
                TextButton.icon(
                  onPressed: onOpenProject,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open in Admin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final ProjectStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.gray700,
        ),
      ),
    );
  }
}

class _MapSummaryChip extends StatelessWidget {
  final int projectCount;

  const _MapSummaryChip({required this.projectCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place_outlined, size: 16, color: AppTheme.gray600),
          const SizedBox(width: 6),
          Text(
            '$projectCount project${projectCount == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
        ],
      ),
    );
  }
}
