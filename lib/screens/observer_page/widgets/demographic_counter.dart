import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';

/// A widget that displays a list of demographic categories with increment/decrement buttons
class DemographicCounter extends StatelessWidget {
  final String title;
  final String? helperText;
  final Map<String, int> counts;
  final List<DemographicCategory> categories;
  final ValueChanged<Map<String, int>> onCountsChanged;
  final bool showHeader;
  final int? maxTotal;

  const DemographicCounter({
    super.key,
    required this.title,
    this.helperText,
    required this.counts,
    required this.categories,
    required this.onCountsChanged,
    this.showHeader = true,
    this.maxTotal,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = counts.values.fold<int>(0, (sum, value) => sum + value);
    final bool canIncrement = maxTotal == null || totalCount < maxTotal!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          if (helperText != null && helperText!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              helperText!,
              style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
          ],
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.gray50,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: AppTheme.gray200, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < categories.length; i++) ...[
                _CategoryRow(
                  category: categories[i],
                  count: counts[categories[i].id] ?? 0,
                  onIncrement:
                      canIncrement ? () => _handleIncrement(categories[i].id) : null,
                  onDecrement: () => _handleDecrement(categories[i].id),
                ),
                if (i < categories.length - 1)
                  const Divider(height: 1, color: AppTheme.gray200),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _handleIncrement(String categoryId) {
    if (maxTotal != null) {
      final totalCount = counts.values.fold<int>(0, (sum, value) => sum + value);
      if (totalCount >= maxTotal!) {
        return;
      }
    }
    final updated = Map<String, int>.from(counts);
    updated[categoryId] = (updated[categoryId] ?? 0) + 1;
    onCountsChanged(updated);
  }

  void _handleDecrement(String categoryId) {
    final updated = Map<String, int>.from(counts);
    final current = updated[categoryId] ?? 0;
    if (current > 0) {
      updated[categoryId] = current - 1;
    }
    onCountsChanged(updated);
  }
}

class _CategoryRow extends StatelessWidget {
  final DemographicCategory category;
  final int count;
  final VoidCallback? onIncrement;
  final VoidCallback onDecrement;

  const _CategoryRow({
    required this.category,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.gray900,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.remove,
            onPressed: count > 0 ? onDecrement : null,
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.gray300, width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamilyHeading,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _CounterButton(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CounterButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onPressed != null
                ? AppTheme.primaryOrange
                : AppTheme.gray200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null ? Colors.white : AppTheme.gray400,
          ),
        ),
      ),
    );
  }
}

class DemographicCategory {
  final String id;
  final String label;

  const DemographicCategory({required this.id, required this.label});
}
