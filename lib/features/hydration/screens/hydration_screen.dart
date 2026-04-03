import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hydration_provider.dart';
import '../../../core/theme/app_theme.dart';

class HydrationScreen extends ConsumerWidget {
  const HydrationScreen({super.key});

  Color _ringColor(int glasses) {
    if (glasses <= 2) return const Color(0xFFEF5350);
    if (glasses <= 5) return const Color(0xFFFFA726);
    return AppTheme.primary;
  }

  String _motivationalMessage(int glasses) {
    if (glasses == 8) return '¡Meta alcanzada! 🎉';
    if (glasses >= 6) return '¡Casi llegas a la meta! 🔥';
    if (glasses >= 3) return '¡Vas bien, sigue así! 🙌';
    return '¡Empieza a hidratarte! 💧';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glasses = ref.watch(hydrationProvider);
    final notifier = ref.read(hydrationProvider.notifier);
    final color = _ringColor(glasses);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress ring central
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: glasses / 8),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(200, 200),
                      painter: _RingPainter(progress: value, color: color),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$glasses',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          'de 8 vasos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Mensaje motivacional
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _motivationalMessage(glasses),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Botones + y -
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleButton(
                onPressed: glasses > 0 ? notifier.removeGlass : null,
                icon: Icons.remove,
                color: const Color(0xFFEF5350),
              ),
              const SizedBox(width: 32),
              _CircleButton(
                onPressed: glasses < 8 ? notifier.addGlass : null,
                icon: Icons.add,
                color: AppTheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Grid de gotitas
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final filled = index < glasses;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(filled),
                  decoration: BoxDecoration(
                    color: filled ? AppTheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: filled ? AppTheme.primary : Colors.grey[300],
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Botón reiniciar
          TextButton.icon(
            onPressed: glasses > 0 ? notifier.reset : null,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reiniciar'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  const _CircleButton({required this.onPressed, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed != null ? color : Colors.grey[300],
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    // Track (fondo)
    final trackPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
