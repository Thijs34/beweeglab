import 'package:flutter/material.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/screens/admin_page/widgets/project_status_badge.dart';
import 'package:my_app/theme/app_theme.dart';

class AdminProjectListView extends StatelessWidget {
  final List<AdminProject> projects;
  final List<AdminLocationOption> locationOptions;
  final bool showNewProjectForm;
  final bool showProjectSuccess;
  final String lastCreatedProjectName;
  final ProjectStatus statusFilter;
  final Map<ProjectStatus, int> statusCounts;
  final ValueChanged<ProjectStatus> onStatusFilterChanged;
  final TextEditingController newProjectNameController;
  final TextEditingController newProjectMainLocationController;
  final TextEditingController newProjectDescriptionController;
  final TextEditingController customLocationController;
  final List<String> selectedLocationTypeIds;
  final List<String> customLocations;
  final List<String> hiddenDefaultLocationIds;
  final bool showObserverSelector;
  final String newProjectObserverSearch;
  final List<String> selectedObserverIds;
  final List<AdminObserver> allObservers;
  final List<AdminObserver> availableObserverOptions;
  final Map<String, String> newProjectErrors;
  final bool isCreatingProject;
  final VoidCallback onProjectNameChanged;
  final VoidCallback onMainLocationChanged;
  final VoidCallback onToggleForm;
  final VoidCallback onAddCustomLocation;
  final ValueChanged<String> onRemoveCustomLocation;
  final ValueChanged<String> onToggleLocationType;
  final ValueChanged<String> onHideDefaultLocation;
  final ValueChanged<String> onRestoreDefaultLocation;
  final VoidCallback onObserverSelectorToggle;
  final ValueChanged<String> onObserverSearchChanged;
  final ValueChanged<String> onAddObserver;
  final ValueChanged<String> onRemoveObserver;
  final VoidCallback onSubmitProject;
  final VoidCallback onCancelForm;
  final ValueChanged<AdminProject> onProjectTap;

  const AdminProjectListView({
    super.key,
    required this.projects,
    required this.locationOptions,
    required this.showNewProjectForm,
    required this.showProjectSuccess,
    required this.lastCreatedProjectName,
    required this.statusFilter,
    required this.statusCounts,
    required this.onStatusFilterChanged,
    required this.newProjectNameController,
    required this.newProjectMainLocationController,
    required this.newProjectDescriptionController,
    required this.customLocationController,
    required this.selectedLocationTypeIds,
    required this.customLocations,
    required this.hiddenDefaultLocationIds,
    required this.showObserverSelector,
    required this.newProjectObserverSearch,
    required this.selectedObserverIds,
    required this.allObservers,
    required this.availableObserverOptions,
    required this.newProjectErrors,
    required this.isCreatingProject,
    required this.onProjectNameChanged,
    required this.onMainLocationChanged,
    required this.onToggleForm,
    required this.onAddCustomLocation,
    required this.onRemoveCustomLocation,
    required this.onToggleLocationType,
    required this.onHideDefaultLocation,
    required this.onRestoreDefaultLocation,
    required this.onObserverSelectorToggle,
    required this.onObserverSearchChanged,
    required this.onAddObserver,
    required this.onRemoveObserver,
    required this.onSubmitProject,
    required this.onCancelForm,
    required this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showProjectSuccess)
            _SuccessBanner(projectName: lastCreatedProjectName),
          const SizedBox(height: 16),
          const Text(
            'Manage Projects',
            style: TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create and organize observation projects, assign observers, and monitor data collection',
            style: TextStyle(color: AppTheme.gray600, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _StatusFilterChips(
            selectedStatus: statusFilter,
            statusCounts: statusCounts,
            onStatusSelected: onStatusFilterChanged,
          ),
          const SizedBox(height: 16),
          if (!showNewProjectForm) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onToggleForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusLarge,
                    ),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Create New Project',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showNewProjectForm)
            _NewProjectForm(
              onProjectNameChanged: onProjectNameChanged,
              locationOptions: locationOptions,
              newProjectNameController: newProjectNameController,
              newProjectMainLocationController:
                  newProjectMainLocationController,
              newProjectDescriptionController: newProjectDescriptionController,
              customLocationController: customLocationController,
              selectedLocationTypeIds: selectedLocationTypeIds,
              customLocations: customLocations,
              hiddenDefaultLocationIds: hiddenDefaultLocationIds,
              showObserverSelector: showObserverSelector,
              newProjectObserverSearch: newProjectObserverSearch,
              selectedObserverIds: selectedObserverIds,
              allObservers: allObservers,
              availableObserverOptions: availableObserverOptions,
              errors: newProjectErrors,
              isCreatingProject: isCreatingProject,
              onMainLocationChanged: onMainLocationChanged,
              onAddCustomLocation: onAddCustomLocation,
              onRemoveCustomLocation: onRemoveCustomLocation,
              onToggleLocationType: onToggleLocationType,
              onHideDefaultLocation: onHideDefaultLocation,
              onRestoreDefaultLocation: onRestoreDefaultLocation,
              onObserverSelectorToggle: onObserverSelectorToggle,
              onObserverSearchChanged: onObserverSearchChanged,
              onAddObserver: onAddObserver,
              onRemoveObserver: onRemoveObserver,
              onSubmitProject: onSubmitProject,
              onCancelForm: onCancelForm,
            ),
          if (showNewProjectForm) const SizedBox(height: 16),
          const SizedBox(height: 24),
          Text(
            '${statusFilter.label} Projects (${projects.length})',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: AppTheme.gray200),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: AppTheme.gray300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No ${statusFilter.label.toLowerCase()} projects yet',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Create your first project to get started',
                    style: TextStyle(color: AppTheme.gray400, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            Column(
              children: projects
                  .map(
                    (project) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ProjectCard(
                        project: project,
                        locationOptions: locationOptions,
                        observerCount: project.assignedObserverIds.length,
                        observationCount: project.totalObservationCount,
                        onTap: () => onProjectTap(project),
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

class _StatusFilterChips extends StatelessWidget {
  final ProjectStatus selectedStatus;
  final Map<ProjectStatus, int> statusCounts;
  final ValueChanged<ProjectStatus> onStatusSelected;

  const _StatusFilterChips({
    required this.selectedStatus,
    required this.statusCounts,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: ProjectStatus.values.map((status) {
        final isSelected = status == selectedStatus;
        final count = statusCounts[status] ?? 0;
        return ChoiceChip(
          label: Text('${status.label} ($count)'),
          selected: isSelected,
          onSelected: (_) => onStatusSelected(status),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppTheme.white,
          selectedColor: AppTheme.orange50,
          side: BorderSide(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.gray200,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
        );
      }).toList(),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String projectName;

  const _SuccessBanner({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.green50,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.green200, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.green700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project created successfully!',
                  style: TextStyle(
                    color: AppTheme.green900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  projectName,
                  style: const TextStyle(
                    color: AppTheme.green700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewProjectForm extends StatelessWidget {
  final VoidCallback onProjectNameChanged;
  final List<AdminLocationOption> locationOptions;
  final TextEditingController newProjectNameController;
  final TextEditingController newProjectMainLocationController;
  final TextEditingController newProjectDescriptionController;
  final TextEditingController customLocationController;
  final List<String> selectedLocationTypeIds;
  final List<String> customLocations;
  final List<String> hiddenDefaultLocationIds;
  final bool showObserverSelector;
  final String newProjectObserverSearch;
  final List<String> selectedObserverIds;
  final List<AdminObserver> allObservers;
  final List<AdminObserver> availableObserverOptions;
  final Map<String, String> errors;
  final bool isCreatingProject;
  final VoidCallback onMainLocationChanged;
  final VoidCallback onAddCustomLocation;
  final ValueChanged<String> onRemoveCustomLocation;
  final ValueChanged<String> onToggleLocationType;
  final ValueChanged<String> onHideDefaultLocation;
  final ValueChanged<String> onRestoreDefaultLocation;
  final VoidCallback onObserverSelectorToggle;
  final ValueChanged<String> onObserverSearchChanged;
  final ValueChanged<String> onAddObserver;
  final ValueChanged<String> onRemoveObserver;
  final VoidCallback onSubmitProject;
  final VoidCallback onCancelForm;

  const _NewProjectForm({
    required this.onProjectNameChanged,
    required this.locationOptions,
    required this.newProjectNameController,
    required this.newProjectMainLocationController,
    required this.newProjectDescriptionController,
    required this.customLocationController,
    required this.selectedLocationTypeIds,
    required this.customLocations,
    required this.hiddenDefaultLocationIds,
    required this.showObserverSelector,
    required this.newProjectObserverSearch,
    required this.selectedObserverIds,
    required this.allObservers,
    required this.availableObserverOptions,
    required this.errors,
    required this.isCreatingProject,
    required this.onMainLocationChanged,
    required this.onAddCustomLocation,
    required this.onRemoveCustomLocation,
    required this.onToggleLocationType,
    required this.onHideDefaultLocation,
    required this.onRestoreDefaultLocation,
    required this.onObserverSelectorToggle,
    required this.onObserverSearchChanged,
    required this.onAddObserver,
    required this.onRemoveObserver,
    required this.onSubmitProject,
    required this.onCancelForm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Project',
            style: TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Project Name',
            isRequired: true,
            child: TextField(
              controller: newProjectNameController,
              decoration: InputDecoration(
                hintText: 'e.g., Parkstraat Observation Site',
                errorText: errors['name'],
              ),
              onChanged: (_) => onProjectNameChanged(),
            ),
          ),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Main Location',
            isRequired: true,
            child: TextField(
              controller: newProjectMainLocationController,
              decoration: InputDecoration(
                hintText: 'e.g., Parkstraat, Amsterdam',
                errorText: errors['mainLocation'],
              ),
              onChanged: (_) => onMainLocationChanged(),
            ),
          ),
          const SizedBox(height: 20),
          _buildLocationSection(),
          const SizedBox(height: 20),
          _buildObserverSection(),
          const SizedBox(height: 20),
          _LabeledField(
            label: 'Description (Optional)',
            child: TextField(
              controller: newProjectDescriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add project description or notes...',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isCreatingProject ? null : onCancelForm,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.gray300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCreatingProject ? null : onSubmitProject,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: isCreatingProject
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.white,
                          ),
                        )
                      : const Icon(Icons.add, size: 20),
                  label: Text(
                    isCreatingProject ? 'Creating...' : 'Create Project',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          title: 'Location Types',
          subtitle: 'Select all location types available at this site',
          isRequired: true,
        ),
        const SizedBox(height: 12),
        if (customLocations.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.purple50,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              border: Border.all(color: AppTheme.purple200),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customLocations
                  .map(
                    (location) => Chip(
                      label: Text(
                        location,
                        style: const TextStyle(color: AppTheme.white),
                      ),
                      backgroundColor: AppTheme.primaryOrange,
                      deleteIcon: const Icon(
                        Icons.close,
                        color: AppTheme.white,
                        size: 18,
                      ),
                      onDeleted: () => onRemoveCustomLocation(location),
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: customLocationController,
                decoration: const InputDecoration(
                  hintText: 'Add a custom location… (Enter or Add)',
                ),
                onSubmitted: (_) => onAddCustomLocation(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onAddCustomLocation,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
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
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            ...locationOptions
                .where(
                  (option) => !hiddenDefaultLocationIds.contains(option.id),
                )
                .map(
                  (option) => _LocationOptionTile(
                    label: option.label,
                    abbreviation: option.abbreviation,
                    selected: selectedLocationTypeIds.contains(option.id),
                    onTap: () => onToggleLocationType(option.id),
                    onRemove: () => onHideDefaultLocation(option.id),
                  ),
                ),
            ...customLocations.map((location) {
              final customId = 'custom:$location';
              return _LocationOptionTile(
                label: location,
                abbreviation: generateLocationAbbreviation(location),
                selected: selectedLocationTypeIds.contains(customId),
                onTap: () => onToggleLocationType(customId),
                onRemove: () => onRemoveCustomLocation(location),
              );
            }),
          ],
        ),
        if (hiddenDefaultLocationIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              border: Border.all(color: AppTheme.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hidden location types:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hiddenDefaultLocationIds
                      .map(
                        (id) => OutlinedButton.icon(
                          onPressed: () => onRestoreDefaultLocation(id),
                          icon: const Icon(Icons.add, size: 14),
                          label: Text(
                            locationOptions
                                .firstWhere((option) => option.id == id)
                                .label,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        if (errors.containsKey('locationTypes')) ...[
          const SizedBox(height: 8),
          Text(
            errors['locationTypes']!,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
        ],
      ],
    );
  }

  Widget _buildObserverSection() {
    final selectedObservers = selectedObserverIds
        .map(
          (id) => allObservers.where((observer) => observer.id == id).toList(),
        )
        .where((matches) => matches.isNotEmpty)
        .map((matches) => matches.first)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          label: 'Assign Observers (Optional)',
          subtitle:
              'Add team members who can collect observations for this project',
        ),
        const SizedBox(height: 12),
        if (!showObserverSelector)
          OutlinedButton.icon(
            onPressed: onObserverSelectorToggle,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: AppTheme.gray300,
                width: 2,
                style: BorderStyle.solid,
              ),
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusMedium,
                ),
              ),
            ),
            icon: const Icon(Icons.add, color: AppTheme.primaryOrange),
            label: const Text(
              'Add Observer',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              border: Border.all(color: AppTheme.gray200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search observers by name or email...',
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                  onChanged: onObserverSearchChanged,
                ),
                const SizedBox(height: 12),
                if (availableObserverOptions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No observers found',
                      style: TextStyle(color: AppTheme.gray500),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: availableObserverOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final observer = availableObserverOptions[index];
                        return GestureDetector(
                          onTap: () => onAddObserver(observer.id),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium,
                              ),
                              border: Border.all(color: AppTheme.gray200),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.gray200,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: AppTheme.primaryOrange,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onObserverSelectorToggle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.gray300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        if (selectedObservers.isNotEmpty)
          Column(
            children: selectedObservers
                .map(
                  (observer) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
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
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.white,
                          ),
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
          )
        else if (!showObserverSelector)
          const Text(
            'No observers assigned yet. You can add them later.',
            style: TextStyle(
              color: AppTheme.gray400,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final AdminProject project;
  final List<AdminLocationOption> locationOptions;
  final int observationCount;
  final int observerCount;
  final VoidCallback onTap;

  const _ProjectCard({
    required this.project,
    required this.locationOptions,
    required this.observationCount,
    required this.observerCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(color: AppTheme.gray200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
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
                        project.name,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamilyHeading,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.description,
                        style: const TextStyle(color: AppTheme.gray600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppTheme.primaryOrange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              project.mainLocation.isEmpty
                                  ? 'Main location not set'
                                  : project.mainLocation,
                              style: const TextStyle(
                                color: AppTheme.gray700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ProjectStatusBadge(
                      status: project.status,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      fontSize: 11,
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.chevron_right, color: AppTheme.gray400),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.locationTypeIds
                  .map((id) => resolveLocationDisplay(id, locationOptions))
                  .map(
                    (display) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.orange50,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      child: Text(
                        '${display.label} (${display.abbreviation})',
                        style: const TextStyle(
                          color: AppTheme.primaryOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storage_outlined,
                      size: 18,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$observationCount observation${observationCount == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppTheme.gray600),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      size: 18,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$observerCount observer${observerCount == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppTheme.gray600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationOptionTile extends StatelessWidget {
  final String label;
  final String abbreviation;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _LocationOptionTile({
    required this.label,
    required this.abbreviation,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.orange50 : AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: selected ? AppTheme.primaryOrange : AppTheme.gray200,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryOrange : AppTheme.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppTheme.primaryOrange : AppTheme.gray300,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: AppTheme.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primaryOrange : AppTheme.gray100,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Text(
              abbreviation,
              style: TextStyle(
                color: selected ? AppTheme.white : AppTheme.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Widget child;

  const _LabeledField({
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray700,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? label;
  final String? subtitle;
  final bool isRequired;

  const _SectionTitle({
    this.title = '',
    this.label,
    this.subtitle,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: displayLabel,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamilyHeading,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
          ),
        ],
      ],
    );
  }
}
