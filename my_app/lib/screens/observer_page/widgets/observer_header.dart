import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/screens/observer_page/models/weather_condition.dart';

class ObserverHeader extends StatelessWidget {
  final String siteLabel;
  final String locationLabel;
  final String dateLabel;
  final String timeLabel;
  final String temperatureLabel;
  final WeatherCondition weatherCondition;
  final GlobalKey profileButtonKey;
  final VoidCallback onProfileTap;

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
  });

  IconData _iconForWeather() => switch (weatherCondition) {
    WeatherCondition.cloudy => Icons.cloud_queue_rounded,
    WeatherCondition.rainy => Icons.umbrella_outlined,
    WeatherCondition.sunny => Icons.wb_sunny_rounded,
  };

  Color _iconColor() => switch (weatherCondition) {
    WeatherCondition.cloudy => AppTheme.gray500,
    WeatherCondition.rainy => const Color(0xFF2563EB),
    WeatherCondition.sunny => const Color(0xFFF59E0B),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siteLabel,
                        style: const TextStyle(
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
                GestureDetector(
                  key: profileButtonKey,
                  onTap: onProfileTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.gray50,
              border: Border(
                bottom: BorderSide(color: AppTheme.primaryOrange, width: 4),
              ),
            ),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _InfoChip(label: 'Date', value: dateLabel),
                    const SizedBox(width: 16),
                    _InfoChip(label: 'Time', value: timeLabel),
                  ],
                ),
                Row(
                  children: [
                    Icon(_iconForWeather(), size: 20, color: _iconColor()),
                    const SizedBox(width: 8),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppTheme.gray700),
        ),
      ],
    );
  }
}
