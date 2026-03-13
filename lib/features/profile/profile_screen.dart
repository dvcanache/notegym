import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../auth/auth_provider.dart';
import '../workout/workout_logs_provider.dart';
import '../../models/user_profile.dart';
import '../routines/excel/excel_export_service.dart';
import 'package:notegym/core/theme_extension.dart';
import '../../core/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;
  String? _selectedGoal;

  final _goals = [
    'Pérdida de peso',
    'Ganar músculo',
    'Mantenimiento',
    'Mejorar resistencia',
    'Aumentar fuerza',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _weightCtrl = TextEditingController(text: profile?.weightKg?.toString() ?? '');
    _heightCtrl = TextEditingController(text: profile?.heightCm?.toString() ?? '');
    _selectedGoal = profile?.goal;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final profile = ref.read(authProvider).profile;
    if (profile == null) return;

    final updated = UserProfile(
      id: profile.id,
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : profile.name,
      email: profile.email,
      photoUrl: profile.photoUrl,
      goal: _selectedGoal ?? profile.goal,
      totalWorkouts: profile.totalWorkouts,
      currentStreak: profile.currentStreak,
      bestStreak: profile.bestStreak,
      joinDate: profile.joinDate,
      lastWorkoutDate: profile.lastWorkoutDate,
      weightKg: double.tryParse(_weightCtrl.text) ?? profile.weightKg,
      heightCm: double.tryParse(_heightCtrl.text) ?? profile.heightCm,
    );

    await ref.read(authProvider.notifier).updateProfile(updated);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider).profile;
    final logs = ref.watch(workoutLogsProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (profile == null) return const SizedBox();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: context.colors.backgroundGradient)),
          // Purple glow
          Positioned(
            top: -80, right: -80,
            child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.primary.withOpacity(0.12))),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Perfil', style: Theme.of(context).textTheme.displayMedium),
                      if (!_isEditing)
                        GlassCard(
                          onTap: () => setState(() => _isEditing = true),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          borderRadius: 12,
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 14, color: context.colors.primaryLight),
                              SizedBox(width: 6),
                              Text('Editar', style: TextStyle(color: context.colors.primaryLight, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // Avatar & name
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: context.colors.purpleOrangeGradient,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: context.colors.primary.withOpacity(0.3), blurRadius: 16)],
                          ),
                          child: Center(
                            child: Text(
                              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'A',
                              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name, style: Theme.of(context).textTheme.headlineLarge),
                              const SizedBox(height: 2),
                              Text(profile.email, style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: context.colors.accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '🔥 ${profile.currentStreak} días de racha',
                                  style: TextStyle(color: context.colors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 14),

                  // Stats
                  Row(
                    children: [
                      Expanded(child: _StatCard2(value: '${profile.totalWorkouts}', label: 'Entrenamientos', icon: Icons.fitness_center_rounded, color: context.colors.primary)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard2(value: '${profile.bestStreak}d', label: 'Mejor racha', icon: Icons.emoji_events_rounded, color: context.colors.accent)),
                      const SizedBox(width: 10),
                      Expanded(child: _StatCard2(
                        value: logs.isEmpty ? '0kg' : '${logs.fold<double>(0, (s, l) => s + l.totalVolume).toStringAsFixed(0)}',
                        label: 'Vol. total (kg)',
                        icon: Icons.monitor_weight_outlined,
                        color: context.colors.success,
                      )),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 14),

                  // Edit form
                  if (_isEditing) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Editar Perfil', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _nameCtrl,
                            style: TextStyle(color: context.colors.textPrimary),
                            decoration: const InputDecoration(labelText: 'Nombre'),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _weightCtrl,
                                  style: TextStyle(color: context.colors.textPrimary),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _heightCtrl,
                                  style: TextStyle(color: context.colors.textPrimary),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Altura (cm)'),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text('Objetivo principal', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _goals.map((g) => GestureDetector(
                              onTap: () => setState(() => _selectedGoal = g),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedGoal == g ? context.colors.primary.withOpacity(0.3) : context.colors.glassWhite,
                                  borderRadius: BorderRadius.circular(10),
                                  border: _selectedGoal == g ? Border.all(color: context.colors.primary) : null,
                                ),
                                child: Text(g, style: TextStyle(color: _selectedGoal == g ? context.colors.primaryLight : context.colors.textMuted, fontSize: 12)),
                              ),
                            )).toList(),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedGlassButton(
                                  label: 'Cancelar',
                                  onPressed: () => setState(() => _isEditing = false),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GradientButton(
                                  label: 'Guardar',
                                  icon: Icons.check_rounded,
                                  onPressed: _saveProfile,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 14),
                  ]
                  else if (profile.goal != null) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.track_changes_rounded, color: context.colors.primaryLight, size: 20),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Objetivo', style: TextStyle(color: context.colors.textMuted, fontSize: 11)),
                              Text(profile.goal!, style: Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                          if (profile.weightKg != null || profile.heightCm != null) ...[
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (profile.weightKg != null)
                                  Text('${profile.weightKg?.toStringAsFixed(0)} kg', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                                if (profile.heightCm != null)
                                  Text('${profile.heightCm?.toStringAsFixed(0)} cm', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 14),
                  ],

                  // Apariencia
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.palette_outlined, color: context.colors.primaryLight, size: 20),
                            const SizedBox(width: 10),
                            Text('Apariencia', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _ThemeModeOption(mode: ThemeMode.system, current: themeMode, icon: Icons.brightness_auto_rounded, label: 'Sistema')),
                            const SizedBox(width: 8),
                            Expanded(child: _ThemeModeOption(mode: ThemeMode.light, current: themeMode, icon: Icons.light_mode_rounded, label: 'Claro')),
                            const SizedBox(width: 8),
                            Expanded(child: _ThemeModeOption(mode: ThemeMode.dark, current: themeMode, icon: Icons.dark_mode_rounded, label: 'Oscuro')),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 14),

                  // Template download
                  GlassCard(
                    onTap: () => ExcelExportService.downloadTemplate(context),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.colors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.download_outlined, color: context.colors.accent, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Descargar Plantilla Excel', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600)),
                              Text('Plantilla para importar rutinas (.xlsx)', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: context.colors.textMuted),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 14),

                  // Sign out
                  GlassCard(
                    onTap: () => _confirmSignOut(context),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: context.colors.error, size: 20),
                        SizedBox(width: 14),
                        Text('Cerrar Sesión', style: TextStyle(color: context.colors.error, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('¿Cerrar sesión?', style: TextStyle(color: context.colors.textPrimary)),
        content: Text('Tus datos locales se mantendrán', style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: context.colors.primaryLight))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Salir', style: TextStyle(color: context.colors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signOut();
    }
  }
}

class _StatCard2 extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard2({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: context.colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: context.colors.textMuted, fontSize: 10), maxLines: 2),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends ConsumerWidget {
  final ThemeMode mode;
  final ThemeMode current;
  final IconData icon;
  final String label;

  const _ThemeModeOption({required this.mode, required this.current, required this.icon, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = mode == current;
    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary.withOpacity(0.2) : context.colors.glassWhite,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: context.colors.primary) : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: selected ? context.colors.primaryLight : context.colors.textMuted),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: selected ? context.colors.primaryLight : context.colors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
