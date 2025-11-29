import 'package:flutter/material.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/theme/app_theme.dart';

class ProjectDetailView extends StatelessWidget {
  final AdminProject project;
  final List<AdminObserver> observers;
  final List<AdminLocationOption> locationOptions;
  final Map<String, String> filters;
  final bool showObserverSelector;
  final String observerSearchQuery;
  final bool showAddLocationField;
  final TextEditingController addLocationController;
  final List<AdminObserver> availableObservers;
  final List<ObservationRecord> filteredObservations;
  final VoidCallback onBack;
  final VoidCallback onDelete;
  final VoidCallback onToggleAddLocation;
  final VoidCallback onAddLocation;
  final ValueChanged<String> onRemoveLocation;
  final VoidCallback onToggleObserverSelector;
  final ValueChanged<String> onObserverSearchChanged;
  final ValueChanged<String> onAddObserver;
  final ValueChanged<String> onRemoveObserver;
  final VoidCallback onDownload;
  final void Function(String key, String value) onFilterChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<ObservationRecord> onEditObservation;

  const ProjectDetailView({
    super.key,
    required this.project,
    required this.observers,
    required this.locationOptions,
    required this.filters,
    required this.showObserverSelector,
    required this.observerSearchQuery,
    required this.showAddLocationField,
    required this.addLocationController,
    required this.availableObservers,
    required this.filteredObservations,
    required this.onBack,
    required this.onDelete,
    required this.onToggleAddLocation,
    required this.onAddLocation,
    required this.onRemoveLocation,
    required this.onToggleObserverSelector,
    required this.onObserverSearchChanged,
    required this.onAddObserver,
    required this.onRemoveObserver,
    required this.onDownload,
    required this.onFilterChanged,
    required this.onClearFilters,
    required this.onEditObservation,
  });

  @override
  Widget build(BuildContext context) {
    final assignedObservers = project.assignedObserverIds
        .map((id) => observers.where((obs) => obs.id == id).toList())
        .where((matches) => matches.isNotEmpty)
        .map((matches) => matches.first)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: OutlinedButton.icon(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.gray300),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back to Projects'),
            ),
          ),
          const SizedBox(height: 16),
          _ProjectInfoCard(
            project: project,
            observerCount: assignedObservers.length,
            observationCount: project.observations.length,
            onDelete: onDelete,
          ),
          const SizedBox(height: 16),
          _LocationTypesCard(
            project: project,
            locationOptions: locationOptions,
            showAddLocationField: showAddLocationField,
            addLocationController: addLocationController,
            onToggleAddLocation: onToggleAddLocation,
            onAddLocation: onAddLocation,
            onRemoveLocation: onRemoveLocation,
          ),
          const SizedBox(height: 16),
          _AssignedObserversCard(
            assignedObservers: assignedObservers,
            showObserverSelector: showObserverSelector,
            observerSearchQuery: observerSearchQuery,
            availableObservers: availableObservers,
            onToggleObserverSelector: onToggleObserverSelector,
            onObserverSearchChanged: onObserverSearchChanged,
            onAddObserver: onAddObserver,
            onRemoveObserver: onRemoveObserver,
          ),
          const SizedBox(height: 16),
          _ObservationDataCard(
            project: project,
            locationOptions: locationOptions,
            filters: filters,
            filteredObservations: filteredObservations,
            onFilterChanged: onFilterChanged,
            onClearFilters: onClearFilters,
            onDownload: onDownload,
            onEditObservation: onEditObservation,
          ),
        ],
      ),
    );
  }
}

class _ProjectInfoCard extends StatelessWidget {
  final AdminProject project;
  final int observationCount;
  final int observerCount;
  final VoidCallback onDelete;

  const _ProjectInfoCard({
    required this.project,
    required this.observationCount,
    required this.observerCount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryOrange.withOpacity(0.05),
                  AppTheme.primaryOrange.withOpacity(0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.borderRadiusLarge),
              ),
              border: const Border(bottom: BorderSide(color: AppTheme.gray200)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamilyHeading,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project.description,
                        style: const TextStyle(color: AppTheme.gray600),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.red200),
                    foregroundColor: AppTheme.red600,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storage_outlined,
                      color: AppTheme.primaryOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$observationCount observation${observationCount == 1 ? '' : 's'} recorded',
                      style: const TextStyle(
                        color: AppTheme.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      color: AppTheme.primaryOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$observerCount observer${observerCount == 1 ? '' : 's'} assigned',
                      style: const TextStyle(
                        color: AppTheme.gray700,
                        fontWeight: FontWeight.w600,
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

class _LocationTypesCard extends StatelessWidget {
  final AdminProject project;
  final List<AdminLocationOption> locationOptions;
  final bool showAddLocationField;
  final TextEditingController addLocationController;
  final VoidCallback onToggleAddLocation;
  final VoidCallback onAddLocation;
  final ValueChanged<String> onRemoveLocation;

  const _LocationTypesCard({
    required this.project,
    required this.locationOptions,
    required this.showAddLocationField,
    required this.addLocationController,
    required this.onToggleAddLocation,
    required this.onAddLocation,
    required this.onRemoveLocation,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Location Types',
      trailing: ElevatedButton.icon(
        onPressed: onToggleAddLocation,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 36),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Location'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAddLocationField) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
                border: Border.all(color: AppTheme.gray200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: addLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Add location',
                      ),
                      onSubmitted: (_) => onAddLocation(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onAddLocation,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (project.locationTypeIds.isEmpty)
            const Text(
              'No location types configured',
              style: TextStyle(color: AppTheme.gray500),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.locationTypeIds
                  .map(
                    (id) => _LocationChip(
                      display: resolveLocationDisplay(id, locationOptions),
                      onRemove: () => onRemoveLocation(id),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _AssignedObserversCard extends StatelessWidget {
  final List<AdminObserver> assignedObservers;
  final bool showObserverSelector;
  final String observerSearchQuery;
  final List<AdminObserver> availableObservers;
  final VoidCallback onToggleObserverSelector;
  final ValueChanged<String> onObserverSearchChanged;
  final ValueChanged<String> onAddObserver;
  final ValueChanged<String> onRemoveObserver;

  const _AssignedObserversCard({
    required this.assignedObservers,
    required this.showObserverSelector,
    required this.observerSearchQuery,
    required this.availableObservers,
    required this.onToggleObserverSelector,
    required this.onObserverSearchChanged,
    required this.onAddObserver,
    required this.onRemoveObserver,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Assigned Observers',
      trailing: ElevatedButton.icon(
        onPressed: onToggleObserverSelector,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Observer'),
      ),
      child: Column(
        children: [
          if (showObserverSelector)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: AppTheme.gray200),
              ),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search observers by name or email...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: onObserverSearchChanged,
                  ),
                  const SizedBox(height: 12),
                  if (availableObservers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        observerSearchQuery.isEmpty
                            ? 'All observers are already assigned'
                            : 'No observers found',
                        style: const TextStyle(color: AppTheme.gray500),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final observer = availableObservers[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: AppTheme.gray200,
                              child: Icon(
                                Icons.person,
                                color: AppTheme.gray600,
                              ),
                            ),
                            title: Text(
                              observer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              observer.email,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              onPressed: () => onAddObserver(observer.id),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: availableObservers.length,
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onToggleObserverSelector,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.gray300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          if (assignedObservers.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Column(
                children: const [
                  Icon(Icons.group_outlined, size: 48, color: AppTheme.gray300),
                  SizedBox(height: 8),
                  Text(
                    'No observers assigned yet',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Click "Add Observer" to assign team members',
                    style: TextStyle(fontSize: 12, color: AppTheme.gray400),
                  ),
                ],
              ),
            )
          else
            Column(
              children: assignedObservers
                  .map(
                    (observer) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.gray50,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusLarge,
                        ),
                        border: Border.all(color: AppTheme.gray200),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppTheme.primaryOrange,
                            child: Icon(Icons.person, color: AppTheme.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  observer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.gray900,
                                  ),
                                ),
                                Text(
                                  observer.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemoveObserver(observer.id),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ObservationDataCard extends StatelessWidget {
  final AdminProject project;
  final List<AdminLocationOption> locationOptions;
  final Map<String, String> filters;
  final List<ObservationRecord> filteredObservations;
  final void Function(String key, String value) onFilterChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onDownload;
  final ValueChanged<ObservationRecord> onEditObservation;

  const _ObservationDataCard({
    required this.project,
    required this.locationOptions,
    required this.filters,
    required this.filteredObservations,
    required this.onFilterChanged,
    required this.onClearFilters,
    required this.onDownload,
    required this.onEditObservation,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = filters.values.any((value) => value != 'all');
    return _SectionCard(
      title: 'Observation Data',
      subtitle: hasFilters
          ? '${filteredObservations.length} of ${project.observations.length} records'
          : '${project.observations.length} records collected',
      trailing: project.observations.isEmpty
          ? null
          : ElevatedButton.icon(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
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
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (project.observations.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: AppTheme.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 18,
                        color: AppTheme.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const Spacer(),
                      if (hasFilters)
                        TextButton(
                          onPressed: onClearFilters,
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _FilterDropdown(
                        value: filters['gender']!,
                        onChanged: (value) => onFilterChanged('gender', value),
                        options: const ['all', 'male', 'female'],
                        label: 'Gender',
                      ),
                      _FilterDropdown(
                        value: filters['ageGroup']!,
                        onChanged: (value) =>
                            onFilterChanged('ageGroup', value),
                        options: const [
                          'all',
                          'child',
                          'teen',
                          'adult',
                          'senior',
                        ],
                        label: 'Age',
                      ),
                      _FilterDropdown(
                        value: filters['socialContext']!,
                        onChanged: (value) =>
                            onFilterChanged('socialContext', value),
                        options: const ['all', 'alone', 'together'],
                        label: 'Social',
                      ),
                      _FilterDropdown(
                        value: filters['activityLevel']!,
                        onChanged: (value) =>
                            onFilterChanged('activityLevel', value),
                        options: const ['all', 'sitting', 'moving', 'intense'],
                        label: 'Level',
                      ),
                      _FilterDropdown(
                        value: filters['activityType']!,
                        onChanged: (value) =>
                            onFilterChanged('activityType', value),
                        options: const ['all', 'organized', 'unorganized'],
                        label: 'Type',
                      ),
                      _FilterDropdown(
                        value: filters['locationType']!,
                        onChanged: (value) =>
                            onFilterChanged('locationType', value),
                        options: ['all', ...project.locationTypeIds],
                        label: 'Location',
                        optionBuilder: (value) => value == 'all'
                            ? 'Location'
                            : resolveLocationDisplay(
                                value,
                                locationOptions,
                              ).label,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (project.observations.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.storage_outlined,
                    size: 48,
                    color: AppTheme.gray300,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No observation data yet',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Data will appear here once observers start collecting',
                    style: TextStyle(fontSize: 12, color: AppTheme.gray400),
                  ),
                ],
              ),
            )
          else if (filteredObservations.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              child: Column(
                children: const [
                  Icon(Icons.search, size: 48, color: AppTheme.gray300),
                  SizedBox(height: 8),
                  Text(
                    'No observations match your filters',
                    style: TextStyle(color: AppTheme.gray500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Try adjusting your filter criteria',
                    style: TextStyle(fontSize: 12, color: AppTheme.gray400),
                  ),
                ],
              ),
            )
          else
            Column(
              children: filteredObservations
                  .map(
                    (record) => _ObservationCard(
                      record: record,
                      locationOptions: locationOptions,
                      onEdit: () => onEditObservation(record),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  final ObservationRecord record;
  final List<AdminLocationOption> locationOptions;
  final VoidCallback onEdit;

  const _ObservationCard({
    required this.record,
    required this.locationOptions,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final locationDisplay = resolveLocationDisplay(
      record.locationTypeId,
      locationOptions,
    );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryOrange,
                child: Text(
                  '#${record.personId}',
                  style: const TextStyle(color: AppTheme.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                record.timestamp,
                style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onEdit,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                  ),
                  foregroundColor: AppTheme.primaryOrange,
                  minimumSize: const Size(0, 32),
                ),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ObservationRow(label: 'Gender', value: record.gender),
          _ObservationRow(label: 'Age', value: record.ageGroup),
          _ObservationRow(label: 'Social', value: record.socialContext),
          _ObservationRow(label: 'Activity', value: record.activityLevel),
          _ObservationRow(label: 'Type', value: record.activityType),
          _ObservationRow(label: 'Location', value: locationDisplay.label),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Notes',
              style: TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
                border: Border.all(color: AppTheme.gray200),
              ),
              child: Text(
                record.notes,
                style: const TextStyle(color: AppTheme.gray700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ObservationRow extends StatelessWidget {
  final String label;
  final String value;

  const _ObservationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamilyHeading,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final LocationDisplayData display;
  final VoidCallback onRemove;

  const _LocationChip({required this.display, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.orange50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on,
            size: 16,
            color: AppTheme.primaryOrange,
          ),
          const SizedBox(width: 6),
          Text(
            '${display.label} (${display.abbreviation})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            padding: const EdgeInsets.only(left: 4),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String label;
  final String Function(String value)? optionBuilder;

  const _FilterDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
    required this.label,
    this.optionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DropdownButtonFormField<String>(
        value: value,
        items: options
            .map(
              (option) => DropdownMenuItem(
                value: option,
                child: Text(
                  optionBuilder?.call(option) ?? _formatLabel(option),
                ),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  String _formatLabel(String value) {
    if (value == 'all') return label;
    return value[0].toUpperCase() + value.substring(1);
  }
}
