import 'package:flutter/material.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu.dart';
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

  const ObserverPageArguments({this.project, this.userEmail});
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

  final String _temperatureLabel = '18°C';
  final WeatherCondition _weatherCondition = WeatherCondition.sunny;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDate = _formatDate(now);
    _currentTime = _formatTime(now);
  }

  @override
  void dispose() {
    _personIdController.dispose();
    _customLocationController.dispose();
    _activityNotesController.dispose();
    _additionalRemarksController.dispose();
    super.dispose();
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
              onAdminTap: _openAdminPage,
              onProjectsTap: _navigateToProjects,
              activeDestination: ProfileMenuDestination.observer,
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
    return Stack(children: [_buildScrollArea(), _buildBottomBar()]);
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
                          temperatureLabel: _temperatureLabel,
                          weatherCondition: _weatherCondition,
                          profileButtonKey: _profileButtonKey,
                          onProfileTap: () => setState(
                            () => _showProfileMenu = !_showProfileMenu,
                          ),
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
            _SelectionOption(label: 'Male', value: 'male'),
            _SelectionOption(label: 'Female', value: 'female'),
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
            _SelectionOption(label: 'Child', value: 'child'),
            _SelectionOption(label: 'Teen', value: 'teen'),
            _SelectionOption(label: 'Adult', value: 'adult'),
            _SelectionOption(label: 'Senior', value: 'senior'),
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
            _SelectionOption(label: 'Alone', value: 'alone'),
            _SelectionOption(label: 'Together', value: 'together'),
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
            _SelectionOption(label: 'Male', value: 'male'),
            _SelectionOption(label: 'Female', value: 'female'),
            _SelectionOption(label: 'Mixed', value: 'mixed'),
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
            _SelectionOption(label: 'Child', value: 'child'),
            _SelectionOption(label: 'Teen', value: 'teen'),
            _SelectionOption(label: 'Adult', value: 'adult'),
            _SelectionOption(label: 'Mixed', value: 'mixed'),
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
        _buildSectionLabel('Location Type', required: true),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          key: ValueKey(_locationType ?? 'location-null'),
          initialValue: _locationType,
          decoration: _inputDecoration(),
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
            _SelectionOption(label: 'Sedentary', value: 'sedentary'),
            _SelectionOption(label: 'Moving', value: 'moving'),
            _SelectionOption(label: 'Intense', value: 'intense'),
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
            _SelectionOption(label: 'Organized', value: 'organized'),
            _SelectionOption(label: 'Unorganized', value: 'unorganized'),
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
    Navigator.pushNamed(
      context,
      '/admin',
      arguments: widget.arguments?.userEmail,
    );
  }

  void _navigateToProjects() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/projects',
      ModalRoute.withName('/'),
    );
  }

  String get _headerLocation =>
      widget.arguments?.project?.name ?? 'Parkstraat Observation Site';

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

  const _ObserverHeaderDelegate({
    required this.siteLabel,
    required this.locationLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.temperatureLabel,
    required this.weatherCondition,
    required this.profileButtonKey,
    required this.onProfileTap,
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
    );
  }

  @override
  bool shouldRebuild(covariant _ObserverHeaderDelegate oldDelegate) {
    return locationLabel != oldDelegate.locationLabel ||
        dateLabel != oldDelegate.dateLabel ||
        timeLabel != oldDelegate.timeLabel ||
        temperatureLabel != oldDelegate.temperatureLabel ||
        weatherCondition != oldDelegate.weatherCondition;
  }
}

class _SelectionOption {
  final String label;
  final String value;
  const _SelectionOption({required this.label, required this.value});
}
