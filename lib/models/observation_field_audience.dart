import 'package:my_app/models/observation_field.dart';
import 'package:my_app/models/observation_field_registry.dart';

/// Resolves the effective audience for a field, falling back to legacy
/// heuristics for standard fields that predate the explicit audience column.
ObservationFieldAudience resolveObservationFieldAudience(
  ObservationField field,
) {
  if (!field.isStandard || field.audience != ObservationFieldAudience.all) {
    return field.audience;
  }

  return ObservationFieldRegistry.legacyAudienceForFieldId(field.id) ??
      ObservationFieldAudience.all;
}
