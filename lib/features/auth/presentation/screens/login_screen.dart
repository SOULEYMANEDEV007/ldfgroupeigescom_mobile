import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_feedback.dart';
import '../bloc/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _matriculeController = TextEditingController(text: 'LDF-999');
  final _passwordController = TextEditingController(text: '123');

  bool _isPasswordVisible = false;
  String? _selectedAgence;

  final List<String> _agences = [
    'LDF-Plateau',
    'LDF-Cocody',
    'LDF-Yopougon',
    'LDF-Koumassi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navBarYellow,
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            AppFeedback.error(context, state.message);
          } else if (state is LoginSuccess) {
            context.go('/dashboard');
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // ── Header Jaune (logo + tagline) ──────────────────────────
              Container(
                decoration: const BoxDecoration(gradient: AppGradients.yellow),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/logo/ldfgroupe-icon-app.webp',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Igescom Mobile',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Espace Livreur',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primaryDark.withValues(
                                  alpha: 0.6,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Formulaire (fond gris arrondi sur le haut, non scrollable) ───
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Connexion',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connectez-vous avec vos identifiants LdF',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),

                        // ── Matricule ─────────────────────────────────────
                        TextFormField(
                          controller: _matriculeController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Matricule',
                            hintText: 'Ex : LDF-023',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Mot de passe ──────────────────────────────────
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Agence (Dropdown) ──────────────────────────────
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Agence',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                          // ignore: deprecated_member_use
                          value: _selectedAgence,
                          hint: const Text('Sélectionnez votre agence'),
                          items: _agences.map((agence) {
                            return DropdownMenuItem<String>(
                              value: agence,
                              child: Text(agence),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedAgence = value;
                            });
                          },
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // ── Bouton SE CONNECTER ───────────────────────────
                        ElevatedButton(
                          onPressed: state is LoginLoading
                              ? null
                              : () {
                                  context.read<LoginBloc>().add(
                                    LoginSubmitted(
                                      _matriculeController.text.trim(),
                                      _selectedAgence ?? '',
                                      _passwordController.text,
                                    ),
                                  );
                                },
                          child: state is LoginLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('SE CONNECTER'),
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: Text(
                            '© LdF Groupe CI — Igescom v1.0',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _matriculeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
