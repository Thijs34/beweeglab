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
    final headerCount = _buildTableHeaders(l10n).length;
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
    final headers = _buildTableHeaders(dutchStrings);
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
          ),
        );
      } else {
        rows.add(
          _buildRowForRecord(
            record: record,
            fields: fields,
            locale: locale,
            localizedStrings: localizedStrings,
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
    final locationLabel = localizeObservationLocation(
      record: record,
      fields: fields,
      locale: locale,
    );
    final modeValue = record.mode == 'group'
        ? localizedStrings.adminRecordGroup
        : localizedStrings.adminRecordIndividual;

    return [
      record.personId,
      modeValue,
      record.timestamp,
      record.observerEmail ?? '—',
      genderValue,
      ageGroupValue,
      socialContextValue,
      activityLevelValue,
      activityTypeValue,
      locationLabel,
      record.notes.isEmpty ? '—' : record.notes,
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

  List<String> _buildTableHeaders(AppLocalizations l10n) => [
        l10n.exportHeaderPersonId,
        l10n.exportHeaderMode,
        l10n.exportHeaderTimestamp,
        l10n.exportHeaderObserverEmail,
        l10n.exportHeaderGender,
        l10n.exportHeaderAgeGroup,
        l10n.exportHeaderSocialContext,
        l10n.exportHeaderActivityLevel,
        l10n.exportHeaderActivityType,
        l10n.exportHeaderLocation,
        l10n.exportHeaderNotes,
      ];
}
