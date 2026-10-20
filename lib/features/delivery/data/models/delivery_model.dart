import '../../domain/entities/delivery.dart';

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

      // ── Date et heure réelles de livraison en priorité ──
      final rawDateLivraison = json['date_livraison']?.toString().trim();
      final hasRealDate =
          rawDateLivraison != null &&
          rawDateLivraison.isNotEmpty &&
          rawDateLivraison != 'null';

      final dateStr = hasRealDate
          ? rawDateLivraison
          : (livraison?['date_livr']?.toString() ??
                json['created_at']?.toString());

      final scheduledTime =
          (dateStr != null ? DateTime.tryParse(dateStr)?.toLocal() : null) ??
          DateTime.now();

      final montArsi = (livraison?['mont_arsi_bl'] as num?)?.toDouble() ?? 0.0;
      final montTva = (livraison?['mont_tva_bl'] as num?)?.toDouble() ?? 0.0;
      final amount = montArsi > 0 ? montArsi : montTva;

      final note = json['observation_livraison']?.toString().trim();
      final commentBl = livraison?['comment_bl']?.toString().trim();
      final finalNotes = (note != null && note.isNotEmpty)
          ? note
          : (commentBl ?? '');

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
        amount: amount,
        address: fullAddress,
        phone: client?['tel1_clt']?.toString() ?? '',
        status: status,
        scheduledTime: scheduledTime,
        notes: finalNotes,
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
  };

  static DeliveryStatus _statusFromApiString(String? value) {
    switch (value) {
      case 'LIVREE':
        return DeliveryStatus.delivered;
      case 'EN_COURS':
        return DeliveryStatus.inProgress;
      case 'ECHEC':
      case 'ANNULEE':
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
