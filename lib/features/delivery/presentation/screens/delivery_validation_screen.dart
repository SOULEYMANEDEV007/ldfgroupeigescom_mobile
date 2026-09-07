import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_dialogs.dart';
import '../../domain/entities/delivery.dart';
import '../bloc/delivery_cubit.dart';

class DeliveryValidationScreen extends StatelessWidget {
  final Delivery delivery;
  const DeliveryValidationScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveryCubit>(),
      child: _DeliveryValidationView(delivery: delivery),
    );
  }
}

class _DeliveryValidationView extends StatefulWidget {
  final Delivery delivery;
  const _DeliveryValidationView({required this.delivery});

  @override
  State<_DeliveryValidationView> createState() =>
      _DeliveryValidationViewState();
}

class _DeliveryValidationViewState extends State<_DeliveryValidationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryCubit, DeliveryState>(
      listener: (context, state) {
        if (state is DeliveryUpdated) {
          AppDialogs.showSuccessDialog(
            context,
            'Livraison #${widget.delivery.id} validée avec succès !',
            onConfirm: () => context.go('/dashboard'),
          );
        }
        if (state is DeliveryUpdateError) {
          AppDialogs.showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primaryHeader),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    children: [
                      const BackButton(color: Colors.white),
                      Expanded(
                        child: Text(
                          'Validation Livraison',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Icon(
                  AppIcons.checkCircle,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Commande #${widget.delivery.id}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.delivery.clientName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 48),

                // Formulaire de validation (Sheet blanc)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Nom du réceptionnaire',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Ex: Jean Dupont',
                              prefixIcon: Icon(AppIcons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ce champ est requis';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Bouton Photo / Signature (Mock UI)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            onPressed: () {},
                            icon: const Icon(AppIcons.camera),
                            label: const Text('Ajouter une preuve (Optionnel)'),
                          ),

                        const Spacer(),
                        BlocBuilder<DeliveryCubit, DeliveryState>(
                          builder: (context, state) {
                            final isLoading = state is DeliveryUpdating;

                            return ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<DeliveryCubit>()
                                            .validateDelivery(widget.delivery);
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Confirmer la livraison'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
