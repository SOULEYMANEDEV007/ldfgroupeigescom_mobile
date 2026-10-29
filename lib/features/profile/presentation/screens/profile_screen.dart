import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/token_manager.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/widgets/ldf_pattern_background.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs Informations Personnelles
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _telephoneController;
  late TextEditingController _portableController;
  late TextEditingController _adresseController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _lieuNaissanceController;
  late TextEditingController _matriculeController;

  // Contrôleurs Mot de passe
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _telephoneController = TextEditingController();
    _portableController = TextEditingController();
    _adresseController = TextEditingController();
    _dateNaissanceController = TextEditingController();
    _lieuNaissanceController = TextEditingController();
    _matriculeController = TextEditingController();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _portableController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    _lieuNaissanceController.dispose();
    _matriculeController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfile profile) {
    _nomController.text = profile.nom;
    _prenomController.text = profile.prenom;
    _telephoneController.text = profile.telephone;
    _portableController.text = profile.portable;
    _adresseController.text = profile.adresse;
    _dateNaissanceController.text = profile.dateNaissance;
    _lieuNaissanceController.text = profile.lieuNaissance;
    _matriculeController.text = profile.matricule.isNotEmpty
        ? profile.matricule
        : profile.codeAgent;
  }

  @override
  Widget build(BuildContext context) {
    return LdfPatternBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && state.successMessage != null) {
            AppFeedback.success(context, state.successMessage!);
          } else if (state is ProfileError) {
            AppFeedback.error(context, state.message);
          }
        },
        builder: (context, state) {
          UserProfile? profile;
          bool isLoading = false;
          bool isUpdating = false;
          bool isPasswordUpdating = false;

          if (state is ProfileLoading || state is ProfileInitial) {
            isLoading = true;
          } else if (state is ProfileLoaded) {
            profile = state.profile;
            _populateControllers(profile);
          } else if (state is ProfileUpdating) {
            profile = state.profile;
            isUpdating = true;
          } else if (state is ProfilePasswordUpdating) {
            profile = state.profile;
            isPasswordUpdating = true;
          } else if (state is ProfileError && state.fallbackProfile != null) {
            profile = state.fallbackProfile;
            _populateControllers(profile!);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── HEADER UNIFORME AVEC DÉGRADÉ ──────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primaryHeader,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(AppIcons.back, color: Colors.white),
                          onPressed: () => context.go('/dashboard'),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Mon Profil',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.navBarYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.navBarYellow,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            profile?.agencyCode ?? 'DGC',
                            style: const TextStyle(
                              color: AppColors.navBarYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── CONTENU DU PROFIL ──────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── CARTE IDENTITÉ / AVATAR ─────────────────────
                            _buildIdentityCard(context, profile),
                            const SizedBox(height: 16),

                            // ── INFORMATIONS PERSONNELLES ───────────────────
                            _buildPersonalInfoCard(
                              context,
                              profile,
                              isUpdating: isUpdating,
                            ),
                            const SizedBox(height: 16),

                            // ── CHANGER LE MOT DE PASSE ─────────────────────
                            _buildPasswordChangeCard(
                              context,
                              isPasswordUpdating: isPasswordUpdating,
                            ),
                            const SizedBox(height: 24),

                            // ── BOUTON DE DÉCONNEXION ───────────────────────
                            _buildLogoutButton(context),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

  // ── Carte Identité & Rôle ──────────────────────────────────────────────────
  Widget _buildIdentityCard(BuildContext context, UserProfile? profile) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primarySoft,
                child: const Icon(
                  AppIcons.person,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.camera,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.nomComplet.toUpperCase() ?? 'CONVOYEUR TEST',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    profile?.role.isNotEmpty == true
                        ? profile!.role
                        : 'CONVOYEUR - LIVREUR',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile?.agency ?? 'DEPOT GRANDS COMPTES',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte Formulaire Infos Personnelles ─────────────────────────────────────
  Widget _buildPersonalInfoCard(
    BuildContext context,
    UserProfile? profile, {
    required bool isUpdating,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    AppIcons.person,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Informations Personnelles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Nom & Prénom en 2 colonnes
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _nomController,
                    label: 'Nom',
                    hintText: 'Votre nom',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _prenomController,
                    label: 'Prénom',
                    hintText: 'Votre prénom',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Téléphone & Portable
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _telephoneController,
                    label: 'Téléphone',
                    hintText: 'Numéro de téléphone',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _portableController,
                    label: 'Portable',
                    hintText: 'Numéro de portable',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Adresse
            _buildTextField(
              controller: _adresseController,
              label: 'Adresse',
              hintText: 'Votre adresse complète',
            ),
            const SizedBox(height: 14),

            // Date de Naissance & Lieu de Naissance
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _dateNaissanceController,
                    label: 'Date de Naissance',
                    hintText: 'jj/mm/aaaa',
                    readOnly: true,
                    suffixIcon: const Icon(
                      AppIcons.calendar,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(1995, 1, 1),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        final formatted =
                            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                        _dateNaissanceController.text = formatted;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _lieuNaissanceController,
                    label: 'Lieu de Naissance',
                    hintText: 'Lieu de naissance',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Matricule (Readonly)
            _buildTextField(
              controller: _matriculeController,
              label: 'Matricule / Identifiant',
              hintText: '0000',
              readOnly: true,
              fillColor: Colors.grey.shade100,
            ),
            const SizedBox(height: 14),

            // Rôles ou Compétences (Badge d'information)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rôles ou Compétences',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        AppIcons.truck,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        profile?.role.isNotEmpty == true
                            ? profile!.role
                            : 'CONVOYEUR - LIVREUR',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bouton "Actualiser mes Infos"
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() ?? true) {
                        final updated = (profile ??
                                UserProfile(
                                  codeAgent:
                                      getIt<TokenManager>().getCodeAgent() ?? '',
                                  username:
                                      getIt<TokenManager>().getUserName() ?? '',
                                  nom: _nomController.text,
                                  prenom: _prenomController.text,
                                  telephone: _telephoneController.text,
                                  portable: _portableController.text,
                                  adresse: _adresseController.text,
                                  dateNaissance: _dateNaissanceController.text,
                                  lieuNaissance: _lieuNaissanceController.text,
                                  matricule: _matriculeController.text,
                                  role: 'CONVOYEUR - LIVREUR',
                                  agency: 'DEPOT GRANDS COMPTES',
                                  agencyCode: 'DGC',
                                ))
                            .copyWith(
                          nom: _nomController.text.trim(),
                          prenom: _prenomController.text.trim(),
                          telephone: _telephoneController.text.trim(),
                          portable: _portableController.text.trim(),
                          adresse: _adresseController.text.trim(),
                          dateNaissance: _dateNaissanceController.text.trim(),
                          lieuNaissance: _lieuNaissanceController.text.trim(),
                        );

                        context.read<ProfileCubit>().updateProfile(updated);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Actualiser mes Infos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carte Formulaire Changement Mot de Passe ────────────────────────────────
  Widget _buildPasswordChangeCard(
    BuildContext context, {
    required bool isPasswordUpdating,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  AppIcons.lock,
                  size: 18,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Changer le mot de passe',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const Divider(height: 24),

          _buildTextField(
            controller: _oldPasswordController,
            label: 'Ancien mot de passe',
            hintText: 'Saisissez votre ancien mot de passe',
            obscureText: _obscureOldPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureOldPassword ? AppIcons.eyeOff : AppIcons.eye,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureOldPassword = !_obscureOldPassword),
            ),
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _newPasswordController,
            label: 'Nouveau mot de passe',
            hintText: 'Saisissez le nouveau mot de passe',
            obscureText: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? AppIcons.eyeOff : AppIcons.eye,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
          ),
          const SizedBox(height: 12),

          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirmation',
            hintText: 'Confirmez le nouveau mot de passe',
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? AppIcons.eyeOff : AppIcons.eye,
                size: 18,
                color: Colors.grey,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          const SizedBox(height: 20),

          OutlinedButton(
            onPressed: isPasswordUpdating
                ? null
                : () {
                    final oldPass = _oldPasswordController.text.trim();
                    final newPass = _newPasswordController.text.trim();
                    final confirmPass = _confirmPasswordController.text.trim();

                    if (oldPass.isEmpty || newPass.isEmpty) {
                      AppFeedback.error(
                        context,
                        'Veuillez renseigner votre ancien et nouveau mot de passe.',
                      );
                      return;
                    }

                    if (newPass != confirmPass) {
                      AppFeedback.error(
                        context,
                        'La confirmation ne correspond pas au nouveau mot de passe.',
                      );
                      return;
                    }

                    context.read<ProfileCubit>().changePassword(oldPass, newPass);
                    _oldPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isPasswordUpdating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text(
                    'Changer le mot de passe',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Bouton Déconnexion ─────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.error, width: 1.4),
        foregroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () async {
        final confirmed = await AppDialogs.showConfirmationDialog(
          context,
          title: 'Déconnexion',
          message:
              'Êtes-vous sûr de vouloir vous déconnecter de votre session ? Vos données sont synchronisées avec le serveur.',
          confirmText: 'Se déconnecter',
          cancelText: 'Annuler',
          isDestructive: true,
        );

        if (confirmed && context.mounted) {
          await getIt<TokenManager>().clearSession();
          if (context.mounted) {
            context.go('/login');
          }
        }
      },
      icon: const Icon(AppIcons.logout),
      label: const Text(
        'Se déconnecter',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── Helper TextField Standardisé ───────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    Color? fillColor,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: fillColor ?? Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
