import '../../../delivery/data/models/delivery_model.dart';
import '../../domain/entities/tour_entity.dart';

class TourModel extends TourEntity {
  const TourModel({
    required super.id,
    required super.reference,
    super.libelle = '',
    required super.date,
    super.heureDepart = '',
    required super.agence,
    super.chauffeurName = '',
    required super.livreurName,
    required super.vehiclePlate,
    required super.status,
    required super.deliveries,
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    // 1. Référence & ID & Libellé
    final codeTournee = json['code_tournee']?.toString() ??
        json['reference']?.toString() ??
        json['id']?.toString() ??
        'TRN-N/A';
    final rawLibelle = json['libelle']?.toString().trim();
    final libelle = (rawLibelle != null && rawLibelle.isNotEmpty)
        ? rawLibelle
        : codeTournee;
    final heureDepart = json['heure_depart']?.toString().trim() ?? '';

    // 2. Date
    final dateStr = json['date_tournee']?.toString() ??
        json['created_at']?.toString() ??
        json['date']?.toString();
    final date = DateTime.tryParse(dateStr ?? '') ?? DateTime.now();

    // 3. Convoyeur & Chauffeur
    final convoyeur = json['convoyeur_info'] is Map<String, dynamic>
        ? json['convoyeur_info'] as Map<String, dynamic>
        : null;
    final chauffeur = json['chauffeur_info'] is Map<String, dynamic>
        ? json['chauffeur_info'] as Map<String, dynamic>
        : null;

    final chauffeurName = chauffeur?['nom_complet']?.toString().trim() ?? '';
    final livreurName = convoyeur?['nom_complet']?.toString() ??
        (chauffeurName.isNotEmpty
            ? chauffeurName
            : (json['livreurName']?.toString() ?? 'Livreur LDF'));

    // 4. Véhicule & Statut
    final vehiclePlate = json['code_vehicule']?.toString() ??
        json['vehiclePlate']?.toString() ??
        'N/A';

    final statutStr = json['statut']?.toString().toUpperCase() ??
        json['status']?.toString().toUpperCase();
    final status = _parseStatus(statutStr);

    // 5. Lignes de livraisons
    final rawLignes = json['lignes'] as List<dynamic>? ??
        json['deliveries'] as List<dynamic>? ??
        [];

    final deliveries = rawLignes.map((item) {
      final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      if (!map.containsKey('code_tournee') ||
          map['code_tournee'] == null ||
          map['code_tournee'].toString().isEmpty) {
        map['code_tournee'] = codeTournee;
      }
      return DeliveryModel.fromJson(map);
    }).toList();

    return TourModel(
      id: codeTournee,
      reference: codeTournee,
      libelle: libelle,
      date: date,
      heureDepart: heureDepart,
      agence: 'DEPOT GRANDS COMPTES',
      chauffeurName: chauffeurName,
      livreurName: livreurName,
      vehiclePlate: vehiclePlate,
      status: status,
      deliveries: deliveries,
    );
  }

  static TourStatus _parseStatus(String? status) {
    switch (status) {
      case 'EN_COURS':
      case 'IN_PROGRESS':
      case 'INPROGRESS':
        return TourStatus.inProgress;
      case 'TERMINEE':
      case 'CLOTUREE':
      case 'COMPLETED':
        return TourStatus.completed;
      case 'ANNULEE':
      case 'CANCELLED':
        return TourStatus.cancelled;
      case 'EN_ATTENTE':
      case 'PENDING':
      default:
        return TourStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
        'code_tournee': reference,
        'date_tournee': date.toIso8601String(),
        'statut': _statusToString(status),
        'code_vehicule': vehiclePlate,
        'lignes': deliveries
            .map((d) => (d is DeliveryModel) ? d.toJson() : null)
            .whereType<Map<String, dynamic>>()
            .toList(),
      };

  static String _statusToString(TourStatus status) {
    switch (status) {
      case TourStatus.inProgress:
        return 'EN_COURS';
      case TourStatus.completed:
        return 'TERMINEE';
      case TourStatus.cancelled:
        return 'ANNULEE';
      case TourStatus.pending:
        return 'EN_ATTENTE';
    }
  }
}
