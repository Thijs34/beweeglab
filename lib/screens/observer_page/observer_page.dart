import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/models/navigation_arguments.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:my_app/models/observation_field_audience.dart';
import 'package:my_app/models/observation_field_registry.dart';
import 'package:my_app/models/project.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/profile_menu_shell.dart';
import 'package:my_app/services/admin_notification_service.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/observation_service.dart';
import 'package:my_app/services/person_id_service.dart';
import 'package:my_app/services/session_draft_service.dart';
import 'package:my_app/services/project_selection_service.dart';
import 'package:my_app/screens/observer_page/models/observation_mode.dart';
import 'package:my_app/screens/observer_page/models/observer_entry.dart';
import 'package:my_app/screens/observer_page/models/weather_condition.dart';
import 'package:my_app/screens/observer_page/widgets/observer_header.dart';
import 'package:my_app/screens/observer_page/widgets/observer_option_button.dart';
import 'package:my_app/screens/observer_page/widgets/observer_section_card.dart';
import 'package:my_app/screens/observer_page/widgets/session_summary_modal.dart';
import 'package:my_app/screens/observer_page/widgets/success_overlay.dart';

const Map<String, String> _kDefaultLocationLabels = {
  'cruyff-court': 'Cruyff Court (C)',
  'basketball-field': 'Basketball Field (B)',
  'grass-field': 'Grass Field (G)',
  'playground': 'Playground (P)',
  'skate-park': 'Skate Park (S)',
};

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
  static const String _kOtherOptionValue = '__other__';

  final TextEditingController _personIdController = TextEditingController(
    text: '1',
  );
  final ScrollController _scrollController = ScrollController();

  ObservationMode _mode = ObservationMode.individual;
  bool _showSuccessOverlay = false;
  bool _showSummary = false;
  bool _isSubmitting = false;
  bool _isEditingPersonId = false;
  final AdminNotificationService _notificationService =
      AdminNotificationService.instance;
  final ObservationService _observationService = ObservationService.instance;
  final PersonIdService _personIdService = PersonIdService.instance;
  final SessionDraftService _sessionDraftService = SessionDraftService.instance;
  final ProjectSelectionService _projectSelectionService =
      ProjectSelectionService.instance;
  StreamSubscription<int>? _notificationCountSubscription;
  VoidCallback? _projectSelectionListener;
  int _unreadNotificationCount = 0;

  String _personId = '1';
  int _personCounter = 1;
  String? _counterProjectKey;
  bool _counterRestored = false;
  String? _sessionProjectKey;
  bool _sessionDraftRestored = false;

  final List<ObserverEntry> _sessionEntries = [];
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, String> _fieldErrors = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _otherOptionControllers = {};
  final Map<String, List<ObservationFieldOption>> _customFieldOptions = {};

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
      setState(() => _customFieldOptions.clear());
      _resetInputs(preservePersonId: true);
      _restorePersonCounter();
      _restoreSessionDrafts();
    };
    _projectSelectionService.selectedProjectListenable.addListener(
      _projectSelectionListener!,
    );
    _restorePersonCounter();
    _restoreSessionDrafts();
  }

  @override
  void dispose() {
    _personIdController.dispose();
    _scrollController.dispose();
    _disposeFieldControllers();
    _notificationCountSubscription?.cancel();
    if (_projectSelectionListener != null) {
      _projectSelectionService.selectedProjectListenable.removeListener(
        _projectSelectionListener!,
      );
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
    return ProfileMenuShell(
      userEmail: widget.arguments?.userEmail,
      activeDestination: ProfileMenuDestination.observer,
      onLogout: _handleLogout,
      onProfileSettingsTap: _openProfileSettings,
      onObserverTap: () {},
      onAdminTap: _isAdmin ? _openAdminPage : null,
      onProjectsTap: _navigateToProjects,
      onNotificationsTap: _isAdmin ? _openNotificationsPage : null,
      onProjectMapTap: _isAdmin ? _openProjectMap : null,
      showAdminOption: _isAdmin,
      showNotificationsOption: _isAdmin,
      showProjectMapOption: _isAdmin,
      unreadNotificationCount: _isAdmin ? _unreadNotificationCount : 0,
      builder: (context, controller) {
        return Scaffold(
          backgroundColor: _pageBackground,
          body: Stack(
            children: [
              SafeArea(child: _buildBaseContent(controller)),
              if (_showSuccessOverlay)
                ObserverSuccessOverlay(
                  mode: _mode,
                  personId: _personIdController.text,
                  groupSize: _currentGroupSize,
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
      },
    );
  }

  Widget _buildBaseContent(ProfileMenuController menuController) {
    final hasProject = _activeProject != null;
    return Stack(
      children: [
        _buildScrollArea(menuController),
        _buildBottomBar(),
        if (!hasProject) Positioned.fill(child: _buildNoProjectOverlay()),
      ],
    );
  }

  Widget _buildScrollArea(ProfileMenuController menuController) {
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
                    controller: _scrollController,
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
                          profileButtonKey: menuController.profileButtonKey,
                          onProfileTap: menuController.toggleMenu,
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
                      child: Text(context.l10n.observerFinishSession),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                                ? context.l10n.observerSubmitGroup
                                : context.l10n.observerSubmitPerson,
                            ),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.observerModeLabel,
          style: const TextStyle(fontSize: 12, color: AppTheme.gray700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ObserverOptionButton(
                label: l10n.observerModeIndividual,
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
                label: l10n.observerModeGroup,
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
    final children = <Widget>[];
    if (_mode == ObservationMode.individual) {
      children
        ..add(_buildPersonIdField())
        ..add(const SizedBox(height: 16));
    }
    children.add(_buildDynamicFields());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildDynamicFields() {
    final fields = _visibleFields;
    if (fields.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.gray50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.gray200, width: 1),
        ),
        child: Text(
          context.l10n.observerNoFieldsConfigured,
          style: const TextStyle(color: AppTheme.gray600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final field in fields) ...[
          _buildFieldHeader(field),
          const SizedBox(height: 6),
          _buildFieldInput(field),
          if (_fieldErrors[field.id] != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _fieldErrors[field.id]!,
                style: const TextStyle(fontSize: 13, color: Colors.red),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildFieldHeader(ObservationField field) {
    final locale = Localizations.localeOf(context).languageCode;
    final label = field.labelForLocale(locale);
    final helper = field.helperForLocale(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
            children: [
              if (field.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppTheme.gray400),
                ),
            ],
          ),
        ),
        if (helper != null && helper.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helper,
              style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
          ),
      ],
    );
  }

  Widget _buildFieldInput(ObservationField field) {
    if (field.id == ObservationFieldRegistry.groupSizeFieldId) {
      return _buildGroupSizeField(field);
    }

    switch (field.type) {
      case ObservationFieldType.text:
        return _buildTextField(field);
      case ObservationFieldType.dropdown:
      case ObservationFieldType.multiSelect:
        final config = field.config as OptionObservationFieldConfig?;
        final allowMultiple = _fieldAllowsMultipleSelections(field, config);
        return _buildOptionField(field, config, isMultiSelect: allowMultiple);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(ObservationField field) {
    final config = field.config as TextObservationFieldConfig?;
    final rawValue = _fieldValues[field.id];
    final textValue = rawValue is String ? rawValue : '';
    final controller = _ensureTextController(field.id, textValue);
    final isMultiline = config?.multiline ?? false;
    final maxLines = isMultiline ? null : 1;
    final minLines = isMultiline ? 3 : 1;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: config?.maxLength,
      decoration: _inputDecoration().copyWith(
        hintText: config?.placeholder,
        counterText: config?.maxLength != null ? '' : null,
      ),
      onChanged: (value) => setState(() {
        _fieldValues[field.id] = value;
        _fieldErrors.remove(field.id);
      }),
    );
  }

  Widget _buildGroupSizeField(ObservationField field) {
    final config = field.config as NumberObservationFieldConfig?;
    final minValue = (config?.minValue ?? 1).round();
    final maxValue = (config?.maxValue ?? 60).round();
    int current = _currentGroupSize;
    if (current < minValue) current = minValue;
    if (current > maxValue) current = maxValue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepperButton(
          icon: Icons.remove,
          onTap: () =>
              _adjustStepperField(field.id, current - 1, minValue, maxValue),
        ),
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
            '$current',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildStepperButton(
          icon: Icons.add,
          onTap: () =>
              _adjustStepperField(field.id, current + 1, minValue, maxValue),
        ),
      ],
    );
  }

  void _adjustStepperField(
    String fieldId,
    int nextValue,
    int minValue,
    int maxValue,
  ) {
    final clamped = nextValue.clamp(minValue, maxValue);
    setState(() {
      _fieldValues[fieldId] = clamped.toString();
      _fieldErrors.remove(fieldId);
    });
  }

  void _validateOtherOptionText(
    ObservationField field,
    dynamic value,
    Map<String, String> errors,
  ) {
    final config = field.config as OptionObservationFieldConfig?;
    if (config?.allowOtherOption != true) {
      return;
    }
    final controller = _otherOptionControllers[field.id];
    final otherText = controller?.text.trim() ?? '';
    bool requiresText = false;
    if (value is String) {
      requiresText = value == _kOtherOptionValue;
    } else if (value is List) {
      requiresText = value.whereType<String>().contains(_kOtherOptionValue);
    }
    if (requiresText && otherText.isEmpty) {
      errors[field.id] = 'Please describe the other option';
    }
  }

  bool _fieldAllowsMultipleSelections(
    ObservationField field,
    OptionObservationFieldConfig? config,
  ) {
    if (config != null) {
      return config.allowMultiple;
    }
    return field.type == ObservationFieldType.multiSelect;
  }

  Widget _buildOptionField(
    ObservationField field,
    OptionObservationFieldConfig? config, {
    required bool isMultiSelect,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    final baseOptions = config?.options ?? const <ObservationFieldOption>[];
    final customOptions =
        _customFieldOptions[field.id] ?? const <ObservationFieldOption>[];
    final combinedOptions = <ObservationFieldOption>[
      ...baseOptions,
      ...customOptions,
    ];
    final allowOther = config?.allowOtherOption ?? false;
    if (combinedOptions.isEmpty && !allowOther) {
      return Text(context.l10n.observerNoOptionsConfigured);
    }

    final selectionOptions = combinedOptions
        .map(
          (option) => _SelectionOption(
            label: option.labelForLocale(locale),
            value: option.id,
            icon: _resolveOptionIcon(option),
          ),
        )
        .toList(growable: true);
    if (allowOther) {
      selectionOptions.add(
        _SelectionOption(
          label: context.l10n.observerOtherOption,
          value: _kOtherOptionValue,
          icon: Icons.edit_outlined,
        ),
      );
    }

    final rawValue = _fieldValues[field.id];
    final selectedValues = <String>{};
    if (isMultiSelect) {
      if (rawValue is List) {
        selectedValues.addAll(rawValue.whereType<String>());
      }
    } else if (rawValue is String && rawValue.isNotEmpty) {
      selectedValues.add(rawValue);
    }

    final columns = selectionOptions.length >= 4 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOptionsGrid(
          options: selectionOptions,
          selectedValues: selectedValues,
          onChanged: (value) => _handleOptionSelection(
            field.id,
            value,
            selectedValues,
            isMultiSelect,
          ),
          columns: columns,
        ),
        if (allowOther && selectedValues.contains(_kOtherOptionValue))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildOtherOptionInput(
              field: field,
              isMultiSelect: isMultiSelect,
              existingOptions: combinedOptions,
            ),
          ),
      ],
    );
  }

  Widget _buildOtherOptionInput({
    required ObservationField field,
    required bool isMultiSelect,
    required List<ObservationFieldOption> existingOptions,
  }) {
    final controller = _ensureOtherOptionController(field.id);
    void submit() {
      _handleAddCustomOption(
        field: field,
        isMultiSelect: isMultiSelect,
        existingOptions: existingOptions,
      );
    }

    return TextField(
      controller: controller,
      decoration: _inputDecoration().copyWith(
        hintText: 'Describe other value',
        suffixIcon: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add option',
          onPressed: submit,
        ),
      ),
      onSubmitted: (_) => submit(),
      onChanged: (_) => setState(() {
        _fieldErrors.remove(field.id);
      }),
    );
  }

  void _handleOptionSelection(
    String fieldId,
    String optionValue,
    Set<String> selectedValues,
    bool isMultiSelect,
  ) {
    setState(() {
      if (isMultiSelect) {
        final updated = selectedValues.toSet();
        if (updated.contains(optionValue)) {
          updated.remove(optionValue);
        } else {
          updated.add(optionValue);
        }
        _fieldValues[fieldId] = updated.toList();
      } else {
        if (selectedValues.contains(optionValue)) {
          _fieldValues.remove(fieldId);
        } else {
          _fieldValues[fieldId] = optionValue;
        }
      }

      if (optionValue != _kOtherOptionValue) {
        _otherOptionControllers[fieldId]?.text = '';
      }
      _fieldErrors.remove(fieldId);
    });
  }

  void _handleAddCustomOption({
    required ObservationField field,
    required bool isMultiSelect,
    required List<ObservationFieldOption> existingOptions,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    final controller = _ensureOtherOptionController(field.id);
    final rawLabel = controller.text.trim();
    if (rawLabel.isEmpty) {
      setState(() {
        _fieldErrors[field.id] = 'Please enter a label for the custom option';
      });
      return;
    }

    final normalizedLabel = rawLabel.toLowerCase();
    final labelExists = existingOptions.any(
      (option) => option.labelForLocale(locale).trim().toLowerCase() == normalizedLabel,
    );
    if (labelExists) {
      setState(() {
        _fieldErrors[field.id] = 'That option already exists';
      });
      return;
    }

    final slug = _slugifyCustomLabel(rawLabel);
    final existingIds = existingOptions.map((option) => option.id).toSet();
    var candidateId = 'custom:$slug';
    var collisionIndex = 2;
    while (existingIds.contains(candidateId)) {
      candidateId = 'custom:$slug-$collisionIndex';
      collisionIndex += 1;
    }

    final newOption = ObservationFieldOption(
      id: candidateId,
      label: LocalizedText(nl: rawLabel, en: rawLabel),
    );

    setState(() {
      final bucket = _customFieldOptions.putIfAbsent(field.id, () => []);
      bucket.add(newOption);
      controller.clear();
      _fieldErrors.remove(field.id);
      _selectCustomOption(
        fieldId: field.id,
        optionId: newOption.id,
        isMultiSelect: isMultiSelect,
      );
    });
  }

  void _selectCustomOption({
    required String fieldId,
    required String optionId,
    required bool isMultiSelect,
  }) {
    if (isMultiSelect) {
      final rawValue = _fieldValues[fieldId];
      final updated = rawValue is List
          ? rawValue.whereType<String>().toList()
          : <String>[];
      updated.remove(_kOtherOptionValue);
      if (!updated.contains(optionId)) {
        updated.add(optionId);
      }
      _fieldValues[fieldId] = updated;
    } else {
      _fieldValues[fieldId] = optionId;
    }
  }

  String _slugifyCustomLabel(String input) {
    final sanitized = input.trim().toLowerCase();
    final collapsed = sanitized.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final deduped = collapsed.replaceAll(RegExp(r'-{2,}'), '-');
    final trimmed = deduped.replaceAll(RegExp(r'^-+|-+$'), '');
    if (trimmed.isEmpty) {
      return 'custom-option-${DateTime.now().millisecondsSinceEpoch}';
    }
    return trimmed;
  }

  IconData? _resolveOptionIcon(ObservationFieldOption option) {
    return option.icon ??
        _inferIconFromLabel(option.id) ??
        _inferIconFromLabel(option.label.en ?? '') ??
        _inferIconFromLabel(option.label.nl);
  }

  //Might be changed if ambigous
  IconData? _inferIconFromLabel(String label) {
    final text = label.trim().toLowerCase();

    // Gender
    if (text.contains('male') || text.contains(' man') || text == 'man') {
      return Icons.male;
    }
    if (text.contains('female') || text.contains(' woman') || text == 'woman') {
      return Icons.female;
    }

    // Social context
    if (text.contains('alone') || text.contains('single')) {
      return Icons.person;
    }
    if (text.contains('together') ||
        text.contains('group') ||
        text.contains('with')) {
      return Icons.groups;
    }

    // Location-specific icons
    if (text.contains('basket') || text.contains('basketball')) {
      return Icons.sports_basketball;
    }
    if (text.contains('cruyff') ||
        text.contains('court') ||
        text.contains('soccer') ||
        text.contains('football')) {
      return Icons.sports_soccer;
    }
    if (text.contains('grass') ||
        text.contains('field') ||
        text.contains('park')) {
      return Icons.park;
    }

    // Activity-level icons
    if (text.contains('sedentary') || text.contains('sedent')) {
      return Icons.airline_seat_flat; // lying down / resting
    }
    if (text.contains('moving') ||
        text.contains('yoga') ||
        text.contains('walk')) {
      return Icons.self_improvement; // yoga / mindful movement
    }
    if (text.contains('intense') ||
        text.contains('run') ||
        text.contains('running')) {
      return Icons.directions_run;
    }

    return null;
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
    required Set<String> selectedValues,
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
                selected: selectedValues.contains(option.value),
                onTap: () => onChanged(option.value),
                height: height,
                icon: option.icon,
                iconSize: 16,
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
    if (_isSubmitting) return;

    final project = _activeProject;
    if (project == null) {
      _showSnackMessage(
        'Select a project before recording observations.',
        isError: true,
      );
      return;
    }

    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (observerUid == null) {
      _showSnackMessage('Please sign in again to continue.', isError: true);
      return;
    }

    final validation = _validateCurrent();
    if (validation.isNotEmpty) {
      setState(() {
        _fieldErrors
          ..clear()
          ..addAll(validation);
      });
      return;
    }

    final entry = _buildSnapshot();
    final success = await _submitEntry(
      entry: entry,
      project: project,
      observerUid: observerUid,
      showSuccessOverlay: true,
    );
    if (!success || !mounted) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _showSuccessOverlay = false);
    _resetInputs(preservePersonId: false);
    _scrollToTop();
  }

  Future<void> _handleFinishSession() async {
    if (_isSubmitting) return;

    await _restoreSessionDrafts();
    if (!mounted) return;

    if (!_isFormEmpty()) {
      final validation = _validateCurrent();
      if (validation.isNotEmpty) {
        setState(() {
          _fieldErrors
            ..clear()
            ..addAll(validation);
        });
        return;
      }
      final project = _activeProject;
      if (project == null) {
        _showSnackMessage(
          context.l10n.observerSelectProject,
          isError: true,
        );
        return;
      }
      final observerUid = FirebaseAuth.instance.currentUser?.uid;
      if (observerUid == null) {
        _showSnackMessage(context.l10n.observerPleaseSignIn, isError: true);
        return;
      }
      final entry = _buildSnapshot();
      final success = await _submitEntry(
        entry: entry,
        project: project,
        observerUid: observerUid,
        showSuccessOverlay: false,
      );
      if (!success || !mounted) {
        return;
      }
      _resetInputs(preservePersonId: false);
      _scrollToTop();
    }
    if (!mounted) return;
    setState(() => _showSummary = true);
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    unawaited(
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      ),
    );
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
    unawaited(_clearSessionDrafts());
    _clearPersistedPersonCounter();
    _navigateToProjects();
  }

  Map<String, String> _validateCurrent() {
    final errors = <String, String>{};
    for (final field in _visibleFields) {
      final value = _fieldValues[field.id];
      if (field.id == ObservationFieldRegistry.groupSizeFieldId) {
        final raw = (value as String?) ?? '$_currentGroupSize';
        if (raw.isEmpty) {
          if (field.isRequired) {
            errors[field.id] = context.l10n.observerEnterNumber;
          }
        } else {
          final parsed = int.tryParse(raw);
          final config = field.config as NumberObservationFieldConfig?;
          final minValue = (config?.minValue ?? 1).round();
          final maxValue = (config?.maxValue ?? 60).round();
          if (parsed == null) {
            errors[field.id] = 'Please enter a valid number';
          } else {
            if (parsed < minValue) {
              errors[field.id] = 'Must be at least $minValue';
            }
            if (parsed > maxValue) {
              errors[field.id] = 'Must be at most $maxValue';
            }
          }
        }
        continue;
      }

      switch (field.type) {
        case ObservationFieldType.text:
          final text = (value as String?)?.trim() ?? '';
          if (field.isRequired && text.isEmpty) {
            errors[field.id] = 'Please enter a value';
          }
          break;
        case ObservationFieldType.multiSelect:
        case ObservationFieldType.dropdown:
          final config = field.config as OptionObservationFieldConfig?;
          final allowMultiple = _fieldAllowsMultipleSelections(field, config);
          if (allowMultiple) {
            final selections = value is List
                ? value.whereType<String>().toList()
                : const <String>[];
            if (field.isRequired && selections.isEmpty) {
              errors[field.id] = 'Select at least one option';
            } else {
              _validateOtherOptionText(field, selections, errors);
            }
          } else {
            final selected = value as String?;
            if (field.isRequired && (selected == null || selected.isEmpty)) {
              errors[field.id] = 'Please select an option';
            } else {
              _validateOtherOptionText(field, selected, errors);
            }
          }
          break;
        default:
          final text = (value == null ? '' : value.toString()).trim();
          if (field.isRequired && text.isEmpty) {
            errors[field.id] = 'Please enter a value';
          }
          break;
      }
    }

    return errors;
  }

  ObserverEntry _buildSnapshot() {
    final locationType = _stringFieldValue(
      ObservationFieldRegistry.locationTypeFieldId,
    );
    final shared = SharedSnapshot(
      locationType: locationType,
      customLocation: locationType == 'custom'
          ? _stringFieldValueOrNull(
              ObservationFieldRegistry.customLocationFieldId,
            )
          : null,
      activityLevel: _stringFieldValue(
        ObservationFieldRegistry.activityLevelFieldId,
      ),
      activityType: _stringFieldValue(
        ObservationFieldRegistry.activityTypeFieldId,
      ),
      activityNotes: _stringFieldValue(
        ObservationFieldRegistry.activityNotesFieldId,
      ),
      additionalRemarks: _stringFieldValue(
        ObservationFieldRegistry.remarksFieldId,
      ),
    );

    final timestamp = DateTime.now();
    if (_mode == ObservationMode.individual) {
      return ObserverEntry(
        mode: ObservationMode.individual,
        shared: shared,
        timestamp: timestamp,
        individual: IndividualSnapshot(
          personId: _personIdController.text.trim(),
          gender: _stringFieldValue(ObservationFieldRegistry.genderFieldId),
          ageGroup: _stringFieldValue(ObservationFieldRegistry.ageGroupFieldId),
          socialContext: _stringFieldValue(
            ObservationFieldRegistry.socialContextFieldId,
          ),
        ),
      );
    }

    return ObserverEntry(
      mode: ObservationMode.group,
      shared: shared,
      timestamp: timestamp,
      group: GroupSnapshot(
        groupSize: _currentGroupSize,
        genderMix: _stringFieldValue(
          ObservationFieldRegistry.groupGenderMixFieldId,
        ),
        ageMix: _stringFieldValue(ObservationFieldRegistry.groupAgeMixFieldId),
      ),
    );
  }

  bool _isFormEmpty() {
    for (final field in _visibleFields) {
      if (_hasValue(field, _fieldValues[field.id])) {
        if (field.id == ObservationFieldRegistry.groupSizeFieldId &&
            _fieldValues[field.id] == null) {
          continue;
        }
        return false;
      }
    }
    return true;
  }

  bool _hasValue(ObservationField field, dynamic value) {
    if (field.id == ObservationFieldRegistry.groupSizeFieldId) {
      if (value is String) {
        return value.trim().isNotEmpty;
      }
      return value != null;
    }

    switch (field.type) {
      case ObservationFieldType.dropdown:
      case ObservationFieldType.multiSelect:
        final config = field.config as OptionObservationFieldConfig?;
        final allowMultiple = _fieldAllowsMultipleSelections(field, config);
        if (allowMultiple) {
          return value is List && value.whereType<String>().isNotEmpty;
        }
        return value is String && value.isNotEmpty;
      default:
        if (value is String) {
          return value.trim().isNotEmpty;
        }
        return value != null;
    }
  }

  void _resetInputs({required bool preservePersonId}) {
    final shouldIncrement = !preservePersonId;
    final nextId = shouldIncrement
        ? (_personCounter + 1).toString()
        : _personIdController.text;
    setState(() {
      _fieldValues.clear();
      _fieldErrors.clear();
      _disposeFieldControllers();
      if (shouldIncrement) {
        _personCounter += 1;
        _personIdController.text = nextId;
      }
      _personId = _personIdController.text;
      _isEditingPersonId = false;
    });
    if (shouldIncrement) {
      _persistPersonCounter();
    }
  }

  TextEditingController _ensureTextController(
    String fieldId,
    String initialValue,
  ) {
    final existing = _textControllers[fieldId];
    if (existing != null) {
      if (existing.text != initialValue) {
        existing
          ..text = initialValue
          ..selection = TextSelection.collapsed(offset: initialValue.length);
      }
      return existing;
    }
    final controller = TextEditingController(text: initialValue);
    _textControllers[fieldId] = controller;
    return controller;
  }

  TextEditingController _ensureOtherOptionController(String fieldId) {
    final existing = _otherOptionControllers[fieldId];
    if (existing != null) {
      return existing;
    }
    final controller = TextEditingController();
    _otherOptionControllers[fieldId] = controller;
    return controller;
  }

  void _disposeFieldControllers() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    for (final controller in _otherOptionControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    _otherOptionControllers.clear();
  }

  int get _currentGroupSize {
    final value = _fieldValues[ObservationFieldRegistry.groupSizeFieldId];
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value) ?? 4;
    }
    if (value is num) {
      return value.toInt();
    }
    return 4;
  }

  String _stringFieldValue(String fieldId) {
    final value = _fieldValues[fieldId];
    if (value is String) {
      return value.trim();
    }
    if (value is num) {
      return value.toString();
    }
    if (value is List) {
      return value.whereType<String>().join(', ');
    }
    return value?.toString().trim() ?? '';
  }

  String? _stringFieldValueOrNull(String fieldId) {
    final value = _stringFieldValue(fieldId);
    return value.isEmpty ? null : value;
  }

  Future<void> _restorePersonCounter() async {
    final project = _activeProject;
    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (project == null || observerUid == null) {
      return;
    }
    final key = '$observerUid-${project.id}';
    if (_counterProjectKey != key) {
      _counterProjectKey = key;
      _counterRestored = false;
    }
    if (_counterRestored) {
      return;
    }
    final stored = await _personIdService.getNextPersonId(
      observerUid: observerUid,
      projectId: project.id,
    );
    if (!mounted) return;
    setState(() {
      _counterRestored = true;
      if (stored != null && stored > 0) {
        _personCounter = stored;
        _personIdController.text = stored.toString();
        _personId = _personIdController.text;
      } else {
        _personCounter = 1;
        _personIdController.text = '1';
        _personId = '1';
      }
    });
  }

  Future<void> _restoreSessionDrafts() async {
    final project = _activeProject;
    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (project == null || observerUid == null) {
      return;
    }
    final key = '$observerUid-${project.id}';
    if (_sessionProjectKey != key) {
      _sessionProjectKey = key;
      _sessionDraftRestored = false;
      if (_sessionEntries.isNotEmpty) {
        if (mounted) {
          setState(() => _sessionEntries.clear());
        } else {
          _sessionEntries.clear();
        }
      }
    }
    if (_sessionDraftRestored) {
      return;
    }
    final restored = await _sessionDraftService.restoreEntries(
      observerUid: observerUid,
      projectId: project.id,
    );
    if (!mounted) return;
    setState(() {
      _sessionEntries
        ..clear()
        ..addAll(restored);
      _sessionDraftRestored = true;
    });
  }

  Future<void> _persistSessionDrafts() async {
    final project = _activeProject;
    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (project == null || observerUid == null) {
      return;
    }
    await _sessionDraftService.saveEntries(
      observerUid: observerUid,
      projectId: project.id,
      entries: List<ObserverEntry>.from(_sessionEntries),
    );
  }

  Future<void> _clearSessionDrafts() async {
    final project = _activeProject;
    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (project == null || observerUid == null) {
      return;
    }
    await _sessionDraftService.clearEntries(
      observerUid: observerUid,
      projectId: project.id,
    );
    _sessionDraftRestored = false;
  }

  Future<void> _persistPersonCounter() async {
    final project = _activeProject;
    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (project == null || observerUid == null) {
      return;
    }
    final nextId = _personCounter;
    await _personIdService.saveNextPersonId(
      observerUid: observerUid,
      projectId: project.id,
      nextPersonId: nextId,
    );
  }

  Future<void> _clearPersistedPersonCounter() async {
    final project = _activeProject;
    final observerUid = FirebaseAuth.instance.currentUser?.uid;
    if (project == null || observerUid == null) {
      return;
    }
    await _personIdService.clearCounter(
      observerUid: observerUid,
      projectId: project.id,
    );
    if (!mounted) return;
    setState(() {
      _personCounter = 1;
      _personIdController.text = '1';
      _personId = '1';
    });
  }

  void _handleLogout() async {
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

  void _openProjectMap() {
    if (!_isAdmin) return;
    Navigator.pushNamed(
      context,
      '/admin-project-map',
      arguments: AdminProjectMapArguments(
        userEmail: widget.arguments?.userEmail,
        userRole: widget.arguments?.userRole ?? 'admin',
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

  void _openProfileSettings() {
    Navigator.pushNamed(
      context,
      '/profile-settings',
      arguments: ProfileSettingsArguments(
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

  String get _headerLocation => _activeProject?.name ?? 'No project selected';

  Project? get _activeProject =>
      widget.arguments?.project ?? _projectSelectionService.currentProject;

  Future<bool> _submitEntry({
    required ObserverEntry entry,
    required Project project,
    required String observerUid,
    required bool showSuccessOverlay,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await _observationService.saveObservation(
        project: project,
        entry: entry,
        observerUid: observerUid,
        observerEmail: widget.arguments?.userEmail,
      );
    } catch (error) {
      debugPrint('Failed to save observation: $error');
      if (!mounted) return false;
      setState(() => _isSubmitting = false);
      _showSnackMessage(
        'Unable to save observation right now. Please try again.',
        isError: true,
      );
      return false;
    }

    if (!mounted) {
      return true;
    }

    setState(() {
      _sessionEntries.add(entry);
      _isSubmitting = false;
      if (showSuccessOverlay) {
        _showSuccessOverlay = true;
      }
    });

    unawaited(_persistSessionDrafts());

    return true;
  }

  void _showSnackMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryOrange,
      ),
    );
  }

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
              Text(
                context.l10n.observerNoProjectTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.observerNoProjectSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.gray600),
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
                  child: Text(context.l10n.observerBackToProjectList),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ObservationField> get _orderedFields {
    final project = _activeProject;
    if (project == null) {
      return const [];
    }
    final fields = project.fields.where((field) => field.isEnabled).map((
      field,
    ) {
      if (field.id == ObservationFieldRegistry.locationTypeFieldId) {
        return _applyProjectLocationOptions(field, project);
      }
      return field;
    }).toList();
    fields.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return fields;
  }

  ObservationField _applyProjectLocationOptions(
    ObservationField field,
    Project project,
  ) {
    final config = field.config as OptionObservationFieldConfig?;
    final generated = _buildProjectLocationOptions(project.locationTypeIds);
    if (config == null || generated == null) {
      return field;
    }
    return field.copyWith(
      config: OptionObservationFieldConfig(
        options: generated,
        allowMultiple: config.allowMultiple,
        allowOtherOption: config.allowOtherOption,
      ),
    );
  }

  List<ObservationFieldOption>? _buildProjectLocationOptions(
    List<String> locationTypeIds,
  ) {
    if (locationTypeIds.isEmpty) {
      return null;
    }
    final seen = <String>{};
    final options = <ObservationFieldOption>[];
    for (final rawId in locationTypeIds) {
      final id = rawId.trim();
      if (id.isEmpty || !seen.add(id)) {
        continue;
      }
      options.add(
        ObservationFieldOption(
          id: id,
          label: LocalizedText(
            nl: _locationLabelForId(id),
            en: _locationLabelForId(id),
          ),
        ),
      );
    }
    if (options.isEmpty) {
      return null;
    }
    return options;
  }

  String _locationLabelForId(String id) {
    if (id == 'custom') {
      return 'Custom';
    }
    if (id.startsWith('custom:')) {
      final trimmed = id.substring('custom:'.length).trim();
      return trimmed.isEmpty ? 'Custom Location' : trimmed;
    }
    final mapped = _kDefaultLocationLabels[id];
    if (mapped != null) {
      return mapped;
    }
    if (id.isEmpty) {
      return 'Unknown location';
    }
    return id
        .split(RegExp(r'[-_]+'))
        .where((segment) => segment.isNotEmpty)
        .map(
          (segment) =>
              segment[0].toUpperCase() + segment.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  List<ObservationField> get _visibleFields {
    return _orderedFields.where(_shouldDisplayField).toList(growable: false);
  }

  bool _shouldDisplayField(ObservationField field) {
    final audience = resolveObservationFieldAudience(field);
    if (audience == ObservationFieldAudience.individual &&
        _mode != ObservationMode.individual) {
      return false;
    }
    if (audience == ObservationFieldAudience.group &&
        _mode != ObservationMode.group) {
      return false;
    }
    if (field.id == ObservationFieldRegistry.customLocationFieldId) {
      final locationValue =
          _fieldValues[ObservationFieldRegistry.locationTypeFieldId];
      if (locationValue != 'custom') {
        return false;
      }
    }
    return true;
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

  const _SelectionOption({required this.label, required this.value, this.icon});
}
