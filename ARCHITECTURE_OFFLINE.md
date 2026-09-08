# 🏗️ Architecture Offline - Documentation Complète

## 📊 Vue d'ensemble

Cette application implémente une **architecture offline-first** permettant aux livreurs de travailler sans connexion réseau. Toutes les actions sont enregistrées localement et synchronisées automatiquement dès que la connexion est rétablie.

## 🎯 Objectifs

| Objectif | Status | Description |
|----------|--------|-------------|
| ✅ Authentification offline | Implémenté | Token stocké localement, démarrage sans réseau |
| ✅ Chargement des données | Implémenté | Cache-first strategy pour tournées et livraisons |
| ✅ Actions offline | Implémenté | Valider/Signaler échec SANS réseau |
| ✅ Synchronisation différée | Implémenté | Queue d'actions avec retry automatique (5x) |
| ✅ Indicateurs UI | Implémenté | Badges, barres d'état, compteurs |
| 🔄 Gestion des conflits | Implémenté | Merge automatique (version la plus récente) |

## 📁 Structure du Code

```
lib/
├── core/
│   └── offline/
│       ├── constants/
│       │   └── hive_boxes.dart              # Noms des boxes Hive
│       ├── models/
│       │   ├── pending_action.dart          # Action en attente (typeId: 0)
│       │   ├── offline_delivery.dart        # Livraison cachée (typeId: 1)
│       │   ├── offline_tour.dart            # Tournée cachée (typeId: 2)
│       │   ├── offline_user.dart            # Utilisateur (typeId: 3)
│       │   ├── offline_history_entry.dart   # Historique (typeId: 4)
│       │   └── models.dart                  # Export central
│       ├── managers/
│       │   └── offline_sync_manager.dart    # Cœur du système offline
│       ├── di/
│       │   ├── offline_module.dart          # Module d'injection
│       │   ├── offline_injection_check.dart # Vérification DI
│       │   └── README.md                    # Doc injection
│       ├── widgets/
│       │   ├── connection_status_bar.dart   # Barre d'état offline
│       │   ├── offline_badge.dart           # Badge "Hors-ligne"
│       │   ├── pending_sync_indicator.dart  # Compteur actions
│       │   ├── pending_actions_list.dart    # Liste détaillée
│       │   ├── offline_aware_scaffold.dart  # Scaffold intelligent
│       │   └── widgets.dart                 # Export central
│       ├── examples/
│       │   ├── delivery_offline_example.dart
│       │   └── offline_ui_example.dart
│       ├── offline.dart                     # Export central du module
│       └── README.md                        # Documentation module
│
├── features/
│   └── delivery/
│       └── presentation/
│           └── bloc/
│               ├── delivery_cubit.dart      # ✨ Modifié pour offline
│               └── delivery_state.dart      # ✨ Ajout flag isOffline
│
└── main.dart                                # ✨ Init Hive + Adapters
```

## 🔄 Flux de Données

### 1. Action Online

```
Utilisateur → DeliveryCubit.startDelivery()
                    ↓
          Sauvegarde locale (Hive)
                    ↓
          Queue action (syncManager)
                    ↓
          Envoi immédiat API ✅
                    ↓
          Marquage synchronisé
                    ↓
          UI mise à jour (isOffline: false)
```

### 2. Action Offline

```
Utilisateur → DeliveryCubit.startDelivery()
                    ↓
          Sauvegarde locale (Hive)
                    ↓
          Queue action (syncManager)
                    ↓
          Envoi API ❌ (pas de réseau)
                    ↓
          Action reste en attente
                    ↓
          UI mise à jour (isOffline: true) 🟠
                    ↓
          [Badge "Hors-ligne" affiché]
```

### 3. Retour Réseau

```
Réseau rétabli 📶
        ↓
ConnectivityListener détecte
        ↓
OfflineSyncManager._syncPendingActions()
        ↓
Pour chaque action en attente:
  ├─ Envoi API
  ├─ Si succès: supprimer de la queue ✅
  └─ Si échec: retry++ (max 5)
        ↓
UI mise à jour (actions synchronisées)
```

## 🗄️ Stockage Local (Hive)

### Boxes Disponibles

| Box | Type | Contenu | Nettoyage |
|-----|------|---------|-----------|
| `pending_actions_box` | `PendingAction` | Actions non synchronisées | Auto après sync |
| `deliveries_box` | `OfflineDelivery` | Cache livraisons | Manuel (30j) |
| `tours_box` | `OfflineTour` | Cache tournées | Manuel (30j) |
| `user_box` | `OfflineUser` | Utilisateur connecté | À la déconnexion |
| `history_box` | `OfflineHistoryEntry` | Historique livraisons | Manuel (30j) |

### Stratégie de Cache

**Cache-First Strategy** :
1. Charger depuis Hive (instantané)
2. Si cache vide + réseau → charger API
3. Mettre en cache pour prochaine fois

## 💉 Injection de Dépendances

### Configuration

```dart
@module
abstract class OfflineModule {
  @lazySingleton
  @Named(HiveBoxes.pendingActions)
  Box<PendingAction> getPendingActionsBox();
  
  // ... autres boxes ...
  
  @lazySingleton
  Connectivity getConnectivity();
}

@lazySingleton
class OfflineSyncManager {
  OfflineSyncManager({
    required Dio dio,
    required Connectivity connectivity,
    @Named(HiveBoxes.pendingActions) required Box<PendingAction> pendingActionsBox,
    // ... autres dépendances ...
  });
}
```

### Utilisation

```dart
// Dans un Cubit
@injectable
class DeliveryCubit extends Cubit<DeliveryState> {
  final OfflineSyncManager syncManager;
  
  DeliveryCubit(this.syncManager) : super(DeliveryInitial());
}

// Dans un Widget
final syncManager = GetIt.instance<OfflineSyncManager>();
```

## 🎨 Composants UI

### 1. ConnectionStatusBar

Barre d'état en haut de l'écran :
- **Offline** : Message rouge "Mode hors-ligne"
- **Sync en cours** : Message orange avec nombre d'actions

```dart
ConnectionStatusBar(
  isOnline: true,
  pendingSyncCount: 3,
  onTap: () => showPendingActionsDialog(),
)
```

### 2. OfflineBadge

Badge sur les éléments non synchronisés :

```dart
OfflineBadge(
  isSynced: delivery.isSynced,
  size: OfflineBadgeSize.small,
)
```

### 3. OfflineAwareScaffold

Scaffold intelligent avec gestion auto :

```dart
OfflineAwareScaffold(
  syncManager: getIt<OfflineSyncManager>(),
  appBar: AppBar(title: Text('Ma Page')),
  body: MyContent(),
)
```

## 🔧 API OfflineSyncManager

### Méthodes Principales

```dart
// Enregistrer une action offline
await syncManager.queueAction(
  actionType: 'start_delivery',
  deliveryId: 'xxx',
  payload: {'timestamp': '...'},
);

// Récupérer les tournées (cache-first)
final tours = await syncManager.getTours(forceRefresh: false);

// Récupérer une livraison
final delivery = await syncManager.getDelivery(deliveryId);

// Vérifier la connectivité
final isOffline = await syncManager.isOffline();

// Forcer une synchronisation
await syncManager.forceSyncNow();

// Nettoyer le cache ancien
await syncManager.cleanupOldCache(daysToKeep: 30);

// Résoudre les conflits
await syncManager.resolveConflicts();
```

### Streams

```dart
// Écouter la connectivité
syncManager.connectivityStream.listen((isOnline) {
  print('Connectivité: ${isOnline ? 'Online' : 'Offline'}');
});

// Écouter les actions en attente
syncManager.pendingSyncCountStream.listen((count) {
  print('Actions en attente: $count');
});
```

## 📝 Utilisation dans DeliveryCubit

### Avant (Online uniquement)

```dart
Future<void> startDelivery(Delivery delivery) async {
  await _changeStatus(delivery, DeliveryStatus.inProgress);
}
```

### Après (Offline-ready)

```dart
Future<void> startDelivery(Delivery delivery) async {
  emit(DeliveryUpdating(delivery));
  
  try {
    // 1. Mettre à jour localement
    final updated = delivery.copyWith(status: DeliveryStatus.inProgress);
    await _saveLocalDelivery(updated);
    
    // 2. Queue pour sync
    await syncManager.queueAction(
      actionType: 'start_delivery',
      deliveryId: delivery.id,
      payload: {'timestamp': DateTime.now().toIso8601String()},
    );
    
    // 3. Émettre succès avec indicateur
    final isOffline = await syncManager.isOffline();
    emit(DeliveryUpdated(updated, isOffline: isOffline));
  } catch (e) {
    emit(DeliveryUpdateError(delivery, e.toString()));
  }
}
```

## 🧪 Tests

### Test Manuel

1. **Mode Offline** :
   - Activer mode avion
   - Effectuer des actions
   - Vérifier badges "Hors-ligne"
   - Redémarrer l'app
   - Vérifier persistance

2. **Synchronisation** :
   - Désactiver mode avion
   - Vérifier sync automatique
   - Vérifier disparition badges

3. **Conflits** :
   - Modifier offline
   - Modifier en parallèle sur le serveur
   - Vérifier résolution

### Test Automatisé

```dart
test('Action offline est mise en queue', () async {
  await syncManager.queueAction(
    actionType: 'start_delivery',
    deliveryId: 'test-123',
    payload: {},
  );
  
  expect(syncManager.getPendingSyncCount(), 1);
});
```

## 🚨 Gestion d'Erreurs

### Retry Automatique

- **Max tentatives** : 5
- **Comportement** : Exponential backoff
- **Après 5 échecs** : Action marquée comme échouée

### Conflits

**Stratégie** : Last-Write-Wins (LWW)
- Comparer `lastModifiedAt`
- Version la plus récente l'emporte
- Merge automatique

## 📊 Monitoring

### Logs Debug

```dart
debugPrint('✅ Hive initialisé avec succès');
debugPrint('   - pending_actions_box: 3 entrées');
```

### Vérification Injection

```dart
import 'package:ldfgroupeigescom_mobile/core/offline/di/verify_injection_example.dart';

void main() async {
  // ...
  if (kDebugMode) {
    await verifyOfflineInjection();
  }
  // ...
}
```

## 🔐 Sécurité

### Token Offline

- Stocké dans `OfflineUser`
- Vérifié à chaque démarrage
- Refresh automatique si expiré

### Données Sensibles

- Pas de données sensibles en clair dans Hive
- Token chiffré (à implémenter si nécessaire)
- Cleanup automatique des données

## 📈 Performance

### Optimisations

- **Lazy Loading** : Boxes ouvertes au démarrage
- **Batch Operations** : `Future.wait` pour sync multiple
- **Cache Strategy** : Cache-first pour latence minimale
- **Cleanup** : Auto-nettoyage données anciennes

### Limitations

- **Stockage mobile** : ~10 MB recommandé
- **Nombre d'actions** : Cleanup après sync
- **Photos** : Compression recommandée

## 🚀 Prochaines Étapes

- [ ] Gestion photos/signatures offline
- [ ] Chiffrement token
- [ ] Compression photos
- [ ] Analytics offline
- [ ] Export données debug

## 📚 Ressources

- [Guide d'installation](OFFLINE_SETUP.md)
- [Documentation Hive](https://docs.hivedb.dev/)
- [Documentation Injectable](https://pub.dev/packages/injectable)
- [Documentation module](lib/core/offline/README.md)
- [Documentation DI](lib/core/offline/di/README.md)

## 👥 Contact

Pour toute question concernant l'architecture offline, consultez :
1. Ce document
2. Les README dans `lib/core/offline/`
3. Les exemples dans `lib/core/offline/examples/`
