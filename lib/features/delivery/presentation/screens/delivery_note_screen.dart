import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../domain/entities/delivery.dart';
import '../widgets/signature_pad_dialog.dart';

class DeliveryNoteScreen extends StatefulWidget {
  final Delivery? delivery;
  const DeliveryNoteScreen({super.key, this.delivery});

  @override
  State<DeliveryNoteScreen> createState() => _DeliveryNoteScreenState();
}

class _DeliveryNoteScreenState extends State<DeliveryNoteScreen> {
  double _zoomScale = 1.0;
  final TransformationController _transformationController =
      TransformationController();

  void _zoomIn() {
    setState(() {
      _zoomScale = (_zoomScale + 0.15).clamp(0.8, 1.6);
      _transformationController.value = Matrix4.diagonal3Values(
        _zoomScale,
        _zoomScale,
        1.0,
      );
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomScale = (_zoomScale - 0.15).clamp(0.8, 1.6);
      _transformationController.value = Matrix4.diagonal3Values(
        _zoomScale,
        _zoomScale,
        1.0,
      );
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;
    final blNumber =
        delivery?.deliveryNote?.number ??
        delivery?.deliveryNoteNumber ??
        'BL-2026-00452';

    return Scaffold(
      backgroundColor: const Color(0xFF1E293B), // Fond ardoise PDF viewer
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // Header viewer sombre
        elevation: 2,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: Colors.white),
          onPressed: () => context.pop(),
          tooltip: 'Retour',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$blNumber.pdf',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            const Text(
              'Aperçu du document officiel (PDF)',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Bouton Imprimer
          IconButton(
            icon: const Icon(AppIcons.printer, color: Colors.white, size: 20),
            tooltip: 'Imprimer',
            onPressed: () {
              AppFeedback.info(
                context,
                'Envoi du Bon de Livraison $blNumber à l\'imprimante…',
              );
            },
          ),
          // Bouton Télécharger
          IconButton(
            icon: const Icon(AppIcons.download, color: Colors.white, size: 20),
            tooltip: 'Télécharger',
            onPressed: () {
              AppFeedback.success(
                context,
                'Document $blNumber.pdf enregistré dans vos téléchargements.',
              );
            },
          ),
          // Bouton Partager
          IconButton(
            icon: const Icon(AppIcons.share, color: Colors.white, size: 20),
            tooltip: 'Partager',
            onPressed: () {
              AppFeedback.info(
                context,
                'Partage du Bon de Livraison $blNumber…',
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          // ── Zone de prévisualisation avec zoom & scroll ──────────────────────
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.7,
              maxScale: 2.0,
              boundaryMargin: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: _buildPaperDocument(context, delivery: delivery),
                  ),
                ),
              ),
            ),
          ),

          // ── Barre d'outils flottante de la visionneuse (Zoom & Pages) ─────────
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge Page
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Page 1 / 1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 18,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),

                    // Zoom Out
                    IconButton(
                      icon: const Icon(AppIcons.zoomOut, size: 18),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Dézoomer',
                      onPressed: _zoomOut,
                    ),

                    // Zoom Indicator / Reset
                    InkWell(
                      onTap: _resetZoom,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          '${(_zoomScale * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Zoom In
                    IconButton(
                      icon: const Icon(AppIcons.zoomIn, size: 18),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Zoomer',
                      onPressed: _zoomIn,
                    ),

                    const SizedBox(width: 4),
                    Container(
                      height: 18,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),

                    // Bouton Plein écran / Recentrer
                    IconButton(
                      icon: const Icon(AppIcons.maximize, size: 18),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      tooltip: 'Ajuster à l\'écran',
                      onPressed: _resetZoom,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feuille de document papier A4 ──────────────────────────────────────────
  Widget _buildPaperDocument(
    BuildContext context, {
    required Delivery? delivery,
  }) {
    final deliveryNote = delivery?.deliveryNote;
    final blNumber =
        deliveryNote?.number ?? delivery?.deliveryNoteNumber ?? 'BL-2026-00452';
    final clientName =
        deliveryNote?.clientName ?? delivery?.clientName ?? 'Client LDF';
    final address =
        deliveryNote?.clientAddress ?? delivery?.address ?? 'Abidjan';
    final phone = delivery?.phone ?? '';
    final codeClt = deliveryNote?.clientCode ?? delivery?.clientCode ?? '';
    final compteContrib = deliveryNote?.compteContrib ?? '';
    final orderNumber = deliveryNote?.orderNumber ?? '';
    final chauffeur = deliveryNote?.livreurName ?? 'ADMIN PLATEAU';
    final vehicule =
        deliveryNote?.vehiclePlate ?? 'Toyota Land Cruiser (ABJ-1010-CI)';
    final agence = deliveryNote?.agence ?? 'Plateau';
    final items = deliveryNote?.items ?? [];
    final totalAmount = deliveryNote?.totalAmount ?? delivery?.amount ?? 0.0;
    final dateStr = delivery != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(delivery.scheduledTime)
        : DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final statusStr = delivery?.status == DeliveryStatus.delivered
        ? 'LIVRÉ'
        : (delivery?.status == DeliveryStatus.cancelled
              ? 'REPORTÉ'
              : 'EN ATTENTE');
    final signedBy = delivery?.signedBy ?? deliveryNote?.signedBy;
    final signatureData = delivery?.signatureData ?? deliveryNote?.signatureUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Bandeau En-tête officiel LdF ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo & Société
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          'assets/images/ldf_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LdF GROUPE CI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Distribution — Agence ${agence.toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'RCCM : CI-ABJ-2023-B-1452',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 8.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Titre BL & Métadonnées
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navBarYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BON DE LIVRAISON',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'N° $blNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Date : $dateStr',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Corps du Document ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Boîtes Émetteur & Destinataire ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Émetteur
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EXPÉDITEUR',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'LDF Central Hub Abidjan',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Agence ${agence.toUpperCase()} · Z.I Yopougon',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.5,
                              ),
                            ),
                            const Text(
                              '+225 27 20 00 00 00',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Destinataire / Client
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DESTINATAIRE / CLIENT',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              clientName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (codeClt.isNotEmpty && codeClt != 'N/A') ...[
                              const SizedBox(height: 1),
                              Text(
                                'Code Client : $codeClt',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (compteContrib.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                'Compte Contrib. : $compteContrib',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                            Text(
                              address,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.5,
                              ),
                            ),
                            if (phone.isNotEmpty)
                              Text(
                                'Tél : $phone',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 9.5,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Références Tournée & Véhicule (Grille 2x2 Adaptative) ────
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniInfo(
                              'CHAUFFEUR / LIVREUR',
                              chauffeur,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniInfo('VÉHICULE FLOTTE', vehicule),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniInfo(
                              'COMMANDE N°',
                              orderNumber.isNotEmpty ? orderNumber : 'N/A',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMiniInfo('STATUT DU BL', statusStr),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tableau des Articles ─────────────────────────────────────
                const Text(
                  'DÉTAIL DES ARTICLES COMMANDÉS',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),

                // Header Tableau
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 22,
                        child: Text(
                          'N°',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Désignation / Article',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Condit.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Montant TTC',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      SizedBox(
                        width: 44,
                        child: Text(
                          'Contrôle',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lignes d'articles réelles
                if (items.isNotEmpty)
                  Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isTax = item.reference.startsWith('TAX');
                      final amountFormatted = item.totalPrice > 0
                          ? '${NumberFormat('#,##0', 'fr_FR').format(item.totalPrice)} F'
                          : '0 F';
                      return _buildTableRow(
                        (index + 1).toString(),
                        item.designation,
                        '${item.quantity} ${item.unit}',
                        amountFormatted,
                        isEven: index.isOdd,
                        isTax: isTax,
                      );
                    }),
                  )
                else
                  _buildTableRow(
                    '1',
                    orderNumber.isNotEmpty
                        ? 'Marchandises Commande N° $orderNumber'
                        : 'Marchandises $clientName',
                    '1 lot',
                    totalAmount > 0
                        ? '${NumberFormat('#,##0', 'fr_FR').format(totalAmount)} F'
                        : '0 F',
                    isEven: false,
                  ),

                // ── Totaux du BL (Adaptatif) ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.packageCheck,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'TOTAL : ${items.isNotEmpty ? items.length : 1} ligne(s)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'TOTAL BL : ${NumberFormat('#,##0', 'fr_FR').format(totalAmount)} FCFA',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Observations & Mentions légales ──────────────────────────
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'OBSERVATIONS & CONDITIONS DE RÉCEPTION :',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Marchandise livrée sous réserve de vérification de conformité. Les réclamations doivent être formulées sous 48h auprès de LdF Groupe.',
                        style: TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF78350F),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Bloc Signatures & Cachet Officiel ────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Signature Livreur
                    Expanded(
                      child: Container(
                        height: 95,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VISA LIVREUR / LOGISTIQUE',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: Text(
                                'Signé numériquement\n$chauffeur',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Signature & Cachet Client
                    Expanded(
                      child: Container(
                        height: 95,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'CACHET & SIGNATURE CLIENT',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (signedBy != null && signedBy.isNotEmpty)
                                  Text(
                                    'Réceptionnaire : $signedBy',
                                    style: const TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const Spacer(),
                                if (signatureData == null ||
                                    signatureData.isEmpty)
                                  Center(
                                    child: Text(
                                      delivery?.status ==
                                              DeliveryStatus.delivered
                                          ? 'Validé directement\n(Visa numérique)'
                                          : 'En attente de réception\net signature client',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                              ],
                            ),

                            // Signature manuscrite tracée en direct si disponible
                            if (signatureData != null &&
                                signatureData.isNotEmpty)
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 18,
                                    bottom: 4,
                                    right: 30,
                                  ),
                                  child: SignatureViewer(
                                    signatureData: signatureData,
                                    strokeColor: const Color(0xFF0F2F64),
                                    strokeWidth: 1.8,
                                  ),
                                ),
                              ),

                            // Tampon officiel vert en filigrane si validé
                            if (delivery?.status == DeliveryStatus.delivered)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Transform.rotate(
                                  angle: -0.15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.success,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      (signatureData != null &&
                                              signatureData.isNotEmpty)
                                          ? 'ÉMARGÉ\nLDF DIGITAL'
                                          : 'CONFORME\nLDF LIVRAISON',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Code-barres simulé en bas
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 22,
                        width: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            28,
                            (index) => Container(
                              width: (index % 3 == 0)
                                  ? 3
                                  : (index % 2 == 0 ? 1 : 2),
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '*$blNumber*',
                        style: const TextStyle(
                          fontSize: 8.5,
                          letterSpacing: 2,
                          color: AppColors.textSecondary,
                        ),
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

  Widget _buildMiniInfo(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          val,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTableRow(
    String num,
    String name,
    String qte,
    String montant, {
    required bool isEven,
    bool isTax = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: isTax
            ? const Color(0xFFF1F5F9)
            : (isEven ? const Color(0xFFF8FAFC) : Colors.white),
        border: const Border(
          left: BorderSide(color: Color(0xFFE2E8F0)),
          right: BorderSide(color: Color(0xFFE2E8F0)),
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              num,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isTax ? FontWeight.w600 : FontWeight.w500,
                color: isTax ? AppColors.textSecondary : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              qte,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              montant,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isTax ? FontWeight.w600 : FontWeight.w700,
                color: isTax ? AppColors.textSecondary : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 44,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.successSoft,
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.check, size: 8, color: AppColors.success),
                  SizedBox(width: 2),
                  Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
