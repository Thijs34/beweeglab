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
    _buildTable(sheet, records, l10n, project.fields);
    _autoFitColumns(sheet, records.length, headerCount);
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

  void _buildTable(
    xlsio.Worksheet sheet,
    List<ObservationRecord> records,
    AppLocalizations l10n,
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

    for (var index = 0; index < records.length; index++) {
      final rowIndex = _tableHeaderRowIndex + 1 + index;
      final record = records[index];
      final genderValue = localizeObservationOption(
        fields: fields,
        fieldId: ObservationFieldRegistry.genderFieldId,
        rawValue: record.gender,
        locale: dutchLocale,
      );
      final ageGroupValue = localizeObservationOption(
        fields: fields,
        fieldId: ObservationFieldRegistry.ageGroupFieldId,
        rawValue: record.ageGroup,
        locale: dutchLocale,
      );
      final socialContextValue = localizeObservationOption(
        fields: fields,
        fieldId: ObservationFieldRegistry.socialContextFieldId,
        rawValue: record.socialContext,
        locale: dutchLocale,
      );
      final activityLevelValue = localizeObservationOption(
        fields: fields,
        fieldId: ObservationFieldRegistry.activityLevelFieldId,
        rawValue: record.activityLevel,
        locale: dutchLocale,
      );
      final activityTypeValue = localizeObservationOption(
        fields: fields,
        fieldId: ObservationFieldRegistry.activityTypeFieldId,
        rawValue: record.activityType,
        locale: dutchLocale,
      );
      final genderMixValue = record.genderMix ?? '—';
      final ageMixValue = record.ageMix ?? '—';
      final locationLabel = localizeObservationLocation(
        record: record,
        fields: fields,
        locale: dutchLocale,
      );
      final locationTypeLabel = localizeObservationOption(
        fields: fields,
        fieldId: ObservationFieldRegistry.locationTypeFieldId,
        rawValue: record.locationTypeId,
        locale: dutchLocale,
      );
      final modeValue = record.mode == 'group'
          ? dutchStrings.adminRecordGroup
          : dutchStrings.adminRecordIndividual;

      final values = [
        record.personId,
        modeValue,
        record.timestamp,
        record.observerEmail ?? '—',
        record.observerUid ?? '—',
        genderValue,
        ageGroupValue,
        socialContextValue,
        activityLevelValue,
        activityTypeValue,
        locationLabel,
        locationTypeLabel,
        record.groupSize?.toString() ?? '—',
        genderMixValue,
        ageMixValue,
        record.notes.isEmpty ? '—' : record.notes,
      ];

      for (var column = 0; column < values.length; column++) {
        sheet.getRangeByIndex(rowIndex, column + 1).setText(values[column]);
      }
    }
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
        l10n.exportHeaderObserverUid,
        l10n.exportHeaderGender,
        l10n.exportHeaderAgeGroup,
        l10n.exportHeaderSocialContext,
        l10n.exportHeaderActivityLevel,
        l10n.exportHeaderActivityType,
        l10n.exportHeaderLocation,
        l10n.exportHeaderLocationTypeId,
        l10n.exportHeaderGroupSize,
        l10n.exportHeaderGenderMix,
        l10n.exportHeaderAgeMix,
        l10n.exportHeaderNotes,
      ];
}
