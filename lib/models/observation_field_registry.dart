import 'package:my_app/models/observation_field.dart';

/// Provides the canonical list of standard observation fields shared by every
/// project. Custom fields can be appended on top of these defaults per project.
class ObservationFieldRegistry {
  const ObservationFieldRegistry._();

  static const String genderFieldId = 'core.gender';
  static const String ageGroupFieldId = 'core.ageGroup';
  static const String socialContextFieldId = 'core.socialContext';
  static const String locationTypeFieldId = 'core.locationType';
  static const String customLocationFieldId = 'core.customLocationLabel';
  static const String activityLevelFieldId = 'core.activityLevel';
  static const String activityTypeFieldId = 'core.activityType';
  static const String activityNotesFieldId = 'core.activityNotes';
  static const String remarksFieldId = 'core.additionalRemarks';
  static const String groupSizeFieldId = 'group.size';
  static const String groupGenderMixFieldId = 'group.genderMix';
  static const String groupAgeMixFieldId = 'group.ageMix';

  /// Returns a defensive copy of the standard field definitions to seed new
  /// projects. Callers are free to append custom definitions to the list.
  static List<ObservationField> defaultFields() {
    return List<ObservationField>.from(_defaultFieldSet);
  }

  static final List<ObservationField> _defaultFieldSet =
      List.unmodifiable(<ObservationField>[
    ObservationField(
      id: genderFieldId,
      label: 'Gender',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 10,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'male', label: 'Male'),
          ObservationFieldOption(id: 'female', label: 'Female'),
        ],
      ),
    ),
    ObservationField(
      id: ageGroupFieldId,
      label: 'Age Group',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 20,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: '11-and-younger', label: '11 and younger'),
          ObservationFieldOption(id: '12-17', label: '12 – 17'),
          ObservationFieldOption(id: '18-24', label: '18 – 24'),
          ObservationFieldOption(id: '25-44', label: '25 – 44'),
          ObservationFieldOption(id: '45-64', label: '45 – 64'),
          ObservationFieldOption(id: '65-plus', label: '65+'),
        ],
      ),
    ),
    ObservationField(
      id: socialContextFieldId,
      label: 'Social Context',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 30,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'alone', label: 'Alone'),
          ObservationFieldOption(id: 'together', label: 'Together'),
        ],
      ),
    ),
    ObservationField(
      id: groupSizeFieldId,
      label: 'Group Size',
      type: ObservationFieldType.number,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 40,
      helperText: 'Only required when recording a group entry.',
      config: NumberObservationFieldConfig(
        minValue: 1,
        maxValue: 60,
        allowDecimal: false,
      ),
    ),
    ObservationField(
      id: groupGenderMixFieldId,
      label: 'Gender Mix',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 50,
      helperText: 'Only required when recording a group entry.',
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'male', label: 'Male'),
          ObservationFieldOption(id: 'female', label: 'Female'),
          ObservationFieldOption(id: 'mixed', label: 'Mixed'),
        ],
      ),
    ),
    ObservationField(
      id: groupAgeMixFieldId,
      label: 'Age Mix',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 60,
      helperText: 'Only required when recording a group entry.',
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'child', label: 'Child'),
          ObservationFieldOption(id: 'teen', label: 'Teen'),
          ObservationFieldOption(id: 'adult', label: 'Adult'),
          ObservationFieldOption(id: 'mixed', label: 'Mixed'),
        ],
      ),
    ),
    ObservationField(
      id: locationTypeFieldId,
      label: 'Location Type',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 70,
      helperText: 'Defaults can be overridden per project.',
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'cruyff-court', label: 'Cruyff Court (C)'),
          ObservationFieldOption(
            id: 'basketball-field',
            label: 'Basketball Field (B)',
          ),
          ObservationFieldOption(id: 'grass-field', label: 'Grass Field (G)'),
          ObservationFieldOption(id: 'playground', label: 'Playground (P)'),
          ObservationFieldOption(id: 'skate-park', label: 'Skate Park (S)'),
          ObservationFieldOption(id: 'custom', label: 'Custom'),
        ],
        allowOtherOption: true,
      ),
    ),
    ObservationField(
      id: customLocationFieldId,
      label: 'Custom Location Label',
      type: ObservationFieldType.text,
      isStandard: true,
      isEnabled: true,
      displayOrder: 80,
      helperText: 'Shown when "Custom" location type is selected.',
      config: TextObservationFieldConfig(
        maxLength: 60,
        placeholder: 'Describe the exact spot',
      ),
    ),
    ObservationField(
      id: activityLevelFieldId,
      label: 'Activity Level',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 90,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'sedentary', label: 'Sedentary'),
          ObservationFieldOption(id: 'moving', label: 'Moving'),
          ObservationFieldOption(id: 'intense', label: 'Intense'),
        ],
      ),
    ),
    ObservationField(
      id: activityTypeFieldId,
      label: 'Activity Type',
      type: ObservationFieldType.dropdown,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 100,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(id: 'organized', label: 'Organized'),
          ObservationFieldOption(id: 'unorganized', label: 'Unorganized'),
        ],
      ),
    ),
    ObservationField(
      id: activityNotesFieldId,
      label: 'Activity Notes',
      type: ObservationFieldType.text,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 110,
      config: TextObservationFieldConfig(
        maxLength: 200,
        placeholder: 'Describe what is happening',
      ),
    ),
    ObservationField(
      id: remarksFieldId,
      label: 'Additional Remarks',
      type: ObservationFieldType.text,
      isStandard: true,
      isEnabled: true,
      displayOrder: 120,
      config: TextObservationFieldConfig(
        maxLength: 400,
        multiline: true,
        placeholder: 'Any extra observations',
      ),
    ),
  ]);
}
