import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/widgets.dart';
import 'package:my_app/l10n/gen/app_localizations.dart';
import 'package:my_app/models/observation_field.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import 'package:my_app/models/observation_field_registry.dart';
import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/services/observation_service.dart';

/// Builds a polished Excel export for project observations and prompts a download.
class ObservationExportService {
  ObservationExportService._();

  static final ObservationExportService instance = ObservationExportService._();
  static const int _tableHeaderRowIndex = 6;

  final ObservationService _observationService = ObservationService.instance;

  Future<void> exportProjectObservations({
    required AdminProject project,
    required AppLocalizations l10n,
  }) async {
    final records = await _observationService.fetchAllObservations(
      projectId: project.id,
    );

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = l10n.exportSheetName;

    _buildMetadataSection(sheet, project, records.length, l10n);
    final headerCount = _buildTableHeaders(
      l10n,
      project.fields,
      const Locale('nl'),
      const [],
    ).length;
    final dataRowCount = _buildTable(sheet, records, project.fields);
    _autoFitColumns(sheet, dataRowCount, headerCount);
    _freezeHeaderRows(sheet);

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final sanitizedProject = _sanitizeFileName(project.name);
    final timestamp = _formatDateTime(DateTime.now()).replaceAll(':', '-');
    final fileName = '${sanitizedProject}_observations_$timestamp';

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes),
      fileExtension: 'xlsx',
      mimeType: MimeType.microsoftExcel,
    );
  }

  void _buildMetadataSection(
    xlsio.Worksheet sheet,
    AdminProject project,
    int recordCount,
    AppLocalizations l10n,
  ) {
    const labelStyleColor = '#F4F4F5';
    const valueStyleColor = '#FFFFFF';

    sheet.getRangeByIndex(1, 1).setText(l10n.exportProjectLabel);
    sheet.getRangeByIndex(1, 2).setText(project.name);
    sheet.getRangeByIndex(2, 1).setText(l10n.exportLocationLabel);
    sheet
        .getRangeByIndex(2, 2)
        .setText(
          project.mainLocation.isEmpty
              ? l10n.exportLocationNotSet
              : project.mainLocation,
        );
    sheet.getRangeByIndex(3, 1).setText(l10n.exportExportedAt);
    sheet.getRangeByIndex(3, 2).setText(_formatDateTime(DateTime.now()));
    sheet.getRangeByIndex(4, 1).setText(l10n.exportObservationCount);
    sheet.getRangeByIndex(4, 2).setNumber(recordCount.toDouble());

    final labelRange = sheet.getRangeByIndex(1, 1, 4, 1);
    labelRange.cellStyle
      ..backColor = labelStyleColor
      ..bold = true;

    final valueRange = sheet.getRangeByIndex(1, 2, 4, 2);
    valueRange.cellStyle.backColor = valueStyleColor;
  }

  int _buildTable(
    xlsio.Worksheet sheet,
    List<ObservationRecord> records,
    List<ObservationField> fields,
  ) {
    final dutchLocale = const Locale('nl');
    final dutchStrings = lookupAppLocalizations(dutchLocale);
    final customFields = _customExportFields(fields);
    final headers = _buildTableHeaders(
      dutchStrings,
      fields,
      dutchLocale,
      customFields,
    );
    for (var column = 0; column < headers.length; column++) {
      sheet
          .getRangeByIndex(_tableHeaderRowIndex, column + 1)
          .setText(headers[column]);
    }

    final headerRange = sheet.getRangeByIndex(
      _tableHeaderRowIndex,
      1,
      _tableHeaderRowIndex,
      headers.length,
    );
    headerRange.cellStyle
      ..backColor = '#0F172A'
      ..fontColor = '#FFFFFF'
      ..bold = true
      ..hAlign = xlsio.HAlignType.center;

    final rows = _flattenRecords(
      records: records,
      fields: fields,
      locale: dutchLocale,
      localizedStrings: dutchStrings,
      customFields: customFields,
    );

    for (var index = 0; index < rows.length; index++) {
      final rowIndex = _tableHeaderRowIndex + 1 + index;
      final values = rows[index];
      for (var column = 0; column < values.length; column++) {
        sheet.getRangeByIndex(rowIndex, column + 1).setText(values[column]);
      }
    }

    return rows.length;
  }

  List<List<String>> _flattenRecords({
    required List<ObservationRecord> records,
    required List<ObservationField> fields,
    required Locale locale,
    required AppLocalizations localizedStrings,
    required List<ObservationField> customFields,
  }) {
    final rows = <List<String>>[];
    for (final record in records) {
      if (record.isGroup) {
        rows.addAll(
          _expandGroupRecordRows(
            record: record,
            fields: fields,
            locale: locale,
            localizedStrings: localizedStrings,
            customFields: customFields,
          ),
        );
      } else {
        rows.add(
          _buildRowForRecord(
            record: record,
            fields: fields,
            locale: locale,
            localizedStrings: localizedStrings,
            customFields: customFields,
          ),
        );
      }
    }
    return rows;
  }

  List<List<String>> _expandGroupRecordRows({
    required ObservationRecord record,
    required List<ObservationField> fields,
    required Locale locale,
    required AppLocalizations localizedStrings,
    required List<ObservationField> customFields,
  }) {
    final genderIds = _expandDemographicCounts(
      counts: record.genderCounts,
      fields: fields,
      fieldId: ObservationFieldRegistry.genderFieldId,
    );
    final ageIds = _expandDemographicCounts(
      counts: record.ageCounts,
      fields: fields,
      fieldId: ObservationFieldRegistry.ageGroupFieldId,
    );
    final hasGenderData = genderIds.isNotEmpty;
    final hasAgeData = ageIds.isNotEmpty;
    final groupSize = record.groupSize ?? 0;
    final inferredCount = math.max(genderIds.length, ageIds.length);
    final targetCount = math.max(groupSize, inferredCount).toInt();
    final rowTotal = targetCount > 0 ? targetCount : 1;

    final rows = <List<String>>[];
    for (var index = 0; index < rowTotal; index++) {
      final genderOverrideId = hasGenderData
          ? (index < genderIds.length ? genderIds[index] : '—')
          : null;
      final ageOverrideId = hasAgeData
          ? (index < ageIds.length ? ageIds[index] : '—')
          : null;
      rows.add(
        _buildRowForRecord(
          record: record,
          fields: fields,
          locale: locale,
          localizedStrings: localizedStrings,
          customFields: customFields,
          genderOverrideId: genderOverrideId,
          ageOverrideId: ageOverrideId,
        ),
      );
    }

    return rows;
  }

  List<String> _buildRowForRecord({
    required ObservationRecord record,
    required List<ObservationField> fields,
    required Locale locale,
    required AppLocalizations localizedStrings,
    required List<ObservationField> customFields,
    String? genderOverrideId,
    String? ageOverrideId,
  }) {
    final genderValue = localizeObservationOption(
      fields: fields,
      fieldId: ObservationFieldRegistry.genderFieldId,
      rawValue: genderOverrideId ?? record.gender,
      locale: locale,
    );
    final ageGroupValue = localizeObservationOption(
      fields: fields,
      fieldId: ObservationFieldRegistry.ageGroupFieldId,
      rawValue: ageOverrideId ?? record.ageGroup,
      locale: locale,
    );
    final socialContextValue = localizeObservationOption(
      fields: fields,
      fieldId: ObservationFieldRegistry.socialContextFieldId,
      rawValue: record.socialContext,
      locale: locale,
    );
    final activityLevelValue = localizeObservationOption(
      fields: fields,
      fieldId: ObservationFieldRegistry.activityLevelFieldId,
      rawValue: record.activityLevel,
      locale: locale,
    );
    final activityTypeValue = localizeObservationOption(
      fields: fields,
      fieldId: ObservationFieldRegistry.activityTypeFieldId,
      rawValue: record.activityType,
      locale: locale,
    );
    final weatherValue = _localizeWeather(
      localizedStrings,
      record.weatherCondition,
    );
    final locationLabel = localizeObservationLocation(
      record: record,
      fields: fields,
      locale: locale,
    );
    final modeValue = record.mode == 'group'
        ? localizedStrings.adminRecordGroup
        : localizedStrings.adminRecordIndividual;
    String textValue(String fieldId) {
      final raw = record.fieldValues?[fieldId];
      if (raw is String) return raw.trim();
      if (raw != null) return raw.toString().trim();
      return '';
    }
    final activityNotes = textValue(ObservationFieldRegistry.activityNotesFieldId);
    final additionalRemarks = textValue(ObservationFieldRegistry.remarksFieldId);
    final base = [
      record.personId,
      modeValue,
      record.timestamp,
      weatherValue,
      record.temperatureLabel.isEmpty ? '—' : record.temperatureLabel,
      record.observerEmail ?? '—',
      genderValue,
      ageGroupValue,
      socialContextValue,
      activityLevelValue,
      activityTypeValue,
      locationLabel,
      activityNotes.isEmpty ? '—' : activityNotes,
      additionalRemarks.isEmpty ? '—' : additionalRemarks,
    ];

    if (customFields.isEmpty) {
      return base;
    }

    final customValues = customFields.map((field) {
      final raw = record.fieldValues?[field.id];
      final formatted = _formatFieldValue(field, locale, raw);
      return (formatted == null || formatted.isEmpty) ? '—' : formatted;
    });

    return [
      ...base,
      ...customValues,
    ];
  }

  List<String> _expandDemographicCounts({
    required Map<String, int>? counts,
    required List<ObservationField> fields,
    required String fieldId,
  }) {
    if (counts == null || counts.isEmpty) {
      return const [];
    }
    final optionOrder = _fieldOptionOrder(fields, fieldId);
    final handled = <String>{};
    final expanded = <String>[];
    if (optionOrder != null) {
      for (final optionId in optionOrder) {
        final value = counts[optionId];
        if (value != null && value > 0) {
          expanded.addAll(List<String>.filled(value, optionId));
          handled.add(optionId);
        }
      }
    }
    counts.forEach((key, value) {
      if (value > 0 && !handled.contains(key)) {
        expanded.addAll(List<String>.filled(value, key));
      }
    });
    return expanded;
  }

  List<String>? _fieldOptionOrder(
    List<ObservationField> fields,
    String fieldId,
  ) {
    final field = _getFieldById(fields, fieldId);
    if (field?.config is OptionObservationFieldConfig) {
      final config = field!.config as OptionObservationFieldConfig;
      return config.options.map((option) => option.id).toList(growable: false);
    }
    return null;
  }

  ObservationField? _getFieldById(
    List<ObservationField> fields,
    String fieldId,
  ) {
    for (final field in fields) {
      if (field.id == fieldId) {
        return field;
      }
    }
    return null;
  }

  String _fieldLabel(
    List<ObservationField> fields,
    String fieldId,
    Locale locale,
  ) {
    final field = _getFieldById(fields, fieldId);
    if (field != null) {
      return field.labelForLocale(locale.languageCode);
    }
    return fieldId;
  }

  String? _formatFieldValue(
    ObservationField field,
    Locale locale,
    dynamic raw,
  ) {
    if (raw == null) return null;

    String resolveOption(String value) {
      final config = field.config;
      if (config is OptionObservationFieldConfig) {
        final match = config.options.firstWhere(
          (opt) => opt.id == value,
          orElse: () => const ObservationFieldOption(
            id: '',
            label: LocalizedText(nl: ''),
          ),
        );
        if (match.id.isNotEmpty) {
          final label = match.labelForLocale(locale.languageCode);
          if (label.trim().isNotEmpty) return label.trim();
        }
      }
      const otherPrefix = 'other:';
      if (value.startsWith(otherPrefix)) {
        return value.substring(otherPrefix.length).trim();
      }
      return value.trim();
    }

    if (raw is String) {
      final resolved = resolveOption(raw);
      return resolved.isEmpty ? null : resolved;
    }

    if (raw is num) return raw.toString();
    if (raw is bool) return raw ? 'Yes' : 'No';

    if (raw is Iterable) {
      final entries = raw
          .whereType<String>()
          .map(resolveOption)
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      if (entries.isEmpty) return null;
      return entries.join(', ');
    }

    if (raw is Map) {
      // Skip demographic matrix payloads; they are captured via counts.
      if (raw.containsKey('genderCounts') || raw.containsKey('ageCounts')) {
        return null;
      }
      final parts = <String>[];
      raw.forEach((key, value) {
        if (value == null) return;
        final rendered = value is String
            ? resolveOption(value)
            : value is num
                ? value.toString()
                : value.toString();
        if (rendered.trim().isNotEmpty) {
          parts.add('$key: ${rendered.trim()}');
        }
      });
      if (parts.isEmpty) return null;
      return parts.join(', ');
    }

    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  void _autoFitColumns(
    xlsio.Worksheet sheet,
    int recordCount,
    int headerCount,
  ) {
    final lastRow = _tableHeaderRowIndex + 1 + recordCount;
    sheet.getRangeByIndex(1, 1, lastRow, headerCount).autoFitColumns();
  }

  void _freezeHeaderRows(xlsio.Worksheet sheet) {
    sheet.getRangeByIndex(_tableHeaderRowIndex + 1, 1).freezePanes();
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  String _sanitizeFileName(String input) {
    final sanitized = input.replaceAll(RegExp(r'[^a-zA-Z0-9-_ ]'), '').trim();
    return sanitized.isEmpty ? 'project' : sanitized.replaceAll(' ', '_');
  }

  String _localizeWeather(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'sunny':
        return l10n.weatherSunny;
      case 'cloudy':
        return l10n.weatherCloudy;
      case 'rainy':
        return l10n.weatherRainy;
      default:
        return raw.isEmpty ? '—' : raw;
    }
  }

  List<String> _buildTableHeaders(
    AppLocalizations l10n,
    List<ObservationField> fields,
    Locale locale,
    List<ObservationField> customFields,
  ) {
    final headers = <String>[
      l10n.exportHeaderPersonId,
      l10n.exportHeaderMode,
      l10n.exportHeaderTimestamp,
      l10n.observerSummaryWeather,
      'Temperature (°C)',
      l10n.exportHeaderObserverEmail,
      l10n.exportHeaderGender,
      l10n.exportHeaderAgeGroup,
      l10n.exportHeaderSocialContext,
      l10n.exportHeaderActivityLevel,
      l10n.exportHeaderActivityType,
      l10n.exportHeaderLocation,
      _fieldLabel(fields, ObservationFieldRegistry.activityNotesFieldId, locale),
      _fieldLabel(fields, ObservationFieldRegistry.remarksFieldId, locale),
    ];

    for (final field in customFields) {
      headers.add(field.labelForLocale(locale.languageCode));
    }
    return headers;
  }

  List<ObservationField> _customExportFields(
    List<ObservationField> fields,
  ) {
    const excludedFieldIds = <String>{
      ObservationFieldRegistry.genderFieldId,
      ObservationFieldRegistry.ageGroupFieldId,
      ObservationFieldRegistry.socialContextFieldId,
      ObservationFieldRegistry.locationTypeFieldId,
      ObservationFieldRegistry.customLocationFieldId,
      ObservationFieldRegistry.activityLevelFieldId,
      ObservationFieldRegistry.activityTypeFieldId,
      ObservationFieldRegistry.activityNotesFieldId,
      ObservationFieldRegistry.remarksFieldId,
      ObservationFieldRegistry.groupSizeFieldId,
      ObservationFieldRegistry.groupGenderMixFieldId,
      ObservationFieldRegistry.groupAgeMixFieldId,
    };

    return fields
        .where((field) => field.isEnabled && !excludedFieldIds.contains(field.id))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }
}
