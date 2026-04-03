import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../hydration/providers/hydration_provider.dart';
import '../../mood/providers/mood_provider.dart';
import '../../mood/models/mood_model.dart';
import '../../../core/theme/app_theme.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días ☀️';
    if (hour < 19) return 'Buenas tardes 🌤️';
    return 'Buenas noches 🌙';
  }

  String _formatDate() {
    final now = DateTime.now();
    const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final glasses = ref.watch(hydrationProvider);
    final mood = ref.watch(moodProvider);

    final completed = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    final highCount = tasks.where((t) => t.priority == TaskPriority.high).length;
    final medCount = tasks.where((t) => t.priority == TaskPriority.medium).length;
    final lowCount = tasks.where((t) => t.priority == TaskPriority.low).length;

    final isPerfectDay = tasks.isNotEmpty && completed == total && glasses == 8;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF9C95FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Cards de resumen en grid 2x2
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              // Tareas
              _SummaryCard(
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.primary,
                title: 'Tareas',
                child: total == 0
                    ? const Text('Sin tareas registradas', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$completed / $total',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: AppTheme.primary.withOpacity(0.15),
                              color: AppTheme.primary,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('completadas', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
              ),

              // Hidratación
              _SummaryCard(
                icon: Icons.water_drop_outlined,
                iconColor: AppTheme.primary,
                title: 'Agua',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$glasses',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        Text('/8', style: TextStyle(fontSize: 16, color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('vasos tomados', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(8, (i) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.water_drop,
                          size: 12,
                          color: i < glasses ? AppTheme.primary : Colors.grey[300],
                        ),
                      )),
                    ),
                  ],
                ),
              ),

              // Mood
              _SummaryCard(
                icon: Icons.mood_outlined,
                iconColor: AppTheme.accent,
                title: 'Mood',
                child: mood == null
                    ? const Text('Sin registrar', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(mood.mood.emoji, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                mood.mood.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: mood.mood.foregroundColor,
                                ),
                              ),
                            ],
                          ),
                          if (mood.note != null && mood.note!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '"${mood.note!}"',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
              ),

              // Mensaje cierre del día
              _SummaryCard(
                icon: isPerfectDay ? Icons.star : Icons.tips_and_updates_outlined,
                iconColor: isPerfectDay ? const Color(0xFFFFA726) : AppTheme.accent,
                title: 'Día',
                child: Text(
                  isPerfectDay
                      ? '¡Día perfecto! 🌟'
                      : '¡Sigue así, cada paso cuenta! 💪',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          // Gráfica de tareas por prioridad
          if (tasks.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Distribución por prioridad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            if (highCount > 0)
                              PieChartSectionData(
                                value: highCount.toDouble(),
                                color: const Color(0xFFEF5350),
                                title: '$highCount',
                                radius: 55,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            if (medCount > 0)
                              PieChartSectionData(
                                value: medCount.toDouble(),
                                color: const Color(0xFFFFA726),
                                title: '$medCount',
                                radius: 55,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            if (lowCount > 0)
                              PieChartSectionData(
                                value: lowCount.toDouble(),
                                color: const Color(0xFF66BB6A),
                                title: '$lowCount',
                                radius: 55,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Legend(color: const Color(0xFFEF5350), label: 'Alta ($highCount)'),
                        _Legend(color: const Color(0xFFFFA726), label: 'Media ($medCount)'),
                        _Legend(color: const Color(0xFF66BB6A), label: 'Baja ($lowCount)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
