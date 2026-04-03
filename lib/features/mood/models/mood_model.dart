import 'package:flutter/material.dart';

enum MoodType { great, good, neutral, bad, awful }

class MoodEntry {
  final MoodType mood;
  final String? note;
  final DateTime registeredAt;

  const MoodEntry({
    required this.mood,
    this.note,
    required this.registeredAt,
  });
}

extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.great: return '😁';
      case MoodType.good: return '😊';
      case MoodType.neutral: return '😐';
      case MoodType.bad: return '😔';
      case MoodType.awful: return '😢';
    }
  }

  String get label {
    switch (this) {
      case MoodType.great: return 'Excelente';
      case MoodType.good: return 'Bien';
      case MoodType.neutral: return 'Regular';
      case MoodType.bad: return 'Mal';
      case MoodType.awful: return 'Muy mal';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case MoodType.great: return const Color(0xFFC8E6C9);
      case MoodType.good: return const Color(0xFFDCEDC8);
      case MoodType.neutral: return const Color(0xFFFFF9C4);
      case MoodType.bad: return const Color(0xFFFFE0B2);
      case MoodType.awful: return const Color(0xFFFFCDD2);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case MoodType.great: return const Color(0xFF2E7D32);
      case MoodType.good: return const Color(0xFF558B2F);
      case MoodType.neutral: return const Color(0xFFF57F17);
      case MoodType.bad: return const Color(0xFFE65100);
      case MoodType.awful: return const Color(0xFFC62828);
    }
  }
}
