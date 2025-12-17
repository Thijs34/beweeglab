import 'package:flutter/material.dart';
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
  static const Set<String> _individualOnlyFieldIds = <String>{
    genderFieldId,
    ageGroupFieldId,
    socialContextFieldId,
  };

  /// Returns a defensive copy of the standard field definitions to seed new
  /// projects. Callers are free to append custom definitions to the list.
  static List<ObservationField> defaultFields() {
    return List<ObservationField>.from(_defaultFieldSet);
  }

  static final List<ObservationField>
  _defaultFieldSet = List.unmodifiable(<ObservationField>[
    ObservationField(
      id: genderFieldId,
      label: LocalizedText(nl: 'Geslacht', en: 'Gender'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.individual,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 10,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'male',
            label: LocalizedText(nl: 'Man', en: 'Male'),
            icon: Icons.male,
          ),
          ObservationFieldOption(
            id: 'female',
            label: LocalizedText(nl: 'Vrouw', en: 'Female'),
            icon: Icons.female,
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: ageGroupFieldId,
      label: LocalizedText(nl: 'Leeftijdsgroep', en: 'Age Group'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.individual,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 20,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: '11-and-younger',
            label: LocalizedText(nl: '11 jaar en jonger', en: '11 and younger'),
          ),
          ObservationFieldOption(
            id: '12-17',
            label: LocalizedText(nl: '12 – 17', en: '12 – 17'),
          ),
          ObservationFieldOption(
            id: '18-24',
            label: LocalizedText(nl: '18 – 24', en: '18 – 24'),
          ),
          ObservationFieldOption(
            id: '25-44',
            label: LocalizedText(nl: '25 – 44', en: '25 – 44'),
          ),
          ObservationFieldOption(
            id: '45-64',
            label: LocalizedText(nl: '45 – 64', en: '45 – 64'),
          ),
          ObservationFieldOption(
            id: '65-plus',
            label: LocalizedText(nl: '65+', en: '65+'),
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: socialContextFieldId,
      label: LocalizedText(nl: 'Sociale context', en: 'Social Context'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.individual,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 30,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'alone',
            label: LocalizedText(nl: 'Alleen', en: 'Alone'),
          ),
          ObservationFieldOption(
            id: 'together',
            label: LocalizedText(nl: 'Samen', en: 'Together'),
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: groupSizeFieldId,
      label: LocalizedText(nl: 'Groepsgrootte', en: 'Group Size'),
      type: ObservationFieldType.number,
      audience: ObservationFieldAudience.group,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 40,
      helperText: LocalizedText(
        nl: 'Alleen nodig bij een groepsmeting.',
        en: 'Only required when recording a group entry.',
      ),
      config: NumberObservationFieldConfig(
        minValue: 1,
        maxValue: 60,
        allowDecimal: false,
      ),
    ),
    ObservationField(
      id: groupGenderMixFieldId,
      label: LocalizedText(nl: 'Geslachtsverdeling', en: 'Gender Mix'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.group,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 50,
      helperText: LocalizedText(
        nl: 'Alleen nodig bij een groepsmeting.',
        en: 'Only required when recording a group entry.',
      ),
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'male',
            label: LocalizedText(nl: 'Man', en: 'Male'),
          ),
          ObservationFieldOption(
            id: 'female',
            label: LocalizedText(nl: 'Vrouw', en: 'Female'),
          ),
          ObservationFieldOption(
            id: 'mixed',
            label: LocalizedText(nl: 'Gemengd', en: 'Mixed'),
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: groupAgeMixFieldId,
      label: LocalizedText(nl: 'Leeftijdsverdeling', en: 'Age Mix'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.group,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 60,
      helperText: LocalizedText(
        nl: 'Alleen nodig bij een groepsmeting.',
        en: 'Only required when recording a group entry.',
      ),
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'child',
            label: LocalizedText(nl: 'Kind', en: 'Child'),
          ),
          ObservationFieldOption(
            id: 'teen',
            label: LocalizedText(nl: 'Tiener', en: 'Teen'),
          ),
          ObservationFieldOption(
            id: 'adult',
            label: LocalizedText(nl: 'Volwassene', en: 'Adult'),
          ),
          ObservationFieldOption(
            id: 'mixed',
            label: LocalizedText(nl: 'Gemengd', en: 'Mixed'),
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: locationTypeFieldId,
      label: LocalizedText(nl: 'Locatietype', en: 'Location Type'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.all,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 70,
      helperText: LocalizedText(
        nl: 'Standaardopties kunnen per project worden aangepast.',
        en: 'Defaults can be overridden per project.',
      ),
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'cruyff-court',
            label: LocalizedText(nl: 'Cruyff Court (C)', en: 'Cruyff Court (C)'),
          ),
          ObservationFieldOption(
            id: 'basketball-field',
            label: LocalizedText(nl: 'Basketbalveld (B)', en: 'Basketball Field (B)'),
          ),
          ObservationFieldOption(
            id: 'grass-field',
            label: LocalizedText(nl: 'Grasveld (G)', en: 'Grass Field (G)'),
          ),
          ObservationFieldOption(
            id: 'playground',
            label: LocalizedText(nl: 'Speelplaats (P)', en: 'Playground (P)'),
          ),
          ObservationFieldOption(
            id: 'skate-park',
            label: LocalizedText(nl: 'Skatepark (S)', en: 'Skate Park (S)'),
          ),
        ],
        allowMultiple: true,
        allowOtherOption: true,
      ),
    ),
    ObservationField(
      id: customLocationFieldId,
      label: LocalizedText(
        nl: 'Aangepaste locatiebeschrijving',
        en: 'Custom Location Label',
      ),
      type: ObservationFieldType.text,
      audience: ObservationFieldAudience.all,
      isStandard: true,
      isEnabled: true,
      displayOrder: 80,
      helperText: LocalizedText(
        nl: 'Toont een veld wanneer "Custom" is geselecteerd.',
        en: 'Shown when "Custom" location type is selected.',
      ),
      config: TextObservationFieldConfig(
        maxLength: 60,
        placeholder: 'Describe the exact spot',
      ),
    ),
    ObservationField(
      id: activityLevelFieldId,
      label: LocalizedText(nl: 'Activiteitsniveau', en: 'Activity Level'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.all,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 90,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'sedentary',
            label: LocalizedText(nl: 'Zittend', en: 'Sedentary'),
          ),
          ObservationFieldOption(
            id: 'moving',
            label: LocalizedText(nl: 'Bewegen', en: 'Moving'),
          ),
          ObservationFieldOption(
            id: 'intense',
            label: LocalizedText(nl: 'Intensief', en: 'Intense'),
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: activityTypeFieldId,
      label: LocalizedText(nl: 'Activiteitstype', en: 'Activity Type'),
      type: ObservationFieldType.multiSelect,
      audience: ObservationFieldAudience.all,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 100,
      config: OptionObservationFieldConfig(
        options: <ObservationFieldOption>[
          ObservationFieldOption(
            id: 'organized',
            label: LocalizedText(nl: 'Georganiseerd', en: 'Organized'),
          ),
          ObservationFieldOption(
            id: 'unorganized',
            label: LocalizedText(nl: 'Ongeregeld', en: 'Unorganized'),
          ),
        ],
        allowMultiple: false,
      ),
    ),
    ObservationField(
      id: activityNotesFieldId,
      label: LocalizedText(nl: 'Activiteitsnotities', en: 'Activity Notes'),
      type: ObservationFieldType.text,
      audience: ObservationFieldAudience.all,
      isRequired: true,
      isStandard: true,
      isEnabled: true,
      displayOrder: 110,
      config: TextObservationFieldConfig(
        maxLength: 200,
        placeholder: 'Any extra remarks?',
      ),
    ),
    ObservationField(
      id: remarksFieldId,
      label: LocalizedText(nl: 'Aanvullende opmerkingen', en: 'Additional Remarks'),
      type: ObservationFieldType.text,
      audience: ObservationFieldAudience.all,
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

  /// Derives the legacy audience for a standard field that predates
  /// the explicit audience attribute. Returns null when the field should
  /// remain visible for both audiences so the caller can preserve `all`.
  static ObservationFieldAudience? legacyAudienceForFieldId(String fieldId) {
    if (_individualOnlyFieldIds.contains(fieldId)) {
      return ObservationFieldAudience.individual;
    }
    if (fieldId.startsWith('group.')) {
      return ObservationFieldAudience.group;
    }
    return null;
  }
}
