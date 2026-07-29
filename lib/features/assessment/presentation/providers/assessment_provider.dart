import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notegym/core/storage_service.dart';
import 'package:notegym/models/assessment.dart';

class AssessmentState {
  final List<Assessment> assessments;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const AssessmentState({
    this.assessments = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  AssessmentState copyWith({
    List<Assessment>? assessments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return AssessmentState(
      assessments: assessments ?? this.assessments,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AssessmentNotifier extends StateNotifier<AssessmentState> {
  AssessmentNotifier() : super(const AssessmentState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final raw = await StorageService.get<String>('assessments');
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => Assessment.fromJson(e as Map<String, dynamic>))
            .toList();
        state = AssessmentState(assessments: list);
        return;
      } catch (_) {}
    }
    state = const AssessmentState();
  }

  Future<void> submitAssessment({
    required String userId,
    required int sleepQuality,
    required int stressLevel,
    required int muscleSoreness,
    required int energyLevel,
    required int motivation,
    required double averageRir,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final assessment = Assessment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: DateTime.now(),
        sleepQuality: sleepQuality,
        stressLevel: stressLevel,
        muscleSoreness: muscleSoreness,
        energyLevel: energyLevel,
        motivation: motivation,
        averageRir: averageRir,
      );

      final updated = [...state.assessments, assessment];
      final json = jsonEncode(updated.map((a) => a.toJson()).toList());
      await StorageService.set('assessments', json);

      state = AssessmentState(assessments: updated);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  Assessment? get lastAssessment {
    if (state.assessments.isEmpty) return null;
    return state.assessments.reduce(
      (a, b) => a.date.isAfter(b.date) ? a : b,
    );
  }
}

final assessmentProvider = StateNotifierProvider<AssessmentNotifier, AssessmentState>(
  (ref) => AssessmentNotifier(),
);
