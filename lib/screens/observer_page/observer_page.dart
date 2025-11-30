import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/project_selection_service.dart';
import 'package:my_app/screens/observer_page/models/observation_mode.dart';
import 'package:my_app/screens/observer_page/models/observer_entry.dart';
import 'package:my_app/screens/observer_page/models/weather_condition.dart';
import 'package:my_app/screens/observer_page/widgets/observer_header.dart';
import 'package:my_app/screens/observer_page/widgets/observer_option_button.dart';
import 'package:my_app/screens/observer_page/widgets/observer_section_card.dart';
import 'package:my_app/screens/observer_page/widgets/session_summary_modal.dart';
import 'package:my_app/screens/observer_page/widgets/success_overlay.dart';

class ObserverPageArguments {
  final Project? project;
  final String? userEmail;
  final String userRole;

  const ObserverPageArguments({
    this.project,
    this.userEmail,
    this.userRole = 'observer',
  });
}

class ObserverPage extends StatefulWidget {
  final ObserverPageArguments? arguments;

  const ObserverPage({super.key, this.arguments});

  @override
  State<ObserverPage> createState() => _ObserverPageState();
}

class _ObserverPageState extends State<ObserverPage> {
  static const Color _pageBackground = Color(0xFFF8FAFC);

  final GlobalKey _profileButtonKey = GlobalKey();

  final TextEditingController _personIdController = TextEditingController(
    text: '1',
  );
  final TextEditingController _customLocationController =
      TextEditingController();
  final TextEditingController _activityNotesController =
      TextEditingController();
  final TextEditingController _additionalRemarksController =
      TextEditingController();

  ObservationMode _mode = ObservationMode.individual;
  bool _showProfileMenu = false;
  bool _showSuccessOverlay = false;
  bool _showSummary = false;
  bool _isSubmitting = false;
  bool _isEditingPersonId = false;
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
    final ProjectSelectionService _projectSelectionService =
      ProjectSelectionService.instance;
  StreamSubscription<int>? _notificationCountSubscription;
    VoidCallback? _projectSelectionListener;
  int _unreadNotificationCount = 0;

  String _personId = '1';
  int _personCounter = 1;

  String? _gender;
  String? _ageGroup;
  String? _socialContext;
  String? _locationType;
  String? _activityLevel;
  String? _activityType;

  int _groupSize = 4;
  String? _genderMix;
  String? _ageMix;

  final List<ObserverEntry> _sessionEntries = [];
  Map<String, String> _errors = {};

  late final String _currentDate;
  late final String _currentTime;

  String _temperatureLabel = '--°C';
  WeatherCondition _weatherCondition = WeatherCondition.sunny;
  bool _isWeatherLoading = false;

  bool get _isAdmin => (widget.arguments?.userRole ?? 'observer') == 'admin';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = _formatDate(now);
    _currentTime = _formatTime(now);
    _fetchWeather();
    if (_isAdmin) {
      _startNotificationWatcher();
    }
    final initialProject = widget.arguments?.project;
    if (initialProject != null) {
      _projectSelectionService.setActiveProject(initialProject);
    }
    _projectSelectionListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _projectSelectionService.selectedProjectListenable
        .addListener(_projectSelectionListener!);
  }

  @override
  void dispose() {
    _personIdController.dispose();
    _customLocationController.dispose();
    _activityNotesController.dispose();
    _additionalRemarksController.dispose();
    _notificationCountSubscription?.cancel();
    if (_projectSelectionListener != null) {
      _projectSelectionService.selectedProjectListenable
          .removeListener(_projectSelectionListener!);
    }
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          SafeArea(child: _buildBaseContent()),
          if (_showProfileMenu)
            ProfileMenu(
              profileButtonKey: _profileButtonKey,
              userEmail: widget.arguments?.userEmail,
              onClose: () => setState(() => _showProfileMenu = false),
              onLogout: _handleLogout,
              onObserverTap: () {},
              onAdminTap: _isAdmin ? _openAdminPage : null,
              onProjectsTap: _navigateToProjects,
              onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
              activeDestination: ProfileMenuDestination.observer,
              showAdminOption: _isAdmin,
              showNotificationsOption: _isAdmin,
              unreadNotificationCount: _isAdmin ? _unreadNotificationCount : 0,
            ),
          if (_showSuccessOverlay)
            ObserverSuccessOverlay(
              mode: _mode,
              personId: _personIdController.text,
              groupSize: _groupSize,
            ),
          if (_showSummary)
            SessionSummaryModal(
              entries: _sessionEntries,
              currentDate: _currentDate,
              locationLabel: _headerLocation,
              temperatureLabel: _temperatureLabel,
              weatherCondition: _weatherCondition,
              onSubmitSession: _handleSubmitSession,
              onCancel: _handleCancelSummary,
            ),
        ],
      ),
    );
  }

  Widget _buildBaseContent() {
    final hasProject = _activeProject != null;
    return Stack(
      children: [
        _buildScrollArea(),
        _buildBottomBar(),
        if (!hasProject) Positioned.fill(child: _buildNoProjectOverlay()),
      ],
    );
  }

  Widget _buildScrollArea() {
    return Align(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _ObserverHeaderDelegate(
                          siteLabel: 'InnoBeweegLab',
                          locationLabel: _headerLocation,
                          dateLabel: _currentDate,
                          timeLabel: _currentTime,
                          temperatureLabel: _isWeatherLoading
                              ? 'Loading...'
                              : _temperatureLabel,
                          weatherCondition: _weatherCondition,
                          profileButtonKey: _profileButtonKey,
                          onProfileTap: () => setState(
                            () => _showProfileMenu = !_showProfileMenu,
                          ),
                          unreadNotificationCount: _isAdmin
                              ? _unreadNotificationCount
                              : 0,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          color: AppTheme.gray50,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Column(
                            children: [
                              ObserverSectionCard(
                                padding: const EdgeInsets.all(12),
                                child: _buildModeToggle(),
                              ),
                              const SizedBox(height: 8),
                              ObserverSectionCard(child: _buildFormCard()),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.white,
          border: Border(top: BorderSide(color: AppTheme.gray200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmitEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: AppTheme.white,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.white,
                                ),
                              ),
                            )
                          : Text(
                              _mode == ObservationMode.group
                                  ? 'Submit Group'
                                  : 'Submit Person',
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _handleFinishSession,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppTheme.gray300,
                          width: 1,
                        ),
                        foregroundColor: AppTheme.gray700,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusMedium,
                          ),
                        ),
                      ),
                      child: const Text('Finish Session'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchWeather() async {
    setState(() => _isWeatherLoading = true);
    const double latitude = 51.4416;
    const double longitude = 5.4697;
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() => _isWeatherLoading = false);
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final current = data['current_weather'];
      if (current is! Map<String, dynamic>) {
        if (!mounted) return;
        setState(() => _isWeatherLoading = false);
        return;
      }

      final double? temperature = (current['temperature'] as num?)?.toDouble();
      final int? weatherCode = (current['weathercode'] as num?)?.toInt();

      if (!mounted) return;
      setState(() {
        if (temperature != null) {
          _temperatureLabel = '${temperature.round()}°C';
        }
        _weatherCondition = _mapWeatherCode(weatherCode);
        _isWeatherLoading = false;
      });
    } catch (error) {
      debugPrint('Failed to fetch weather: $error');
      if (!mounted) return;
      setState(() => _isWeatherLoading = false);
    }
  }

  WeatherCondition _mapWeatherCode(int? code) {
    if (code == null) {
      return WeatherCondition.sunny;
    }
    if (code == 0 || code == 1) {
      return WeatherCondition.sunny;
    }
    if ((code >= 2 && code <= 3) || (code >= 45 && code <= 48)) {
      return WeatherCondition.cloudy;
    }
    if ((code >= 51 && code <= 67) ||
        (code >= 71 && code <= 82) ||
        (code >= 95 && code <= 99)) {
      return WeatherCondition.rainy;
    }
    return WeatherCondition.sunny;
  }

  Widget _buildModeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Observation Mode',
          style: TextStyle(fontSize: 12, color: AppTheme.gray700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ObserverOptionButton(
                label: 'Individual',
                icon: Icons.person_outline,
                iconSize: 18,
                height: 40,
                selectedBorderWidth: 2,
                selected: _mode == ObservationMode.individual,
                onTap: () => setState(() => _mode = ObservationMode.individual),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ObserverOptionButton(
                label: 'Group',
                icon: Icons.groups_outlined,
                iconSize: 18,
                height: 40,
                selectedBorderWidth: 2,
                selected: _mode == ObservationMode.group,
                onTap: () => setState(() => _mode = ObservationMode.group),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mode == ObservationMode.individual)
          _buildIndividualFields()
        else
          _buildGroupFields(),
        const SizedBox(height: 12),
        _buildSharedFields(),
      ],
    );
  }

  Widget _buildIndividualFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonIdField(),
        const SizedBox(height: 16),
        _buildSectionLabel('Gender', required: true, isSmall: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: 'Male',
              value: 'male',
              icon: Icons.male_outlined,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Female',
              value: 'female',
              icon: Icons.female_outlined,
              iconSize: 18,
            ),
          ],
          value: _gender,
          onChanged: (value) => setState(() {
            _gender = value;
            _errors.remove('gender');
          }),
        ),
        _buildErrorText('gender'),
        const SizedBox(height: 16),
        _buildSectionLabel('Age Group', required: true, isSmall: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: '11 en jonger',
              value: '11-and-younger',
              icon: Icons.child_care,
              iconSize: 18,
            ),
            _SelectionOption(
              label: '12 t/m 17',
              value: '12-17',
              icon: Icons.school,
              iconSize: 18,
            ),
            _SelectionOption(
              label: '18 t/m 24',
              value: '18-24',
              icon: Icons.directions_run,
              iconSize: 18,
            ),
            _SelectionOption(
              label: '25 t/m 44',
              value: '25-44',
              icon: Icons.work_outline,
              iconSize: 18,
            ),
            _SelectionOption(
              label: '45 t/m 64',
              value: '45-64',
              icon: Icons.psychology_alt,
              iconSize: 18,
            ),
            _SelectionOption(
              label: '65 +',
              value: '65-plus',
              icon: Icons.elderly,
              iconSize: 20,
            ),
          ],
          value: _ageGroup,
          onChanged: (value) => setState(() {
            _ageGroup = value;
            _errors.remove('ageGroup');
          }),
        ),
        _buildErrorText('ageGroup'),
        const SizedBox(height: 16),
        _buildSectionLabel('Social Context', required: true, isSmall: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: 'Alone',
              value: 'alone',
              icon: Icons.person_outline,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Together',
              value: 'together',
              icon: Icons.groups_outlined,
              iconSize: 18,
            ),
          ],
          value: _socialContext,
          onChanged: (value) => setState(() {
            _socialContext = value;
            _errors.remove('socialContext');
          }),
        ),
        _buildErrorText('socialContext'),
      ],
    );
  }

  Widget _buildGroupFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Group Info',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamilyHeading,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Reset form',
              onPressed: () => _resetInputs(preservePersonId: true),
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: AppTheme.gray400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSectionLabel('Group Size', required: true, isSmall: true),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepperButton(icon: Icons.remove, onTap: _decrementGroupSize),
            const SizedBox(width: 12),
            Container(
              width: 64,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gray300, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$_groupSize',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamilyHeading,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildStepperButton(icon: Icons.add, onTap: _incrementGroupSize),
          ],
        ),
        const SizedBox(height: 16),
        _buildSectionLabel('Gender Mix', required: true, isSmall: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: 'Male',
              value: 'male',
              icon: Icons.male,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Female',
              value: 'female',
              icon: Icons.female,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Mixed',
              value: 'mixed',
              icon: Icons.groups,
              iconSize: 20,
            ),
          ],
          columns: 3,
          value: _genderMix,
          onChanged: (value) => setState(() {
            _genderMix = value;
            _errors.remove('genderMix');
          }),
        ),
        _buildErrorText('genderMix'),
        const SizedBox(height: 16),
        _buildSectionLabel('Age Mix', required: true, isSmall: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: 'Child',
              value: 'child',
              icon: Icons.child_care,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Teen',
              value: 'teen',
              icon: Icons.school,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Adult',
              value: 'adult',
              icon: Icons.work_outline,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Mixed',
              value: 'mixed',
              icon: Icons.groups_outlined,
              iconSize: 20,
            ),
          ],
          value: _ageMix,
          onChanged: (value) => setState(() {
            _ageMix = value;
            _errors.remove('ageMix');
          }),
        ),
        _buildErrorText('ageMix'),
        const SizedBox(height: 16),
        const Text(
          'Activity Info',
          style: TextStyle(
            fontFamily: AppTheme.fontFamilyHeading,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildSharedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Location Type', required: true, isSmall: true),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            key: ValueKey(_locationType ?? 'location-null'),
            initialValue: _locationType,
            isDense: true,
            decoration: _inputDecoration().copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            items: const [
              DropdownMenuItem(
                value: 'cruyff-court',
                child: Text('C - Cruyff Court'),
              ),
              DropdownMenuItem(
                value: 'basketball-field',
                child: Text('B - Basketball Field'),
              ),
              DropdownMenuItem(
                value: 'grass-field',
                child: Text('G - Grass Field'),
              ),
              DropdownMenuItem(value: 'custom', child: Text('Custom')),
            ],
            onChanged: (value) => setState(() {
              _locationType = value;
              _errors.remove('locationType');
              if (value != 'custom') {
                _customLocationController.clear();
                _errors.remove('customLocation');
              }
            }),
            hint: const Text('Select location type'),
          ),
        ),
        _buildErrorText('locationType'),
        if (_locationType == 'custom') ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: TextField(
              controller: _customLocationController,
              onChanged: (_) =>
                  setState(() => _errors.remove('customLocation')),
              decoration: _inputDecoration().copyWith(
                hintText: 'Enter custom location',
              ),
            ),
          ),
          _buildErrorText('customLocation'),
        ],
        const SizedBox(height: 16),
        _buildSectionLabel('Activity Level', required: true, isSmall: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: 'Sedentary',
              value: 'sedentary',
              icon: Icons.self_improvement,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Moving',
              value: 'moving',
              icon: Icons.directions_walk,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Intense',
              value: 'intense',
              icon: Icons.whatshot,
              iconSize: 20,
            ),
          ],
          columns: 3,
          value: _activityLevel,
          onChanged: (value) => setState(() {
            _activityLevel = value;
            _errors.remove('activityLevel');
          }),
        ),
        _buildErrorText('activityLevel'),
        const SizedBox(height: 16),
        _buildSectionLabel('Activity Type', required: true),
        const SizedBox(height: 4),
        _buildOptionsGrid(
          options: const [
            _SelectionOption(
              label: 'Organized',
              value: 'organized',
              icon: Icons.event_available,
              iconSize: 18,
            ),
            _SelectionOption(
              label: 'Unorganized',
              value: 'unorganized',
              icon: Icons.sports_handball,
              iconSize: 18,
            ),
          ],
          value: _activityType,
          onChanged: (value) => setState(() {
            _activityType = value;
            _errors.remove('activityType');
          }),
        ),
        _buildErrorText('activityType'),
        const SizedBox(height: 16),
        _buildSectionLabel('Activity Notes', required: true),
        const SizedBox(height: 4),
        SizedBox(
          height: 44,
          child: TextField(
            controller: _activityNotesController,
            onChanged: (_) => setState(() => _errors.remove('activityNotes')),
            decoration: _inputDecoration().copyWith(
              hintText: 'e.g., Playing basketball, Running, Walking...',
            ),
          ),
        ),
        _buildErrorText('activityNotes'),
        const SizedBox(height: 16),
        _buildSectionLabel('Additional Remarks (optional)'),
        const SizedBox(height: 4),
        TextField(
          controller: _additionalRemarksController,
          maxLines: 4,
          minLines: 3,
          decoration: _inputDecoration().copyWith(
            hintText: 'Any unusual observations or additional notes...',
          ),
        ),
      ],
    );
  }

  Widget _buildPersonIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Person ID',
              style: TextStyle(fontSize: 14, color: AppTheme.gray700),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Reset form',
              onPressed: () => _resetInputs(preservePersonId: true),
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: AppTheme.gray400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_isEditingPersonId)
          SizedBox(
            height: 44,
            child: TextField(
              controller: _personIdController,
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (value) => setState(() => _personId = value),
              onEditingComplete: () =>
                  setState(() => _isEditingPersonId = false),
              decoration: _inputDecoration().copyWith(hintText: 'Enter ID'),
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _isEditingPersonId = true),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.gray300, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Person #$_personId ',
                      style: const TextStyle(
                        color: AppTheme.gray900,
                        fontSize: 14,
                      ),
                      children: const [
                        TextSpan(
                          text: '(Auto ID)',
                          style: TextStyle(
                            color: AppTheme.gray500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppTheme.gray400,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsGrid({
    required List<_SelectionOption> options,
    required String? value,
    required ValueChanged<String> onChanged,
    int columns = 2,
    double gap = 8,
    double height = 40,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalGap = gap * (columns - 1);
        final double itemWidth = (constraints.maxWidth - totalGap) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: options.map((option) {
            return SizedBox(
              width: itemWidth,
              child: ObserverOptionButton(
                label: option.label,
                selected: value == option.value,
                onTap: () => onChanged(option.value),
                height: height,
                icon: option.icon,
                iconSize: option.iconSize ?? 16,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 56,
      height: 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: AppTheme.gray300, width: 2),
        ),
        child: Icon(icon, size: 22, color: AppTheme.gray700),
      ),
    );
  }

  Widget _buildSectionLabel(
    String text, {
    bool required = false,
    bool isSmall = false,
  }) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.gray700,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(fontSize: 12, color: AppTheme.gray400),
          ),
      ],
    );
  }

  Widget _buildErrorText(String key) {
    final message = _errors[key];
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Colors.red),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.gray50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.gray300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.gray300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 1),
      ),
    );
  }

  Future<void> _handleSubmitEntry() async {
    final validation = _validateCurrent();
    if (validation.isNotEmpty) {
      setState(() => _errors = validation);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final entry = _buildSnapshot();
    setState(() {
      _sessionEntries.add(entry);
      _isSubmitting = false;
      _showSuccessOverlay = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _showSuccessOverlay = false);
    _resetInputs(preservePersonId: false);
  }

  void _handleFinishSession() {
    if (!_isFormEmpty()) {
      final validation = _validateCurrent();
      if (validation.isNotEmpty) {
        setState(() => _errors = validation);
        return;
      }
      setState(() => _sessionEntries.add(_buildSnapshot()));
      _resetInputs(preservePersonId: false);
    }
    setState(() => _showSummary = true);
  }

  void _handleCancelSummary() {
    setState(() => _showSummary = false);
  }

  void _handleSubmitSession() {
    debugPrint('Submitting session with ${_sessionEntries.length} entries');
    setState(() {
      _sessionEntries.clear();
      _showSummary = false;
    });
    _navigateToProjects();
  }

  Map<String, String> _validateCurrent() {
    final validationErrors = <String, String>{};
    if (_mode == ObservationMode.individual) {
      if (_gender == null) {
        validationErrors['gender'] = 'Please select a gender';
      }
      if (_ageGroup == null) {
        validationErrors['ageGroup'] = 'Please select an age group';
      }
      if (_socialContext == null) {
        validationErrors['socialContext'] = 'Please select social context';
      }
    } else {
      if (_genderMix == null) {
        validationErrors['genderMix'] = 'Please select gender mix';
      }
      if (_ageMix == null) {
        validationErrors['ageMix'] = 'Please select age mix';
      }
    }
    if (_locationType == null) {
      validationErrors['locationType'] = 'Please select a location type';
    } else if (_locationType == 'custom' &&
        _customLocationController.text.trim().isEmpty) {
      validationErrors['customLocation'] = 'Please enter a custom location';
    }
    if (_activityLevel == null) {
      validationErrors['activityLevel'] = 'Please select an activity level';
    }
    if (_activityType == null) {
      validationErrors['activityType'] = 'Please select an activity type';
    }
    if (_activityNotesController.text.trim().isEmpty) {
      validationErrors['activityNotes'] = 'Please enter activity notes';
    }
    return validationErrors;
  }

  ObserverEntry _buildSnapshot() {
    final shared = SharedSnapshot(
      locationType: _locationType ?? '',
      customLocation: _locationType == 'custom'
          ? _customLocationController.text.trim()
          : null,
      activityLevel: _activityLevel ?? '',
      activityType: _activityType ?? '',
      activityNotes: _activityNotesController.text.trim(),
      additionalRemarks: _additionalRemarksController.text.trim(),
    );

    final timestamp = DateTime.now();
    if (_mode == ObservationMode.individual) {
      return ObserverEntry(
        mode: ObservationMode.individual,
        shared: shared,
        timestamp: timestamp,
        individual: IndividualSnapshot(
          personId: _personIdController.text.trim(),
          gender: _gender ?? '',
          ageGroup: _ageGroup ?? '',
          socialContext: _socialContext ?? '',
        ),
      );
    }

    return ObserverEntry(
      mode: ObservationMode.group,
      shared: shared,
      timestamp: timestamp,
      group: GroupSnapshot(
        groupSize: _groupSize,
        genderMix: _genderMix ?? '',
        ageMix: _ageMix ?? '',
      ),
    );
  }

  bool _isFormEmpty() {
    if (_mode == ObservationMode.individual) {
      return _gender == null &&
          _ageGroup == null &&
          _socialContext == null &&
          _locationType == null &&
          _activityLevel == null &&
          _activityType == null &&
          _activityNotesController.text.trim().isEmpty &&
          _additionalRemarksController.text.trim().isEmpty;
    }
    return _genderMix == null &&
        _ageMix == null &&
        _locationType == null &&
        _activityLevel == null &&
        _activityType == null &&
        _activityNotesController.text.trim().isEmpty &&
        _additionalRemarksController.text.trim().isEmpty &&
        _groupSize == 4;
  }

  void _resetInputs({required bool preservePersonId}) {
    final shouldIncrement = !preservePersonId;
    final nextId = shouldIncrement
        ? (_personCounter + 1).toString()
        : _personIdController.text;
    setState(() {
      _gender = null;
      _ageGroup = null;
      _socialContext = null;
      _locationType = null;
      _activityLevel = null;
      _activityType = null;
      _genderMix = null;
      _ageMix = null;
      _groupSize = 4;
      if (shouldIncrement) {
        _personCounter += 1;
        _personIdController.text = nextId;
      }
      _personId = _personIdController.text;
      _errors = {};
      _isEditingPersonId = false;
    });
    _customLocationController.clear();
    _activityNotesController.clear();
    _additionalRemarksController.clear();
  }

  void _incrementGroupSize() {
    setState(() {
      if (_groupSize < 99) {
        _groupSize += 1;
      }
    });
  }

  void _decrementGroupSize() {
    setState(() {
      if (_groupSize > 2) {
        _groupSize -= 1;
      }
    });
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openAdminPage() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin',
      arguments: AdminPageArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'observer',
      ),
    );
  }

  void _openNotificationsPage() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin-notifications',
      arguments: AdminNotificationsArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'observer',
      ),
    );
  }

  void _navigateToProjects() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/projects',
      ModalRoute.withName('/'),
      arguments: ProjectListArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'observer',
      ),
    );
  }

  String get _headerLocation =>
      _activeProject?.name ?? 'No project selected';

  Project? get _activeProject =>
      widget.arguments?.project ?? _projectSelectionService.currentProject;

  Widget _buildNoProjectOverlay() {
    return Container(
      color: AppTheme.gray50.withValues(alpha: 0.95),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 48,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                'No project selected. Please choose a project from the list before starting an observation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select a project on the Project List screen to unlock the observation tools.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.gray600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: _navigateToProjects,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: AppTheme.white,
                  ),
                  child: const Text('Back to Project List'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _ObserverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String siteLabel;
  final String locationLabel;
  final String dateLabel;
  final String timeLabel;
  final String temperatureLabel;
  final WeatherCondition weatherCondition;
  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;
  final int unreadNotificationCount;

  const _ObserverHeaderDelegate({
    required this.siteLabel,
    required this.locationLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.temperatureLabel,
    required this.weatherCondition,
    required this.profileButtonKey,
    required this.onProfileTap,
    required this.unreadNotificationCount,
  });

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => 150;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ObserverHeader(
      siteLabel: siteLabel,
      locationLabel: locationLabel,
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      temperatureLabel: temperatureLabel,
      weatherCondition: weatherCondition,
      profileButtonKey: profileButtonKey,
      onProfileTap: onProfileTap,
      unreadNotificationCount: unreadNotificationCount,
    );
  }

  @override
  bool shouldRebuild(covariant _ObserverHeaderDelegate oldDelegate) {
    return locationLabel != oldDelegate.locationLabel ||
        dateLabel != oldDelegate.dateLabel ||
        timeLabel != oldDelegate.timeLabel ||
        temperatureLabel != oldDelegate.temperatureLabel ||
        weatherCondition != oldDelegate.weatherCondition ||
        unreadNotificationCount != oldDelegate.unreadNotificationCount;
  }
}

class _SelectionOption {
  final String label;
  final String value;
  final IconData? icon;
  final double? iconSize;

  const _SelectionOption({
    required this.label,
    required this.value,
    this.icon,
    this.iconSize,
  });
}
