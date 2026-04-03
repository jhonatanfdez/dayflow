import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavbar({super.key, required this.child});

  static const _destinations = [
    (icon: Icons.check_circle_outline, activeIcon: Icons.check_circle, label: 'Tareas', route: '/tasks'),
    (icon: Icons.water_drop_outlined, activeIcon: Icons.water_drop, label: 'Agua', route: '/hydration'),
    (icon: Icons.mood_outlined, activeIcon: Icons.mood, label: 'Mood', route: '/mood'),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Resumen', route: '/summary'),
  ];

  static const _titles = {
    '/tasks': 'Mis Tareas',
    '/hydration': 'Hidratación',
    '/mood': 'Estado de Ánimo',
    '/summary': 'Resumen del Día',
  };

  String _formatDate() {
    final now = DateTime.now();
    const weekdays = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} de $month';
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _destinations.indexWhere((d) => location.startsWith(d.route));
    final safeIndex = currentIndex == -1 ? 0 : currentIndex;
    final title = _titles[location] ?? 'DayFlow';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(
              _formatDate(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => context.go(_destinations[index].route),
          items: _destinations
              .map((d) => BottomNavigationBarItem(
                    icon: Icon(d.icon),
                    activeIcon: Icon(d.activeIcon),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
