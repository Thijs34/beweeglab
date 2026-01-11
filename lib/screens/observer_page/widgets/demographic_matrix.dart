import 'package:flutter/material.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/screens/observer_page/models/observer_entry.dart';

/// A widget that allows selecting combinations of gender and age for group observations
class DemographicMatrix extends StatelessWidget {
  final String? helperText;
  final List<DemographicPair> pairs;
  final List<GenderOption> genderOptions;
  final List<AgeOption> ageOptions;
  final ValueChanged<List<DemographicPair>> onPairsChanged;
  final int maxTotal;

  const DemographicMatrix({
    super.key,
    this.helperText,
    required this.pairs,
    required this.genderOptions,
    required this.ageOptions,
    required this.onPairsChanged,
    required this.maxTotal,
  });

  int get currentTotal => pairs.length;

  @override
  Widget build(BuildContext context) {
    // Ensure we have exactly maxTotal pairs
    _ensurePairsCount();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPairsList(),
      ],
    );
  }

  void _ensurePairsCount() {
    if (pairs.length != maxTotal) {
      final List<DemographicPair> updated;
      
      if (pairs.length < maxTotal) {
        // Increasing group size - add new pairs
        updated = List<DemographicPair>.generate(
          maxTotal,
          (index) {
            if (index < pairs.length) {
              return pairs[index];
            }
            // Create empty pair with no pre-selected values
            return const DemographicPair(
              genderId: '',
              ageId: '',
            );
          },
        );
      } else {
        // Decreasing group size - truncate list
        updated = pairs.sublist(0, maxTotal);
      }
      
      // Use post-frame callback to update without build errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onPairsChanged(updated);
      });
    }
  }

  Widget _buildPairsList() {

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.gray200, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < pairs.length; i++) ...[
            _PairRow(
              index: i,
              pair: pairs[i],
              genderOptions: genderOptions,
              ageOptions: ageOptions,
              onUpdate: (updated) => _handleUpdate(i, updated),
            ),
            if (i < pairs.length - 1)
              const Divider(height: 1, color: AppTheme.gray200),
          ],
        ],
      ),
    );
  }

  void _handleUpdate(int index, DemographicPair updated) {
    final newPairs = List<DemographicPair>.from(pairs);
    newPairs[index] = updated;
    onPairsChanged(newPairs);
  }
}

class _PairRow extends StatelessWidget {
  final int index;
  final DemographicPair pair;
  final List<GenderOption> genderOptions;
  final List<AgeOption> ageOptions;
  final ValueChanged<DemographicPair> onUpdate;

  const _PairRow({
    required this.index,
    required this.pair,
    required this.genderOptions,
    required this.ageOptions,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildGenderDropdown(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAgeDropdown(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gray300, width: 1),
      ),
      child: DropdownButton<String>(
        value: pair.genderId,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.gray900,
          fontWeight: FontWeight.w500,
        ),
        items: genderOptions.map((gender) {
          return DropdownMenuItem<String>(
            value: gender.id,
            child: Row(
              children: [
                Icon(gender.icon, size: 16, color: AppTheme.gray700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    gender.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onUpdate(DemographicPair(genderId: value, ageId: pair.ageId));
          }
        },
      ),
    );
  }

  Widget _buildAgeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gray300, width: 1),
      ),
      child: DropdownButton<String>(
        value: pair.ageId,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, size: 20),
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.gray900,
          fontWeight: FontWeight.w500,
        ),
        items: ageOptions.map((age) {
          return DropdownMenuItem<String>(
            value: age.id,
            child: Text(
              age.label,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onUpdate(DemographicPair(genderId: pair.genderId, ageId: value));
          }
        },
      ),
    );
  }
}

class GenderOption {
  final String id;
  final String label;
  final IconData icon;

  const GenderOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class AgeOption {
  final String id;
  final String label;

  const AgeOption({
    required this.id,
    required this.label,
  });
}
