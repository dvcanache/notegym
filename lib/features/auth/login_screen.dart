import 'dart:developer';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import 'auth_provider.dart';
import 'presentation/providers/auth_provider.dart' as firebase;
import 'package:notegym/core/theme_extension.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(firebase.authControllerProvider.notifier).signInWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    log('[LoginScreen] Google button clicked');
    await ref.read(firebase.authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final loggedIn = ref.read(authProvider).isLoggedIn;
    log('[LoginScreen] signInWithGoogle completed, isLoggedIn=$loggedIn');
    if (loggedIn) {
      GoRouter.of(context).go('/join');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final localAuthState = ref.watch(authProvider);
    final authControllerState = ref.watch(firebase.authControllerProvider);
    final isLoading = localAuthState.isLoading || authControllerState.isLoading;

    ref.listen<AsyncValue<void>>(firebase.authControllerProvider, (_, next) {
      if (next is AsyncData) {
        if (mounted) GoRouter.of(context).go('/join');
      } else if (next is AsyncError) {
        final error = next.error;
        if (error is FirebaseAuthException &&
            (error.code == 'user-not-found' || error.code == 'invalid-credential')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'No existe una cuenta vinculada a este correo. Por favor regístrate.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Regístrate',
                textColor: Colors.white,
                onPressed: () => context.push('/login/register'),
              ),
            ),
          );
          return;
        }
        final msg = error is FirebaseAuthException
            ? _firebaseErrorMessage(error as FirebaseAuthException)
            : error is Exception
                ? error.toString().replaceFirst('Exception: ', '')
                : error.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0A0A1A),
                  Color(0xFF1A0A2E),
                  Color(0xFF0D0D1A)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Glow orbs
          Positioned(
            top: -80,
            left: -80,
            child: _GlowOrb(
                color: context.colors.primary.withValues(alpha: 0.25),
                size: 300),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: _GlowOrb(
                color: context.colors.accent.withValues(alpha: 0.2), size: 250),
          ),
          Positioned(
            top: size.height * 0.4,
            left: size.width * 0.5,
            child: _GlowOrb(
                color: context.colors.primaryLight.withValues(alpha: 0.1),
                size: 200),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo & Title
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: context.colors.purpleOrangeGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.fitness_center_rounded,
                        color: Colors.white, size: 42),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .scale(begin: const Offset(0.7, 0.7)),

                  const SizedBox(height: 24),

                  Text(
                    'NoteGym',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                  const SizedBox(height: 8),

                  Text(
                    'Tu compañero de entrenamiento personal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 56),

                  // Form
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Comenzar',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Inicia sesión con tu cuenta',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),

                          // Email field
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: context.colors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: context.colors.textMuted),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Ingresa tu correo';
                              if (!v.contains('@')) return 'Correo inválido';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Password field
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            style: TextStyle(color: context.colors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: context.colors.textMuted),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                              if (v.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          GradientButton(
                            label: 'Ingresar',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: isLoading ? null : _signIn,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 16),

                          OutlinedGlassButton(
                            label: 'Continuar con Google',
                            icon: Icons.g_mobiledata_rounded,
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _signInWithGoogle,
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/login/register'),
                              child: Text(
                                '¿No tienes cuenta? Regístrate',
                                style: TextStyle(
                                  color: context.colors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 32),

                  Text(
                    'Tus datos se sincronizan con tu cuenta',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: context.colors.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _firebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña inválidos';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error: ${e.message ?? e.code}';
    }
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
