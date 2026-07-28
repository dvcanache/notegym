import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../routines/routines_provider.dart';
import '../../models/routine.dart';
import 'excel/excel_import_service.dart';
import 'package:notegym/core/theme_extension.dart';

class RoutinesScreen extends ConsumerStatefulWidget {
  const RoutinesScreen({super.key});

  @override
  ConsumerState<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends ConsumerState<RoutinesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ref.watch(defaultRoutinesProvider);
    final custom = ref.watch(customRoutinesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration:
                BoxDecoration(gradient: context.colors.backgroundGradient),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rutinas',
                          style: Theme.of(context).textTheme.displayMedium),
                      Row(
                        children: [
                          GlassCard(
                            onTap: () => _importExcel(context),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            borderRadius: 12,
                            child: Row(
                              children: [
                                Icon(Icons.upload_file_outlined,
                                    color: context.colors.accent, size: 16),
                                const SizedBox(width: 6),
                                Text('Importar',
                                    style: TextStyle(
                                        color: context.colors.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlassCard(
                            onTap: () => context.go('/routines/create'),
                            padding: const EdgeInsets.all(10),
                            borderRadius: 12,
                            child: Icon(Icons.add_rounded,
                                color: context.colors.primaryLight, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                ),

                const SizedBox(height: 16),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: context.colors.textMuted, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            style: TextStyle(
                                color: context.colors.textPrimary,
                                fontSize: 14),
                            onChanged: (v) => setState(() => _search = v),
                            decoration: const InputDecoration(
                              hintText: 'Buscar rutina...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_search.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                            child: Icon(Icons.close_rounded,
                                color: context.colors.textMuted, size: 18),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassCard(
                    padding: const EdgeInsets.all(4),
                    borderRadius: 14,
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: context.colors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: context.colors.textMuted,
                      labelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w400),
                      tabs: [
                        Tab(text: 'Predeterminadas (${defaults.length})'),
                        Tab(text: 'Mis Rutinas (${custom.length})'),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _RoutineList(
                        routines: _filtered(defaults),
                        emptyMessage: 'No hay rutinas predeterminadas',
                      ),
                      _RoutineList(
                        routines: _filtered(custom),
                        emptyMessage:
                            'No has creado rutinas todavía.\nToca + para crear una.',
                        onDelete: (id) => ref
                            .read(routinesProvider.notifier)
                            .deleteRoutine(id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Routine> _filtered(List<Routine> list) {
    if (_search.isEmpty) return list;
    return list
        .where((r) =>
            r.name.toLowerCase().contains(_search.toLowerCase()) ||
            r.description.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  Future<void> _importExcel(BuildContext context) async {
    final routine = await ExcelImportService.importRoutine(context);
    if (routine != null && mounted) {
      await ref.read(routinesProvider.notifier).importRoutine(routine);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Rutina "${routine.name}" importada con éxito!'),
          backgroundColor: context.colors.success,
        ),
      );
    }
  }
}

class _RoutineList extends StatelessWidget {
  final List<Routine> routines;
  final String emptyMessage;
  final void Function(String id)? onDelete;

  const _RoutineList({
    required this.routines,
    required this.emptyMessage,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (routines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center_outlined,
                color: context.colors.textMuted, size: 52),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: context.colors.textMuted, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: routines.length,
      itemBuilder: (ctx, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _RoutineCard(
          routine: routines[i],
          onDelete: onDelete,
        ).animate().fadeIn(delay: (i * 80).ms).slideY(begin: 0.15),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final void Function(String id)? onDelete;

  const _RoutineCard({required this.routine, this.onDelete});

  Color _typeColor(BuildContext context, String type) {
    switch (type) {
      case 'hiit':
        return context.colors.accent;
      case 'cardio':
        return context.colors.success;
      case 'yoga':
        return const Color(0xFF06B6D4);
      case 'flexibility':
        return const Color(0xFF84CC16);
      default:
        return context.colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(context, routine.type);
    return GlassCard(
      onTap: () => context.go('/routines/detail/${routine.id}'),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(routine.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  routine.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TagChip(text: routine.difficulty, color: color),
                    const SizedBox(width: 6),
                    _TagChip(
                        text: '${routine.estimatedMinutes}min',
                        color: context.colors.textMuted),
                    const SizedBox(width: 6),
                    _TagChip(
                        text: '${routine.exercises.length} ejerc.',
                        color: context.colors.textMuted),
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null)
            PopupMenuButton<String>(
              color: context.colors.surface,
              icon: Icon(Icons.more_vert_rounded,
                  color: context.colors.textMuted, size: 20),
              onSelected: (val) {
                if (val == 'delete') onDelete!(routine.id);
                if (val == 'edit')
                  context.go('/routines/create', extra: {'id': routine.id});
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar',
                        style: TextStyle(color: context.colors.textPrimary))),
                PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar',
                        style: TextStyle(color: context.colors.error))),
              ],
            ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final Color color;
  const _TagChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
