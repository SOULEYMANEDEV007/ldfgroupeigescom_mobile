import '../../domain/entities/delivery.dart';
import '../../domain/entities/delivery_line_item.dart';
import '../../domain/entities/delivery_note.dart';

/// Modèle de données pour la désérialisation JSON de l'API IGSCOM.
class DeliveryModel extends Delivery {
  const DeliveryModel({
    required super.id,
    required super.tourId,
    required super.clientCode,
    required super.clientName,
    required super.deliveryNoteNumber,
    required super.weight,
    required super.amount,
    required super.address,
    required super.phone,
    required super.status,
    required super.scheduledTime,
    required super.notes,
    super.deliveryNote,
    super.signedBy,
    super.signatureData,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    // Cas 1 : Payload réel issu de l'API IGESCOM (`lignes[]` dans convotournees)
    if (json.containsKey('code_ligne') || json.containsKey('code_bl')) {
      final livraison = json['livraison'] is Map<String, dynamic>
          ? json['livraison'] as Map<String, dynamic>
          : null;
      final commande = livraison?['commande'] is Map<String, dynamic>
          ? livraison!['commande'] as Map<String, dynamic>
          : null;
      final client = commande?['client'] is Map<String, dynamic>
          ? commande!['client'] as Map<String, dynamic>
          : null;

      final rawCodeBl = json['code_bl'] ?? livraison?['code_bl'];
      final codeBlStr = rawCodeBl != null
          ? (rawCodeBl is num
                ? rawCodeBl.toInt().toString()
                : rawCodeBl.toString())
          : 'N/A';

      final clientName = client?['nom_clt']?.toString().trim();
      final address = client?['adresse_clt']?.toString().trim();
      final city = client?['ville_clt']?.toString().trim();

      final fullAddress = (address != null && address.isNotEmpty)
          ? address
          : ((city != null && city.isNotEmpty) ? city : 'Abidjan');

      final statutLivraison = json['statut_livraison']
          ?.toString()
          .toUpperCase();
      final status = _statusFromApiString(statutLivraison);

      // ── Traçabilité des dates selon le statut ──
      final rawDateLivraison = json['date_livraison']?.toString().trim();
      final rawDateReport = json['date_report']?.toString().trim();
      final rawDateLivr = livraison?['date_livr']?.toString().trim();

      final hasDeliveryDate =
          rawDateLivraison != null &&
          rawDateLivraison.isNotEmpty &&
          rawDateLivraison != 'null';
      final hasReportDate =
          rawDateReport != null &&
          rawDateReport.isNotEmpty &&
          rawDateReport != 'null';
      final hasLivrDate =
          rawDateLivr != null &&
          rawDateLivr.isNotEmpty &&
          rawDateLivr != 'null';

      final String? dateStr;
      if (status == DeliveryStatus.delivered && hasDeliveryDate) {
        dateStr = rawDateLivraison;
      } else if (status == DeliveryStatus.cancelled && hasReportDate) {
        dateStr = rawDateReport;
      } else if (hasLivrDate) {
        dateStr = rawDateLivr;
      } else if (hasDeliveryDate) {
        dateStr = rawDateLivraison;
      } else if (hasReportDate) {
        dateStr = rawDateReport;
      } else {
        dateStr = json['created_at']?.toString();
      }

      final scheduledTime =
          (dateStr != null ? DateTime.tryParse(dateStr)?.toLocal() : null) ??
          DateTime.now();

      final montArsi = (livraison?['mont_arsi_bl'] as num?)?.toDouble() ?? 0.0;
      final montTva = (livraison?['mont_tva_bl'] as num?)?.toDouble() ?? 0.0;
      final taxes = montArsi + montTva;

      // Recherche du montant total déclaré dans livraison ou commande
      final rawTotal =
          (livraison?['mont_ttc_bl'] ??
                  livraison?['mont_bl'] ??
                  livraison?['mont_ht_bl'] ??
                  livraison?['montant'] ??
                  commande?['mont_ttc_com'] ??
                  commande?['mont_com'] ??
                  commande?['montant'])
              as num?;

      // Montant total de référence (15 F si seule la taxe/ARSI est retournée)
      final double totalReference = (rawTotal != null && rawTotal > 0)
          ? rawTotal.toDouble()
          : (taxes > 0 ? taxes : 0.0);

      final note = json['observation_livraison']?.toString().trim();
      final commentBl = livraison?['comment_bl']?.toString().trim();
      final finalNotes = (note != null && note.isNotEmpty)
          ? note
          : (commentBl ?? '');

      // ── Données enrichies du BL ──
      final rawCodeCom = livraison?['code_com'] ?? commande?['code_com'];
      final codeComStr = rawCodeCom != null
          ? (rawCodeCom is num
                ? rawCodeCom.toInt().toString()
                : rawCodeCom.toString())
          : '';
      final compteContrib = client?['compte_contrib']?.toString().trim() ?? '';
      final nomBonl = livraison?['nom_bonl']?.toString().trim() ?? '';
      final codeAgce =
          livraison?['code_agce']?.toString().trim() ??
          commande?['code_agce']?.toString().trim() ??
          (json['agence_tournee']?.toString().trim() ?? 'PLA');

      final chauffeurOrLivreur =
          (json['chauffeur_name']?.toString().isNotEmpty ?? false)
          ? json['chauffeur_name']!.toString()
          : (json['livreur_name']?.toString() ?? 'Équipe LDF');
      final vehiclePlate = json['vehicle_plate']?.toString() ?? 'Véhicule LDF';

      // ── Génération des lignes de commande réelles (Articles du BL) ──
      final List<DeliveryLineItem> items = [];
      final String desig = nomBonl.isNotEmpty
          ? 'Marchandises Commande N° $codeComStr ($nomBonl)'
          : (codeComStr.isNotEmpty
                ? 'Marchandises Commande N° $codeComStr'
                : 'Marchandises Client ${clientName ?? "LDF"}');

      // Si un montant global supérieur aux taxes existe, on déduit les taxes du prix marchandise
      // Sinon (ex: 15 F total avec ARSI de 15 F), la ligne marchandise vaut le total sans doublon
      if (totalReference > taxes && taxes > 0) {
        final prixMarchandise = totalReference - taxes;
        items.add(
          DeliveryLineItem(
            reference: codeComStr.isNotEmpty
                ? 'CMD-$codeComStr'
                : 'BL-$codeBlStr',
            designation: desig,
            quantity: 1,
            unitPrice: prixMarchandise,
            totalPrice: prixMarchandise,
            unit: 'lot',
          ),
        );
        if (montArsi > 0) {
          items.add(
            DeliveryLineItem(
              reference: 'TAX-ARSI',
              designation: 'Retenue ARSI légale',
              quantity: 1,
              unitPrice: montArsi,
              totalPrice: montArsi,
              unit: 'taxe',
            ),
          );
        }
        if (montTva > 0) {
          items.add(
            DeliveryLineItem(
              reference: 'TAX-TVA',
              designation: 'Taxe sur la Valeur Ajoutée (TVA)',
              quantity: 1,
              unitPrice: montTva,
              totalPrice: montTva,
              unit: 'taxe',
            ),
          );
        }
      } else {
        // Cas forfaitaire / test : une seule ligne de marchandise avec mention ARSI si applicable
        items.add(
          DeliveryLineItem(
            reference: codeComStr.isNotEmpty
                ? 'CMD-$codeComStr'
                : 'BL-$codeBlStr',
            designation: montArsi > 0 ? '$desig (dont Retenue ARSI)' : desig,
            quantity: 1,
            unitPrice: totalReference,
            totalPrice: totalReference,
            unit: 'lot',
          ),
        );
      }

      final signedBy = json['signed_by']?.toString();
      final signatureData = json['signature_data']?.toString();
      final validatedAtStr = json['date_livraison']?.toString();
      final validatedAt = (validatedAtStr != null && validatedAtStr.isNotEmpty)
          ? DateTime.tryParse(validatedAtStr)
          : null;

      final finalBlTotal = items.fold<double>(
        0.0,
        (sum, it) => sum + it.totalPrice,
      );
      final deliveryNote = DeliveryNote(
        number: 'BL-$codeBlStr',
        generatedAt: scheduledTime,
        validatedAt: validatedAt,
        clientName: (clientName != null && clientName.isNotEmpty)
            ? clientName
            : 'Client LDF',
        clientCode: client?['code_clt']?.toString() ?? 'N/A',
        clientAddress: fullAddress,
        agence: codeAgce,
        livreurName: chauffeurOrLivreur,
        vehiclePlate: vehiclePlate,
        items: items,
        totalAmount: finalBlTotal,
        totalWeight: 0.0,
        signatureUrl: signatureData,
        status: status == DeliveryStatus.delivered
            ? DeliveryNoteStatus.livre
            : (status == DeliveryStatus.cancelled
                  ? DeliveryNoteStatus.echec
                  : DeliveryNoteStatus.emis),
        orderNumber: codeComStr,
        compteContrib: compteContrib,
        montTva: montTva,
        montArsi: montArsi,
        signedBy: signedBy,
      );

      return DeliveryModel(
        // L'id technique est le code_ligne (attendu par valider-livraison)
        id: json['code_ligne']?.toString() ?? codeBlStr,
        tourId: json['code_tournee']?.toString() ?? 'N/A',
        clientCode: client?['code_clt']?.toString() ?? 'N/A',
        clientName: (clientName != null && clientName.isNotEmpty)
            ? clientName
            : 'Client LDF',
        deliveryNoteNumber: 'BL-$codeBlStr',
        weight: 0.0,
        amount: finalBlTotal,
        address: fullAddress,
        phone: client?['tel1_clt']?.toString() ?? '',
        status: status,
        scheduledTime: scheduledTime,
        notes: finalNotes,
        deliveryNote: deliveryNote,
        signedBy: signedBy,
        signatureData: signatureData,
      );
    }

    // Cas 2 : Format standard (fallback)
    return DeliveryModel(
      id: json['id'] as String,
      tourId: json['tour_id'] as String? ?? 'N/A',
      clientCode: json['client_code'] as String? ?? 'N/A',
      clientName: json['client_name'] as String,
      deliveryNoteNumber: json['delivery_note_number'] as String? ?? 'N/A',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String,
      phone: json['phone'] as String,
      status: _statusFromString(json['status'] as String),
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      notes: json['notes'] as String? ?? '',
      signedBy: json['signed_by'] as String?,
      signatureData: json['signature_data'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tour_id': tourId,
    'client_code': clientCode,
    'client_name': clientName,
    'delivery_note_number': deliveryNoteNumber,
    'weight': weight,
    'amount': amount,
    'address': address,
    'phone': phone,
    'status': _statusToString(status),
    'scheduled_time': scheduledTime.toIso8601String(),
    'notes': notes,
    'signed_by': signedBy,
    'signature_data': signatureData,
  };

  static DeliveryStatus _statusFromApiString(String? value) {
    switch (value) {
      case 'LIVREE':
        return DeliveryStatus.delivered;
      case 'EN_COURS':
        return DeliveryStatus.inProgress;
      case 'ECHEC':
      case 'ANNULEE':
      case 'REPORTEE':
      case 'REPORTE':
        return DeliveryStatus.cancelled;
      case 'EN_ATTENTE':
      default:
        return DeliveryStatus.pending;
    }
  }

  static DeliveryStatus _statusFromString(String value) {
    switch (value) {
      case 'in_progress':
        return DeliveryStatus.inProgress;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  static String _statusToString(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.inProgress:
        return 'in_progress';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
      case DeliveryStatus.pending:
        return 'pending';
    }
  }
}
