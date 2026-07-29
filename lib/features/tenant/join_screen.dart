import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:notegym/core/theme_extension.dart';
import 'package:notegym/widgets/glass_card.dart';
import 'package:notegym/widgets/gradient_button.dart';
import 'package:notegym/models/gym.dart';
import 'package:notegym/features/tenant/gym_service.dart';
import 'package:notegym/features/tenant/tenant_provider.dart';

class JoinScreen extends ConsumerStatefulWidget {
  final String? initialSlug;
  const JoinScreen({super.key, this.initialSlug});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  final _searchCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  List<Gym> _gyms = [];
  List<Gym> _filtered = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _slugCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final gyms = await GymService.getAllGyms();
      if (!mounted) return;
      setState(() {
        _gyms = gyms;
        _filtered = gyms;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No pudimos cargar los gimnasios. Verifica tu conexión.';
      });
    }
  }

  void _filter(String query) {
    setState(() {
      _filtered = _gyms
          .where((g) =>
              g.name.toLowerCase().contains(query.toLowerCase()) ||
              g.slug.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _selectGym(String gymId) async {
    final notifier = ref.read(tenantProvider.notifier);
    await notifier.joinGym(gymId);
    if (!mounted) return;
    if (ref.read(tenantProvider).hasTenant) {
      GoRouter.of(context).go('/home');
    }
  }

  Future<void> _joinBySlug() async {
    final slug = _slugCtrl.text.trim();
    if (slug.isEmpty) return;
    setState(() => _loading = true);
    try {
      final gym = await GymService.getGymBySlug(slug);
      if (!mounted) return;
      if (gym != null) {
        await _selectGym(gym.id);
      } else {
        setState(() {
          _loading = false;
          _error = 'No encontramos un gimnasio con ese slug';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Error al buscar el gimnasio';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0A1A),
                  Color(0xFF1A0A2E),
                  Color(0xFF0D0D1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -80, left: -80,
            child: _GlowOrb(color: context.colors.primary.withValues(alpha: 0.25), size: 300),
          ),
          Positioned(
            bottom: 80, right: -60,
            child: _GlowOrb(color: context.colors.accent.withValues(alpha: 0.2), size: 250),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.apartment_rounded, size: 48, color: context.colors.primary)
                      .animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.7, 0.7)),
                  const SizedBox(height: 16),
                  Text(
                    'Tu gimnasio',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona o busca tu gimnasio',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 32),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: CircularProgressIndicator(),
                    )
                  else ...[
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchCtrl,
                            style: TextStyle(color: context.colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Buscar gimnasio...',
                              prefixIcon: Icon(Icons.search, color: context.colors.textMuted),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: context.colors.textMuted),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        _filter('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: _filter,
                          ),
                          const SizedBox(height: 16),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  Text(_error!, style: TextStyle(color: context.colors.error)),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _loadGyms,
                                    child: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            )
                          else if (_filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  _searchCtrl.text.isEmpty
                                      ? 'No hay gimnasios disponibles'
                                      : 'Sin resultados para "${_searchCtrl.text}"',
                                  style: TextStyle(color: context.colors.textMuted),
                                ),
                              ),
                            )
                          else
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: size.height * 0.35),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final gym = _filtered[index];
                                  return GlassCard(
                                    borderRadius: 14,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    backgroundColor: context.colors.glassWhiteStrong,
                                    onTap: () => _selectGym(gym.id),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            gradient: context.colors.purpleOrangeGradient,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              gym.name.substring(0, 1).toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                gym.name,
                                                style: TextStyle(
                                                  color: context.colors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (gym.address != null && gym.address!.isNotEmpty)
                                                Text(
                                                  gym.address!,
                                                  style: TextStyle(
                                                    color: context.colors.textMuted,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.chevron_right, color: context.colors.textMuted),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'O ingresa el slug manualmente',
                            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _slugCtrl,
                                  style: TextStyle(color: context.colors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'ej: mi-gimnasio',
                                    prefixIcon: Icon(Icons.link, color: context.colors.textMuted),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 48,
                                child: OutlinedGlassButton(
                                  label: 'Vincular',
                                  icon: Icons.arrow_forward_rounded,
                                  onPressed: _joinBySlug,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox(),
      ),
    );
  }
}
