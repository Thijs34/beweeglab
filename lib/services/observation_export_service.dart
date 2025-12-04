import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

import 'package:my_app/screens/admin_page/admin_models.dart';
import 'package:my_app/services/observation_service.dart';

/// Builds a polished Excel export for project observations and prompts a download.
class ObservationExportService {
  ObservationExportService._();

  static final ObservationExportService instance = ObservationExportService._();
  static const List<String> _tableHeaders = [
    'Person ID',
    'Mode',
    'Timestamp',
    'Observer Email',
    'Observer UID',
    'Gender',
    'Age Group',
    'Social Context',
    'Activity Level',
    'Activity Type',
    'Location',
    'Location Type ID',
    'Group Size',
    'Gender Mix',
    'Age Mix',
    'Notes',
  ];
  static const int _tableHeaderRowIndex = 6;

  final ObservationService _observationService = ObservationService.instance;

  Future<void> exportProjectObservations({
    required AdminProject project,
  }) async {
    final records = await _observationService.fetchAllObservations(
      projectId: project.id,
    );

    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Observations';

    _buildMetadataSection(sheet, project, records.length);
    _buildTable(sheet, records);
    _autoFitColumns(sheet, records.length);
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
  ) {
    const labelStyleColor = '#F4F4F5';
    const valueStyleColor = '#FFFFFF';

    sheet.getRangeByIndex(1, 1).setText('Project');
    sheet.getRangeByIndex(1, 2).setText(project.name);
    sheet.getRangeByIndex(2, 1).setText('Location');
    sheet
        .getRangeByIndex(2, 2)
        .setText(
          project.mainLocation.isEmpty ? 'Not set' : project.mainLocation,
        );
    sheet.getRangeByIndex(3, 1).setText('Exported At');
    sheet.getRangeByIndex(3, 2).setText(_formatDateTime(DateTime.now()));
    sheet.getRangeByIndex(4, 1).setText('Observation Count');
    sheet.getRangeByIndex(4, 2).setNumber(recordCount.toDouble());

    final labelRange = sheet.getRangeByIndex(1, 1, 4, 1);
    labelRange.cellStyle
      ..backColor = labelStyleColor
      ..bold = true;

    final valueRange = sheet.getRangeByIndex(1, 2, 4, 2);
    valueRange.cellStyle.backColor = valueStyleColor;
  }

  void _buildTable(xlsio.Worksheet sheet, List<ObservationRecord> records) {
    for (var column = 0; column < _tableHeaders.length; column++) {
      sheet
          .getRangeByIndex(_tableHeaderRowIndex, column + 1)
          .setText(_tableHeaders[column]);
    }

    final headerRange = sheet.getRangeByIndex(
      _tableHeaderRowIndex,
      1,
      _tableHeaderRowIndex,
      _tableHeaders.length,
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

  void _autoFitColumns(xlsio.Worksheet sheet, int recordCount) {
    final lastRow = _tableHeaderRowIndex + 1 + recordCount;
    sheet.getRangeByIndex(1, 1, lastRow, _tableHeaders.length).autoFitColumns();
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
}
