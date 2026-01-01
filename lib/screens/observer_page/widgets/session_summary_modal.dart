import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/screens/observer_page/models/observer_entry.dart';
import 'package:my_app/screens/observer_page/models/observation_mode.dart';
import 'package:my_app/screens/observer_page/models/weather_condition.dart';

class SessionSummaryModal extends StatelessWidget {
  final List<ObserverEntry> entries;
  final String currentDate;
  final String locationLabel;
  final String temperatureLabel;
  final WeatherCondition weatherCondition;
  final VoidCallback onSubmitSession;
  final VoidCallback onCancel;

  const SessionSummaryModal({
    super.key,
    required this.entries,
    required this.currentDate,
    required this.locationLabel,
    required this.temperatureLabel,
    required this.weatherCondition,
    required this.onSubmitSession,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Positioned.fill(
      child: Material(
        color: AppTheme.white,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pageGutter,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppTheme.maxContentWidth,
                    ),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusXL),
                          border:
                              Border.all(color: AppTheme.gray200, width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusXL),
                          child: Column(
                            children: [
                              _buildHeader(l10n),
                              Expanded(
                                child: entries.isEmpty
                                    ? _buildEmptyState(l10n)
                                    : _buildSummaryContent(l10n),
                              ),
                              _buildBottomButtons(l10n),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.gray200, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.observerSummaryTitle,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            locationLabel,
            style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_outlined, size: 72, color: AppTheme.gray300),
          const SizedBox(height: 16),
          Text(
            l10n.observerSummaryEmptyTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.observerSummaryEmptySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(AppLocalizations l10n) {
    final stats = _SummaryStats(entries, l10n);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryCard(
            title: l10n.observerSummaryTotalRecorded,
            child: Column(
              children: [
                _DividerLabel(label: l10n.observerSummaryEntries(entries.length)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        background: const Color(0xFFFFF3E0),
                        valueColor: Color(0xFFFE5C01),
                        label: l10n.observerSummaryIndividuals,
                        value: stats.individuals.toString(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatPill(
                        background: const Color(0xFFFFE0B2),
                        valueColor: const Color(0xFFFE5C01),
                        label: l10n.observerSummaryGroups,
                        value: stats.groups.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DividerLabel(label: l10n.observerSummaryGroupObservations),
                const SizedBox(height: 4),
                Text(
                  '${stats.groupPercentage}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: l10n.observerSummaryDemographics,
            child: Row(
              children: [
                Expanded(
                  child: _CenteredStat(
                    label: l10n.observerSummaryMales,
                    value: stats.males.toString(),
                    color: const Color(0xFFBF360C),
                  ),
                ),
                Container(width: 1, height: 60, color: AppTheme.gray100),
                Expanded(
                  child: _CenteredStat(
                    label: l10n.observerSummaryFemales,
                    value: stats.females.toString(),
                    color: AppTheme.gray900,
                  ),
                ),
                Container(width: 1, height: 60, color: AppTheme.gray100),
                Expanded(
                  child: _CenteredStat(
                    label: l10n.observerSummaryChildren,
                    value: stats.children.toString(),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: l10n.observerSummaryActivityLevels,
            child: Column(
              children: [
                _KeyValueRow(
                  label: l10n.observerSummaryActivitySedentary,
                  value: stats.activitySedentary.toString(),
                ),
                const Divider(height: 24, color: AppTheme.gray100),
                _KeyValueRow(
                  label: l10n.observerSummaryActivityMoving,
                  value: stats.activityMoving.toString(),
                ),
                const Divider(height: 24, color: AppTheme.gray100),
                _KeyValueRow(
                  label: l10n.observerSummaryActivityIntense,
                  value: stats.activityIntense.toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: l10n.observerSummarySessionDetails,
            child: Column(
              children: [
                _KeyValueRow(label: l10n.observerSummaryLocation, value: stats.locationsLabel),
                const Divider(height: 24, color: AppTheme.gray100),
                _KeyValueRow(label: l10n.observerSummaryDate, value: currentDate),
                const Divider(height: 24, color: AppTheme.gray100),
                _KeyValueRow(label: l10n.observerSummaryTime, value: stats.timeRangeLabel),
                const Divider(height: 24, color: AppTheme.gray100),
                _KeyValueRow(
                  label: l10n.observerSummaryWeather,
                  value: '$temperatureLabel \u2022 ${_readableWeatherLabel(l10n)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.gray200, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.gray300, width: 1),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  foregroundColor: AppTheme.gray700,
                ),
                child: Text(l10n.commonCancel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onSubmitSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(l10n.observerSummarySubmit),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _readableWeatherLabel(AppLocalizations l10n) {
    return switch (weatherCondition) {
      WeatherCondition.cloudy => l10n.weatherCloudy,
      WeatherCondition.rainy => l10n.weatherRainy,
      WeatherCondition.sunny => l10n.weatherSunny,
    };
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SummaryCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gray200, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final Color background;
  final Color valueColor;
  final String label;
  final String value;

  const _StatPill({
    required this.background,
    required this.valueColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.gray600),
          ),
        ],
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  final String label;

  const _DividerLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppTheme.gray100)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.gray500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: AppTheme.gray100)),
      ],
    );
  }
}

class _CenteredStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CenteredStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.gray600),
        ),
      ],
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.gray600),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryStats {
  final AppLocalizations l10n;
  final int individuals;
  final int groups;
  final int groupPercentage;
  final int males;
  final int females;
  final int children;
  final int activitySedentary;
  final int activityMoving;
  final int activityIntense;
  final String locationsLabel;
  final String timeRangeLabel;

  _SummaryStats(List<ObserverEntry> entries, this.l10n)
    : individuals = entries
          .where((e) => e.mode == ObservationMode.individual)
          .length,
      groups = entries.where((e) => e.mode == ObservationMode.group).length,
      groupPercentage = entries.isEmpty
          ? 0
          : ((entries.where((e) => e.mode == ObservationMode.group).length /
                        entries.length) *
                    100)
                .round(),
      males = entries.fold(0, (prev, entry) {
        if (entry.individual?.gender == 'male') return prev + 1;
        return prev;
      }),
      females = entries.fold(0, (prev, entry) {
        if (entry.individual?.gender == 'female') return prev + 1;
        return prev;
      }),
      children = entries.fold(0, (prev, entry) {
        if (entry.individual?.ageGroup == 'child') return prev + 1;
        return prev;
      }),
      activitySedentary = entries
          .where((e) => e.shared.activityLevel == 'sedentary')
          .length,
      activityMoving = entries
          .where((e) => e.shared.activityLevel == 'moving')
          .length,
      activityIntense = entries
          .where((e) => e.shared.activityLevel == 'intense')
          .length,
      locationsLabel = _formatLocations(entries, l10n),
      timeRangeLabel = _formatTimeRange(entries);

  static String _formatLocations(
    List<ObserverEntry> entries,
    AppLocalizations l10n,
  ) {
    final labels = entries
        .map(
          (e) => _humanLocation(
            e.shared.locationType,
            e.shared.customLocation,
            l10n,
          ),
        )
        .toSet();
    if (labels.isEmpty) return '—';
    if (labels.length == 1) return labels.first;
    return l10n.observerSummaryLocationMultiple;
  }

  static String _humanLocation(
    String locationType,
    String? customLocation,
    AppLocalizations l10n,
  ) {
    switch (locationType) {
      case 'cruyff-court':
        return l10n.observerSummaryLocationCruyff;
      case 'basketball-field':
        return l10n.observerSummaryLocationBasketball;
      case 'grass-field':
        return l10n.observerSummaryLocationGrass;
      case 'custom':
        return customLocation?.isNotEmpty == true
            ? customLocation!
            : l10n.observerSummaryLocationCustom;
      default:
        return locationType;
    }
  }

  static String _formatTimeRange(List<ObserverEntry> entries) {
    if (entries.isEmpty) return '—';
    final sorted = List<ObserverEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final start = sorted.first.timestamp;
    final end = sorted.last.timestamp;
    return '${_formatTime(start)} — ${_formatTime(end)}';
  }

  static String _formatTime(DateTime dt) {
    final hours = dt.hour.toString().padLeft(2, '0');
    final minutes = dt.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
