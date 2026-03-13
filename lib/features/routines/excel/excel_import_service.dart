import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme.dart';
import '../../../models/exercise.dart';
import '../../../models/routine.dart';
import 'package:notegym/core/theme_extension.dart';

class ExcelImportService {
  static final _uuid = const Uuid();

  /// Shows file picker and imports a routine from .xlsx
  static Future<Routine?> importRoutine(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final bytes = result.files.first.bytes;
      if (bytes == null) return null;

      final excel = Excel.decodeBytes(bytes);

      // Try to find the exercises sheet
      Sheet? sheet;
      for (final name in excel.tables.keys) {
        if (name.toLowerCase().contains('ejercicio') ||
            name.toLowerCase().contains('ejerc') ||
            name.toLowerCase().contains('rutina') ||
            name.toLowerCase().contains('sheet')) {
          sheet = excel.tables[name];
          break;
        }
      }
      sheet ??= excel.tables[excel.tables.keys.first];

      if (sheet == null || sheet.rows.isEmpty) {
        if (context.mounted) {
          _showError(context, 'El archivo no contiene datos válidos');
        }
        return null;
      }

      // Get routine name from first row or filename
      String routineName = result.files.first.name
          .replaceAll('.xlsx', '')
          .replaceAll('_', ' ');

      // Parse exercises (skip header row)
      final exercises = <Exercise>[];
      final rows = sheet.rows;

      // Detect header row
      int startRow = 0;
      for (int i = 0; i < rows.length && i < 3; i++) {
        final row = rows[i];
        if (row.isNotEmpty) {
          final cell = row[0]?.value?.toString().toLowerCase() ?? '';
          if (cell.contains('ejerc') || cell.contains('nombre') || cell.contains('exercise')) {
            startRow = i + 1;
            break;
          }
        }
      }

      for (int i = startRow; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row[0] == null) continue;

        final name = row[0]?.value?.toString().trim() ?? '';
        if (name.isEmpty) continue;

        final muscle = row.length > 1 ? row[1]?.value?.toString().trim() ?? 'Full Body' : 'Full Body';
        final sets = int.tryParse(row.length > 2 ? row[2]?.value?.toString() ?? '3' : '3') ?? 3;
        final reps = int.tryParse(row.length > 3 ? row[3]?.value?.toString() ?? '10' : '10') ?? 10;
        final weight = double.tryParse(row.length > 4 ? row[4]?.value?.toString() ?? '0' : '0') ?? 0;
        final rest = int.tryParse(row.length > 5 ? row[5]?.value?.toString() ?? '60' : '60') ?? 60;

        exercises.add(Exercise(
          id: _uuid.v4(),
          name: name,
          muscleGroup: muscle,
          defaultSets: sets,
          defaultReps: reps,
          defaultWeight: weight,
          restSeconds: rest,
        ));
      }

      if (exercises.isEmpty) {
        if (context.mounted) {
          _showError(context, 'No se encontraron ejercicios válidos');
        }
        return null;
      }

      // Show preview dialog
      if (context.mounted) {
        final confirmed = await _showPreviewDialog(context, routineName, exercises);
        if (!confirmed) return null;
      }

      return Routine(
        id: _uuid.v4(),
        name: routineName,
        description: 'Importada desde archivo .xlsx',
        type: 'strength',
        emoji: '📋',
        exercises: exercises,
        isDefault: false,
      );
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error al leer el archivo: $e');
      }
      return null;
    }
  }

  static Future<bool> _showPreviewDialog(
    BuildContext context,
    String name,
    List<Exercise> exercises,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: context.colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vista previa de importación',
                      style: Theme.of(ctx).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Rutina: $name',
                      style: TextStyle(color: context.colors.textSecondary)),
                  Text('${exercises.length} ejercicios encontrados',
                      style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (_, i) {
                        final ex = exercises[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Text('${i + 1}. ', style: TextStyle(color: context.colors.textMuted)),
                              Expanded(
                                child: Text(
                                  '${ex.name} • ${ex.defaultSets}×${ex.defaultReps}',
                                  style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancelar', style: TextStyle(color: context.colors.textMuted)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary),
                          child: const Text('Importar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  static void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: context.colors.error),
    );
  }
}
