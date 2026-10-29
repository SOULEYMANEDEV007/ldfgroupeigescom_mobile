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
    final blNumber = (delivery?.deliveryNote?.number.isNotEmpty == true &&
            delivery!.deliveryNote!.number != 'N/A')
        ? 'BL-${delivery.deliveryNote!.number}'
        : (delivery?.deliveryNoteNumber.isNotEmpty == true
            ? delivery!.deliveryNoteNumber
            : 'BL');

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

  // ── Feuille de document papier A4 officiel IGESCOM ──────────────────────────
  Widget _buildPaperDocument(
    BuildContext context, {
    required Delivery? delivery,
  }) {
    final deliveryNote = delivery?.deliveryNote;
    final blNumber = (deliveryNote?.number.isNotEmpty == true && deliveryNote!.number != 'N/A')
        ? deliveryNote.number
        : (delivery?.deliveryNoteNumber.replaceAll('BL-', '') ?? '');
    final orderNumber = deliveryNote?.orderNumber ?? '';
    final clientCode = (deliveryNote?.clientCode.isNotEmpty == true)
        ? deliveryNote!.clientCode
        : (delivery?.clientCode ?? '');
    final clientName = (deliveryNote?.clientName.isNotEmpty == true)
        ? deliveryNote!.clientName
        : (delivery?.clientName ?? '');
    final address = (deliveryNote?.clientAddress.isNotEmpty == true)
        ? deliveryNote!.clientAddress
        : (delivery?.address ?? '');
    final phone = delivery?.phone.isNotEmpty == true ? delivery!.phone : '';
    final compteContrib = deliveryNote?.compteContrib ?? '';
    final chauffeur = (deliveryNote?.livreurName.isNotEmpty == true)
        ? deliveryNote!.livreurName
        : 'Livreur LDF';
    final items = deliveryNote?.items ?? [];

    final dateStr = delivery != null
        ? DateFormat('dd/MM/yyyy').format(delivery.scheduledTime)
        : DateFormat('dd/MM/yyyy').format(DateTime.now());

    final montantHt = deliveryNote?.montantHtCumule ?? (delivery?.amount ?? 0.0);
    final totalTva = deliveryNote?.totalTva ?? 0.0;
    final montantTtc = deliveryNote?.montantTtc ?? (delivery?.amount ?? 0.0);
    final netAPayer = deliveryNote?.netAPayer ?? (delivery?.amount ?? 0.0);
    final regulObs = deliveryNote?.observationRegul ?? delivery?.notes ?? '';

    final signedBy = delivery?.signedBy ?? deliveryNote?.signedBy;
    final signatureData = delivery?.signatureData ?? deliveryNote?.signatureUrl;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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
          // ── En-tête : Société (Gauche) & Titre BL (Droite) ──────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏢 GAUCHE : Cartouche légal & bancaire officiel LDF
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'LIBRAIRIE DE FRANCE GROUPE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'S.A avec C.A au capital de 2 188 950 000\n'
                      'RC : CI-ABJ-1995-B-188116-CC N° 9511970 B\n'
                      'Régime normal CDI DGE\n'
                      'BICICI : CI006 01550 0100720000110 11\n'
                      'BIAO : CI042 01231 031360265625 54\n'
                      'SIB : CI007 01030 026681600120 50\n'
                      'BNI : CI092 01001 00207550003 61\n'
                      'ECOBANK : CI059 01010 00005786618 09\n'
                      '01 BP 228 Abidjan 01\n'
                      'Librairie de France\n'
                      'Tél. : 20 30 63 63 - Fax : 20 30 63 64\n'
                      'Email : ldf@ldfgroupe.com\n'
                      'Burotop\n'
                      'Barnoin Informatique\n'
                      'Tél : 20 25 31 25 - Fax : 20 22 08 92\n'
                      'N° Compte comptable :',
                      style: TextStyle(
                        fontSize: 7.5,
                        height: 1.15,
                        color: Colors.black54,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 📄 DROITE : igescom + BON DE LIVRAISON + Références & Client
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'igescom',
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black87, width: 1.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'BON DE LIVRAISON',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildMetaLine(
                      'Référence',
                      orderNumber.isNotEmpty
                          ? '$blNumber de la Cmd : N° $orderNumber'
                          : (blNumber.isNotEmpty ? 'N° $blNumber' : ''),
                      boldVal: true,
                    ),
                    _buildMetaLine('Date', dateStr),
                    _buildMetaLine('Devise', 'FCFA'),
                    _buildMetaLine('Mode de règlement', ''),
                    const SizedBox(height: 4),
                    _buildMetaLine(
                      'CLIENT',
                      clientCode.isNotEmpty
                          ? '($clientCode) $clientName'
                          : clientName,
                      boldVal: true,
                    ),
                    if (compteContrib.isNotEmpty)
                      _buildMetaLine('N°Cpte contribuable', compteContrib),
                    if (address.isNotEmpty)
                      _buildMetaLine('Adresse', address),
                    if (phone.isNotEmpty)
                      _buildMetaLine('Tél.', phone),
                    _buildMetaLine('Fax', ''),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Tableau officiel des Articles (8 colonnes) ─────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 1),
            ),
            child: Column(
              children: [
                // En-tête du tableau
                Container(
                  color: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    children: const [
                      SizedBox(
                        width: 70,
                        child: Text(
                          'Code Produit',
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Désignation',
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          'Qté LIV',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 45,
                        child: Text(
                          'N° série',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 55,
                        child: Text(
                          'Prix HT',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 55,
                        child: Text(
                          'MONTANT',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 14,
                        child: Text(
                          'T',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      SizedBox(
                        width: 14,
                        child: Text(
                          'A',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Colors.black87),

                // Lignes réelles des articles
                if (items.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                    alignment: Alignment.center,
                    child: const Text(
                      'Détail des articles non disponible',
                      style: TextStyle(
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  )
                else
                  ...items.map((it) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.productCode,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                if (it.barcode != null && it.barcode!.isNotEmpty)
                                  Text(
                                    it.barcode!,
                                    style: const TextStyle(
                                      fontSize: 6.5,
                                      color: Colors.black54,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              it.designation,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              it.quantity.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 45,
                            child: Text(
                              it.serialNumber ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 7.5),
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            child: Text(
                              NumberFormat('#,##0.00', 'fr_FR').format(it.unitPriceHt),
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 7.5, fontFamily: 'monospace'),
                            ),
                          ),
                          SizedBox(
                            width: 55,
                            child: Text(
                              NumberFormat('#,##0.00', 'fr_FR').format(it.totalPriceHt),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 14,
                            child: Text(
                              it.taxCode,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 7.5),
                            ),
                          ),
                          SizedBox(
                            width: 14,
                            child: Text(
                              it.arsiCode,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 7.5),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          if (regulObs.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              regulObs,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // ── Bloc Récapitulatif : TAXES & TOTAUX ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grille TAXES
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFFF1F5F9),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: const Text(
                          'TAXES',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.8, color: Colors.black87),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            _buildTaxLine('Code TVA : 1', 'ARSI : 1', 'Code ARSI : 2'),
                            _buildTaxLine('Taux : 18 %', 'Taux : 5%', 'Taux : 2%'),
                            _buildTaxLine(
                              'Base : ${NumberFormat('#,##0', 'fr_FR').format(deliveryNote?.tvaBase ?? (totalTva > 0 ? montantHt : 0.0))}',
                              'Base : ${NumberFormat('#,##0', 'fr_FR').format(deliveryNote?.arsiBase ?? 0.0)}',
                              'Base : 0',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Grille TOTAUX & NET À PAYER
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFFF1F5F9),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Expanded(
                              child: Text(
                                'MONTANT HT CUMULE',
                                style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Total TVA',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'MONTANT TTC',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.8, color: Colors.black87),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                NumberFormat('#,##0', 'fr_FR').format(montantHt),
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                NumberFormat('#,##0', 'fr_FR').format(totalTva),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                NumberFormat('#,##0', 'fr_FR').format(montantTtc),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.8, color: Colors.black87),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        color: const Color(0xFFFFFBEB),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'NET A PAYER :',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,##0', 'fr_FR').format(netAPayer)} FCFA',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Bloc Émargement & Signatures numériques ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visa Livreur
              Expanded(
                child: Container(
                  height: 85,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VISA LIVREUR / LOGISTIQUE',
                        style: TextStyle(
                          fontSize: 7.5,
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
                            fontSize: 7.5,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Cachet & Signature Client tactile
              Expanded(
                child: Container(
                  height: 85,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCBD5E1)),
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
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (signedBy != null && signedBy.isNotEmpty)
                            Text(
                              'Réceptionnaire : $signedBy',
                              style: const TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const Spacer(),
                          if (signatureData == null || signatureData.isEmpty)
                            Center(
                              child: Text(
                                delivery?.status == DeliveryStatus.delivered
                                    ? 'Validé directement\n(Visa numérique)'
                                    : 'En attente de réception\net signature client',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 7,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          const Spacer(),
                        ],
                      ),
                      if (signatureData != null && signatureData.isNotEmpty)
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 14, bottom: 2, right: 20),
                            child: SignatureViewer(
                              signatureData: signatureData,
                              strokeColor: const Color(0xFF0F2F64),
                              strokeWidth: 1.6,
                            ),
                          ),
                        ),
                      if (delivery?.status == DeliveryStatus.delivered)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Transform.rotate(
                            angle: -0.12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.success, width: 1.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Text(
                                'ÉMARGÉ\nLDF DIGITAL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w900,
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
        ],
      ),
    );
  }

  Widget _buildMetaLine(String label, String value, {bool boldVal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 8,
                fontWeight: boldVal ? FontWeight.w800 : FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxLine(String col1, String col2, String col3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: Text(
              col1,
              style: const TextStyle(fontSize: 6.5, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Text(
              col2,
              style: const TextStyle(fontSize: 6.5, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Text(
              col3,
              style: const TextStyle(fontSize: 6.5, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
