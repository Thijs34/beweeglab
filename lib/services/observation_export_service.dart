import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:my_app/l10n/gen/app_localizations.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

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
    _buildTable(sheet, records, l10n);
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
  ) {
    final headers = _buildTableHeaders(l10n);
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
      final values = [
        record.personId,
        record.mode,
        record.timestamp,
        record.observerEmail ?? '—',
        record.observerUid ?? '—',
        record.gender,
        record.ageGroup,
        record.socialContext,
        record.activityLevel,
        record.activityType,
        _resolveLocationLabel(record),
        record.locationTypeId,
        record.groupSize?.toString() ?? '—',
        record.genderMix ?? '—',
        record.ageMix ?? '—',
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

  String _resolveLocationLabel(ObservationRecord record) {
    if (record.locationLabel != null && record.locationLabel!.isNotEmpty) {
      return record.locationLabel!;
    }
    if (record.locationTypeId.startsWith('custom:')) {
      return record.locationTypeId.replaceFirst('custom:', '').trim();
    }
    return record.locationTypeId;
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
