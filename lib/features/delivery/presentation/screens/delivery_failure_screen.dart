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

class DeliveryFailureScreen extends StatelessWidget {
  final Delivery delivery;
  const DeliveryFailureScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeliveryCubit>(),
      child: _DeliveryFailureView(delivery: delivery),
    );
  }
}

class _DeliveryFailureView extends StatefulWidget {
  final Delivery delivery;
  const _DeliveryFailureView({required this.delivery});

  @override
  State<_DeliveryFailureView> createState() => _DeliveryFailureViewState();
}

class _DeliveryFailureViewState extends State<_DeliveryFailureView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveryCubit, DeliveryState>(
      listener: (context, state) {
        if (state is DeliveryUpdated) {
          AppDialogs.showSuccessDialog(
            context,
            'Échec signalé pour la commande #${widget.delivery.id}.',
            onConfirm: () => context.go('/dashboard'),
          );
        }
        if (state is DeliveryUpdateError) {
          AppDialogs.showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.error),
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
                          'Signalement',
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
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    AppIcons.warning,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Échec Livraison',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Commande #${widget.delivery.id}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 48),

                // Formulaire de Signalement (Sheet blanc)
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
                            'Raison de l\'échec',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _reasonController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText:
                                  'Expliquez brièvement pourquoi la livraison n\'a pas pu être effectuée (ex: Client absent).',
                              alignLabelWithHint: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La raison de l\'échec est requise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                        const Spacer(),
                        BlocBuilder<DeliveryCubit, DeliveryState>(
                          builder: (context, state) {
                            final isLoading = state is DeliveryUpdating;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        context
                                            .read<DeliveryCubit>()
                                            .reportFailure(widget.delivery);
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
                                  : const Text('Confirmer l\'échec'),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    _reasonController.dispose();
    super.dispose();
  }
}
