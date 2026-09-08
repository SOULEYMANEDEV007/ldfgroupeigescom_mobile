# 📱 IGESCOM Mobile - Architecture Offline

> Application de livraison offline-first pour les livreurs LDF Groupe

## 🎯 Vue d'Ensemble

Cette application permet aux livreurs de travailler **sans connexion réseau**. Toutes les actions (démarrage, validation, échec de livraison) sont enregistrées localement et synchronisées automatiquement dès que la connexion est rétablie.

## ✨ Fonctionnalités

- ✅ **Authentification offline** : Démarrage de l'app sans réseau
- ✅ **Cache local** : Tournées et livraisons disponibles hors-ligne
- ✅ **Actions offline** : Valider/Signaler échecs sans réseau
- ✅ **Synchronisation auto** : Retry automatique (5x) au retour du réseau
- ✅ **Indicateurs UI** : Badges, barres d'état, compteurs d'actions en attente
- ✅ **Résolution de conflits** : Merge automatique local/serveur

## 🚀 Démarrage Rapide

### 1. Installation

```bash
# Installer les dépendances
flutter pub get

# Générer les adapters Hive et injection DI
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'application
flutter run
```

### 2. Vérification

Dans la console, vous devriez voir :

```
✅ Hive initialisé avec succès
   - pending_actions_box: 0 entrées
   - deliveries_box: 0 entrées
   - tours_box: 0 entrées
   - user_box: 0 entrées
   - history_box: 0 entrées
```

### 3. Test Offline

1. Activer le mode avion sur votre appareil
2. Effectuer une action (démarrer/valider une livraison)
3. Observer le badge "Hors-ligne" 🟠
4. Désactiver le mode avion
5. Observer la synchronisation automatique ✅

## 📚 Documentation

| Document | Description | Pour qui ? |
|----------|-------------|------------|
| **[OFFLINE_SETUP.md](OFFLINE_SETUP.md)** | Guide d'installation et configuration | Développeurs (première fois) |
| **[ARCHITECTURE_OFFLINE.md](ARCHITECTURE_OFFLINE.md)** | Architecture technique complète | Architectes, Lead Dev |
| **[MIGRATION_GUIDE_OFFLINE.md](MIGRATION_GUIDE_OFFLINE.md)** | Migration des écrans existants | Développeurs (feature) |
| **[lib/core/offline/README.md](lib/core/offline/README.md)** | Documentation du module | Développeurs (utilisation) |
| **[lib/core/offline/di/README.md](lib/core/offline/di/README.md)** | Injection de dépendances | Développeurs (DI) |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                         │
│              (Cubit/Bloc - UI - Widgets)                │
│  ┌──────────────────────────────────────────────────┐   │
│  │ OfflineAwareScaffold                             │   │
│  │ ├─ ConnectionStatusBar                           │   │
│  │ ├─ OfflineBadge                                  │   │
│  │ └─ PendingSyncIndicator                          │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                  OFFLINE MANAGER                        │
│           (OfflineSyncManager - DI)                     │
│  ┌──────────────────────────────────────────────────┐   │
│  │ • Connectivity Listener                          │   │
│  │ • Queue Management                               │   │
│  │ • Auto Sync (retry 5x)                           │   │
│  │ • Conflict Resolution                            │   │
│  │ • Cache Strategy (cache-first)                   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│                   LOCAL STORAGE                         │
│                  (Hive - 5 Boxes)                       │
│  ┌──────────────────────────────────────────────────┐   │
│  │ • pending_actions_box    (Actions non sync)      │   │
│  │ • deliveries_box         (Cache livraisons)      │   │
│  │ • tours_box              (Cache tournées)        │   │
│  │ • user_box               (Utilisateur)           │   │
│  │ • history_box            (Historique)            │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 💻 Utilisation

### Dans un Écran

```dart
import 'package:ldfgroupeigescom_mobile/core/offline/offline.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final syncManager = GetIt.instance<OfflineSyncManager>();
    
    return OfflineAwareScaffold(
      syncManager: syncManager,
      appBar: AppBar(title: Text('Ma Page')),
      body: MyContent(),
    );
  }
}
```

### Dans un Cubit

```dart
@injectable
class MyCubit extends Cubit<MyState> {
  final OfflineSyncManager syncManager;
  
  MyCubit(this.syncManager) : super(MyInitial());
  
  Future<void> performAction() async {
    // 1. Sauvegarder localement
    await _saveLocally();
    
    // 2. Queue pour synchronisation
    await syncManager.queueAction(
      actionType: 'my_action',
      deliveryId: 'xxx',
      payload: {'data': '...'},
    );
    
    // 3. Émettre état avec indicateur offline
    final isOffline = await syncManager.isOffline();
    emit(MySuccess(isOffline: isOffline));
  }
}
```

### Afficher un Badge

```dart
OfflineBadge(
  isSynced: delivery.isSynced,
  size: OfflineBadgeSize.medium,
)
```

## 🔧 Commandes Utiles

```bash
# Générer les adapters Hive après modification des modèles
flutter pub run build_runner build --delete-conflicting-outputs

# Mode watch (auto-génération)
flutter pub run build_runner watch

# Nettoyer et regénérer
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer les tests
flutter test

# Build release
flutter build apk --release
```

## 📊 Fichiers Générés

Après `flutter pub run build_runner build`, vous devriez avoir :

```
lib/
├── core/
│   ├── di/
│   │   └── injection.config.dart           ✨ Généré
│   └── offline/
│       └── models/
│           ├── pending_action.g.dart       ✨ Généré
│           ├── offline_delivery.g.dart     ✨ Généré
│           ├── offline_tour.g.dart         ✨ Généré
│           ├── offline_user.g.dart         ✨ Généré
│           └── offline_history_entry.g.dart ✨ Généré
```

## 🧪 Tests

### Tests Manuels

```bash
# 1. Mode offline
flutter run
# → Activer mode avion
# → Effectuer actions
# → Vérifier badges

# 2. Synchronisation
# → Désactiver mode avion
# → Vérifier sync auto
# → Vérifier disparition badges

# 3. Persistance
# → Fermer app (offline)
# → Rouvrir app
# → Vérifier données présentes
```

### Tests Automatisés

```bash
flutter test
```

## 🐛 Dépannage

### Erreur : "No adapter found"

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erreur : "Box not found"

Vérifiez que `_initializeHive()` est appelé dans `main.dart` **avant** `configureDependencies()`.

### Données non synchronisées

Vérifiez la connectivité et les logs :

```dart
import 'package:ldfgroupeigescom_mobile/core/offline/di/verify_injection_example.dart';

void main() async {
  // ...
  await verifyOfflineInjection();
  // ...
}
```

## 📦 Structure du Projet

```
lib/
├── core/
│   └── offline/                    # Module offline
│       ├── constants/              # Constantes (HiveBoxes)
│       ├── models/                 # Modèles Hive (5 modèles)
│       ├── managers/               # OfflineSyncManager
│       ├── di/                     # Injection de dépendances
│       ├── widgets/                # Composants UI (5 widgets)
│       ├── examples/               # Exemples d'utilisation
│       └── offline.dart            # Export central
│
├── features/
│   └── delivery/
│       └── presentation/
│           └── bloc/
│               ├── delivery_cubit.dart    ✨ Modifié (offline-ready)
│               └── delivery_state.dart    ✨ Modifié (flag isOffline)
│
└── main.dart                       ✨ Modifié (init Hive)
```

## 🎓 Formation

### Pour Développeurs Junior

1. Lire [OFFLINE_SETUP.md](OFFLINE_SETUP.md)
2. Suivre les exemples dans `lib/core/offline/examples/`
3. Migrer un petit écran avec [MIGRATION_GUIDE_OFFLINE.md](MIGRATION_GUIDE_OFFLINE.md)

### Pour Développeurs Senior

1. Lire [ARCHITECTURE_OFFLINE.md](ARCHITECTURE_OFFLINE.md)
2. Comprendre `OfflineSyncManager` dans `lib/core/offline/managers/`
3. Adapter l'architecture aux besoins spécifiques

### Pour Architectes

1. Étudier le flux de données dans [ARCHITECTURE_OFFLINE.md](ARCHITECTURE_OFFLINE.md)
2. Analyser la stratégie de cache
3. Évaluer la résolution de conflits
4. Proposer des améliorations

## 🚀 Roadmap

### Phase 1 : Fondations ✅
- [x] Architecture offline de base
- [x] Modèles Hive
- [x] OfflineSyncManager
- [x] Composants UI
- [x] Documentation

### Phase 2 : Enrichissement (À venir)
- [ ] Gestion photos/signatures offline
- [ ] Compression automatique
- [ ] Chiffrement du token
- [ ] Export données debug

### Phase 3 : Optimisation (À venir)
- [ ] Analytics offline
- [ ] Performance monitoring
- [ ] Tests automatisés complets
- [ ] CI/CD integration

## 📞 Support

| Besoin | Ressource |
|--------|-----------|
| Installation | [OFFLINE_SETUP.md](OFFLINE_SETUP.md) |
| Architecture | [ARCHITECTURE_OFFLINE.md](ARCHITECTURE_OFFLINE.md) |
| Migration | [MIGRATION_GUIDE_OFFLINE.md](MIGRATION_GUIDE_OFFLINE.md) |
| API | [lib/core/offline/README.md](lib/core/offline/README.md) |
| Injection DI | [lib/core/offline/di/README.md](lib/core/offline/di/README.md) |

## 📄 Licence

© 2024 LDF Groupe - Tous droits réservés

## 👥 Contributeurs

- Architecture & Implémentation : Kiro AI Assistant
- Spécifications : Équipe LDF Groupe
- Tests : Équipe QA LDF Groupe

---

**Note** : Ce projet utilise une architecture offline-first pour garantir la continuité de service dans les zones à faible couverture réseau. Toutes les actions critiques sont sauvegardées localement et synchronisées automatiquement.

**Version** : 1.0.0  
**Dernière mise à jour** : 2024
