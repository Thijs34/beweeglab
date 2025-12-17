import 'package:flutter/material.dart';
import 'package:my_app/l10n/l10n.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/screens/observer_page/models/weather_condition.dart';
import 'package:my_app/widgets/profile_avatar_button.dart';

// A reusable header widget for the Observer dashboard with the prefetched data. Takes less space
class ObserverHeader extends StatelessWidget {
  final String siteLabel;
  final String locationLabel;
  final String dateLabel;
  final String timeLabel;
  final String temperatureLabel;
  final WeatherCondition weatherCondition;
  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;
  final int unreadNotificationCount;

  const ObserverHeader({
    super.key,
    required this.siteLabel,
    required this.locationLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.temperatureLabel,
    required this.weatherCondition,
    required this.profileButtonKey,
    required this.onProfileTap,
    this.unreadNotificationCount = 0,
  });

  IconData _iconForWeather() => switch (weatherCondition) {
    WeatherCondition.cloudy => Icons.cloud_queue_rounded,
    WeatherCondition.rainy => Icons.umbrella_outlined,
    WeatherCondition.sunny => Icons.wb_sunny_rounded,
  };

  Color _iconColor() => switch (weatherCondition) {
    WeatherCondition.cloudy => AppTheme.gray500,
    WeatherCondition.rainy => AppTheme.gray700,
    WeatherCondition.sunny => AppTheme.primaryOrange,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppTheme.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: AppTheme.headerPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siteLabel,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontFamily: AppTheme.fontFamilyHeading,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ) ??
                            const TextStyle(
                              fontFamily: AppTheme.fontFamilyHeading,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppTheme.primaryOrange,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              locationLabel,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamilyHeading,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ProfileAvatarButton(
                  buttonKey: profileButtonKey,
                  onTap: onProfileTap,
                  unreadCount: unreadNotificationCount,
                ),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;

              final bool compactChips = width < 380;
              double horizontalPadding;
              double chipSpacing;
              double weatherPadding;
              double weatherGap;

              if (width < 285) {
                horizontalPadding = 4;
                chipSpacing = 0;
                weatherPadding = 3;
                weatherGap = 1;
              } else if (width < 305) {
                horizontalPadding = 6;
                chipSpacing = 2;
                weatherPadding = 5;
                weatherGap = 3;
              } else if (width < 330) {
                horizontalPadding = 10;
                chipSpacing = 4;
                weatherPadding = 6;
                weatherGap = 4;
              } else if (width < 360) {
                horizontalPadding = 12;
                chipSpacing = 6;
                weatherPadding = 8;
                weatherGap = 6;
              } else {
                horizontalPadding = 20;
                chipSpacing = 12;
                weatherPadding = 10;
                weatherGap = 8;
              }

              return Container(
                decoration: const BoxDecoration(
                  color: AppTheme.gray50,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.primaryOrange, width: 4),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _InfoChip(
                          label: l10n.observerDateLabel,
                          value: dateLabel,
                          compact: compactChips,
                        ),
                        SizedBox(width: chipSpacing),
                        _InfoChip(
                          label: l10n.observerTimeLabel,
                          value: timeLabel,
                          compact: compactChips,
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: weatherPadding,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.gray200, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_iconForWeather(), size: 18, color: _iconColor()),
                          SizedBox(width: weatherGap),
                          Text(
                            temperatureLabel,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray700,
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
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool compact;

  const _InfoChip({
    required this.label,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.gray200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppTheme.gray700),
          ),
        ],
      ),
    );
  }
}
