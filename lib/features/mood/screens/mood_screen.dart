import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_model.dart';
import '../providers/mood_provider.dart';
import '../../../core/theme/app_theme.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  MoodType? _selectedMood;
  final _noteController = TextEditingController();
  bool _showNoteField = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = ref.watch(moodProvider);
    final notifier = ref.read(moodProvider.notifier);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: currentMood != null
          ? _buildMoodRegistered(context, currentMood, notifier)
          : _buildMoodSelector(context, notifier),
    );
  }

  Widget _buildMoodSelector(BuildContext context, MoodNotifier notifier) {
    return SingleChildScrollView(
      key: const ValueKey('selector'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          const Text(
            '¿Cómo te sientes hoy?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona tu estado de ánimo actual',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Fila de moods
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodType.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedMood = mood;
                  _showNoteField = true;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? mood.backgroundColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: mood.foregroundColor, width: 2)
                        : Border.all(color: Colors.transparent, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 40 : 32)),
                      const SizedBox(height: 6),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? mood.foregroundColor : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Campo de nota
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showNoteField
                ? Padding(
                    key: const ValueKey('note'),
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Añade una nota (opcional)',
                          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: '¿Algo que quieras recordar de este momento?',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_selectedMood != null) {
                                notifier.setMood(_selectedMood!, note: _noteController.text);
                                setState(() {
                                  _selectedMood = null;
                                  _showNoteField = false;
                                  _noteController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Guardar mood',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRegistered(BuildContext context, MoodEntry entry, MoodNotifier notifier) {
    return Center(
      key: const ValueKey('registered'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: entry.mood.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: entry.mood.foregroundColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(entry.mood.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 8),
                  Text(
                    entry.mood.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: entry.mood.foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Registrado a las ${_formatTime(entry.registeredAt)}',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '"${entry.note!}"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: notifier.clearMood,
              icon: const Icon(Icons.refresh),
              label: const Text('Cambiar mood'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
