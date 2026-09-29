# 🚀 Guide de Configuration Offline - IGESCOM Mobile

Ce guide vous accompagne dans la mise en place de l'architecture offline de l'application.

## 📋 Prérequis

- Flutter SDK installé
- Dart SDK installé
- Projet cloné et dépendances de base installées

## 🔧 Installation Étape par Étape

### 1. Installer les dépendances

Les dépendances ont déjà été ajoutées dans `pubspec.yaml`. Exécutez :

```bash
flutter pub get
```

### 2. Générer les adapters Hive

Les modèles Hive nécessitent des adapters générés automatiquement. Exécutez :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Cette commande va générer les fichiers suivants :
- `lib/core/offline/models/pending_action.g.dart`
- `lib/core/offline/models/offline_delivery.g.dart`
- `lib/core/offline/models/offline_tour.g.dart`
- `lib/core/offline/models/offline_user.g.dart`
- `lib/core/offline/models/offline_history_entry.g.dart`

**Note :** Si vous modifiez un modèle Hive, vous devez relancer cette commande.

### 3. Générer le fichier d'injection

L'injection de dépendances nécessite également une génération :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Cela générera `lib/core/di/injection.config.dart`.

### 4. Vérifier l'initialisation

Lancez l'application en mode debug et vérifiez les logs :

```bash
flutter run
```

Vous devriez voir dans la console :

```
✅ Hive initialisé avec succès
   - pending_actions_box: 0 entrées
   - deliveries_box: 0 entrées
   - tours_box: 0 entrées
   - user_box: 0 entrées
   - history_box: 0 entrées
```

## 📦 Structure des Fichiers Générés

```
lib/
├── core/
│   ├── offline/
│   │   ├── models/
│   │   │   ├── pending_action.dart
│   │   │   ├── pending_action.g.dart          ← Généré
│   │   │   ├── offline_delivery.dart
│   │   │   ├── offline_delivery.g.dart        ← Généré
│   │   │   ├── offline_tour.dart
│   │   │   ├── offline_tour.g.dart            ← Généré
│   │   │   ├── offline_user.dart
│   │   │   ├── offline_user.g.dart            ← Généré
│   │   │   ├── offline_history_entry.dart
│   │   │   └── offline_history_entry.g.dart   ← Généré
│   │   └── ...
│   └── di/
│       ├── injection.dart
│       └── injection.config.dart               ← Généré
```

## 🧪 Tester l'Architecture Offline

### Test 1 : Vérifier le stockage local

```dart
import 'package:hive/hive.dart';
import 'package:ldfgroupeigescom_mobile/core/offline/offline.dart';

void testHive() {
  final box = Hive.box<PendingAction>(HiveBoxes.pendingActions);
  print('Nombre d\'actions en attente: ${box.length}');
}
```

### Test 2 : Simuler une action offline

1. Lancez l'application
2. Activez le mode avion sur votre appareil/émulateur
3. Effectuez une action (démarrer/valider une livraison)
4. Vérifiez que le badge "Hors-ligne" apparaît
5. Désactivez le mode avion
6. Vérifiez que la synchronisation démarre automatiquement

### Test 3 : Vérifier la persistance

1. Effectuez des actions offline
2. Fermez complètement l'application
3. Relancez l'application (toujours offline)
4. Vérifiez que les actions sont toujours présentes

## 🔍 Commandes Utiles

### Regénérer les fichiers (en cas de modification)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Nettoyer et regénérer (en cas de problème)

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Mode watch (regénération automatique)

```bash
flutter pub run build_runner watch
```

## 🐛 Résolution de Problèmes

### Erreur : "No adapter found for..."

**Cause :** Les adapters n'ont pas été générés ou enregistrés.

**Solution :**
1. Vérifiez que les fichiers `.g.dart` existent
2. Relancez `flutter pub run build_runner build --delete-conflicting-outputs`
3. Vérifiez que tous les adapters sont enregistrés dans `main.dart`

### Erreur : "Box has already been registered"

**Cause :** Tentative d'ouvrir une box déjà ouverte.

**Solution :** Utilisez `Hive.box<T>()` au lieu de `Hive.openBox<T>()` après la première ouverture.

### Erreur : "HiveError: Cannot write, unknown type"

**Cause :** Tentative d'écrire un objet sans adapter.

**Solution :** Assurez-vous que tous les types personnalisés ont un adapter Hive enregistré.

### Les données persistent entre les sessions

**Normal :** C'est le comportement attendu. Pour réinitialiser :

```dart
await Hive.box<PendingAction>(HiveBoxes.pendingActions).clear();
await Hive.box<OfflineDelivery>(HiveBoxes.deliveries).clear();
// etc...
```

## 📊 Monitoring

### Vérifier l'état des boxes

```dart
import 'package:get_it/get_it.dart';
import 'package:ldfgroupeigescom_mobile/core/offline/offline.dart';

void checkOfflineStatus() {
  final syncManager = GetIt.instance<OfflineSyncManager>();
  
  print('Nombre d\'actions en attente: ${syncManager.getPendingSyncCount()}');
  print('Mode offline: ${await syncManager.isOffline()}');
}
```

### Logs de synchronisation

Activez les logs détaillés dans `OfflineSyncManager` pour voir les synchronisations :

```dart
// Les logs sont déjà présents dans le code avec debugPrint
```

## 🎯 Prochaines Étapes

1. ✅ Installation et génération des fichiers
2. ✅ Test de l'architecture offline
3. ⏭️ Intégration dans les écrans existants
4. ⏭️ Ajout de gestion des photos/signatures offline
5. ⏭️ Tests en conditions réelles (terrain)

## 📚 Ressources

- [Documentation Hive](https://docs.hivedb.dev/)
- [Guide Offline-First Flutter](https://flutter.dev/docs/cookbook/persistence)
- [Build Runner](https://pub.dev/packages/build_runner)

## 🆘 Support

En cas de problème, vérifiez :
1. Les logs de la console Flutter
2. Les fichiers générés dans `*.g.dart`
3. L'enregistrement des adapters dans `main.dart`
4. La documentation interne dans `lib/core/offline/README.md`
