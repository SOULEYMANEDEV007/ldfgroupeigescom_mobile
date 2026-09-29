import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

/// Service de géolocalisation utilisant Geolocator (Google Location API)
///
/// Fournit :
/// - Vérification et demande des permissions de localisation
/// - Récupération de la position actuelle
/// - Stream de position en temps réel
@lazySingleton
class LocationService {
  /// Vérifie et demande les permissions de localisation si nécessaire
  ///
  /// Retourne `true` si les permissions sont accordées, `false` sinon
  Future<bool> checkAndRequestPermissions() async {
    // Vérifier si le service de localisation est activé
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Le service de localisation est désactivé
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission refusée
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permission refusée de façon permanente
      return false;
    }

    // Permission accordée
    return true;
  }

  /// Récupère la position actuelle de l'appareil
  ///
  /// Lève une exception si les permissions ne sont pas accordées
  Future<Position> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermissions();
    
    if (!hasPermission) {
      throw LocationPermissionException(
        'Les permissions de localisation ne sont pas accordées',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Récupère la position actuelle avec une précision réduite (économie de batterie)
  Future<Position> getCurrentPositionLowAccuracy() async {
    final hasPermission = await checkAndRequestPermissions();
    
    if (!hasPermission) {
      throw LocationPermissionException(
        'Les permissions de localisation ne sont pas accordées',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  /// Stream de positions en temps réel
  ///
  /// Utile pour le suivi en temps réel pendant une livraison
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // Mise à jour tous les 10 mètres
  }) {
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calcule la distance en mètres entre deux positions
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Vérifie si l'appareil est à proximité d'une destination (rayon en mètres)
  Future<bool> isNearDestination({
    required double destinationLat,
    required double destinationLng,
    double radiusMeters = 100, // 100 mètres par défaut
  }) async {
    try {
      final position = await getCurrentPosition();
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        destinationLat,
        destinationLng,
      );

      return distance <= radiusMeters;
    } catch (e) {
      return false;
    }
  }

  /// Ouvre les paramètres de localisation de l'appareil
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Ouvre les paramètres d'application pour modifier les permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

/// Exception levée quand les permissions de localisation ne sont pas accordées
class LocationPermissionException implements Exception {
  final String message;
  
  LocationPermissionException(this.message);

  @override
  String toString() => 'LocationPermissionException: $message';
}
