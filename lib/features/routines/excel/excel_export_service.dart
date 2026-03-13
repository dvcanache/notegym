import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../models/routine.dart';
import 'package:notegym/core/theme_extension.dart';

class ExcelExportService {
  static Future<void> exportRoutine(BuildContext context, Routine routine) async {
    try {
      final excel = Excel.createExcel();

      // Sheet 1: Routine Info
      final infoSheet = excel['Información'];
      _addCell(infoSheet, 0, 0, 'NoteGym - Exportación de Rutina', bold: true, size: 14);
      _addCell(infoSheet, 1, 0, '');
      _addCell(infoSheet, 2, 0, 'Nombre:', bold: true);
      _addCell(infoSheet, 2, 1, routine.name);
      _addCell(infoSheet, 3, 0, 'Descripción:', bold: true);
      _addCell(infoSheet, 3, 1, routine.description);
      _addCell(infoSheet, 4, 0, 'Tipo:', bold: true);
      _addCell(infoSheet, 4, 1, _typeLabel(routine.type));
      _addCell(infoSheet, 5, 0, 'Dificultad:', bold: true);
      _addCell(infoSheet, 5, 1, routine.difficulty);
      _addCell(infoSheet, 6, 0, 'Duración estimada:', bold: true);
      _addCell(infoSheet, 6, 1, '${routine.estimatedMinutes} minutos');
      _addCell(infoSheet, 7, 0, 'Ejercicios:', bold: true);
      _addCell(infoSheet, 7, 1, '${routine.exercises.length}');
      _addCell(infoSheet, 8, 0, 'Exportado:', bold: true);
      _addCell(infoSheet, 8, 1,
          DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()));

      // Sheet 2: Exercises
      final exSheet = excel['Ejercicios'];
      // Headers
      final headers = [
        'Ejercicio', 'Músculo', 'Series', 'Reps', 'Peso (kg)', 'Descanso (seg)', 'Equipo', 'Descripción'
      ];
      for (int j = 0; j < headers.length; j++) {
        _addCell(exSheet, 0, j, headers[j], bold: true);
      }

      // Data rows
      for (int i = 0; i < routine.exercises.length; i++) {
        final ex = routine.exercises[i];
        final row = i + 1;
        _addCell(exSheet, row, 0, ex.name);
        _addCell(exSheet, row, 1, ex.muscleGroup);
        _addCell(exSheet, row, 2, ex.defaultSets.toString());
        _addCell(exSheet, row, 3, ex.defaultReps.toString());
        _addCell(exSheet, row, 4, ex.defaultWeight.toString());
        _addCell(exSheet, row, 5, ex.restSeconds.toString());
        _addCell(exSheet, row, 6, ex.equipment ?? '');
        _addCell(exSheet, row, 7, ex.description);
      }

      // Remove default sheet
      excel.delete('Sheet1');

      // Save file
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Error al generar el archivo');

      final dir = await getApplicationDocumentsDirectory();
      final safeName = routine.name.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
      final path = '${dir.path}/NoteGym_${safeName}.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      // Share
      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Rutina: ${routine.name} - NoteGym',
        text: 'Rutina "${routine.name}" exportada desde NoteGym',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Rutina exportada con éxito!'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  /// Returns a downloadable template xlsx
  static Future<void> downloadTemplate(BuildContext context) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Ejercicios'];

      final headers = [
        'Ejercicio', 'Músculo', 'Series', 'Reps', 'Peso (kg)', 'Descanso (seg)'
      ];
      for (int j = 0; j < headers.length; j++) {
        _addCell(sheet, 0, j, headers[j], bold: true);
      }

      // Example rows
      final examples = [
        ['Press de Banca', 'Pecho', '4', '8', '60', '90'],
        ['Sentadilla', 'Piernas', '4', '8', '70', '90'],
        ['Dominadas', 'Espalda', '3', '10', '0', '75'],
      ];
      for (int i = 0; i < examples.length; i++) {
        for (int j = 0; j < examples[i].length; j++) {
          _addCell(sheet, i + 1, j, examples[i][j]);
        }
      }

      excel.delete('Sheet1');

      final bytes = excel.encode();
      if (bytes == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/NoteGym_Plantilla.xlsx';
      await File(path).writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Plantilla de Rutina - NoteGym',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: context.colors.error),
        );
      }
    }
  }

  static void _addCell(Sheet sheet, int row, int col, String text,
      {bool bold = false, double? size}) {
    final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    if (bold || size != null) {
      cell.cellStyle = CellStyle(
        bold: bold,
        fontSize: size?.toInt(),
      );
    }
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'strength': return 'Fuerza';
      case 'cardio': return 'Cardio';
      case 'hiit': return 'HIIT';
      case 'yoga': return 'Yoga';
      case 'flexibility': return 'Flexibilidad';
      default: return type;
    }
  }
}
