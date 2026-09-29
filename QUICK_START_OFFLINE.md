# ⚡ Quick Start - Architecture Offline

Guide ultra-rapide pour démarrer avec l'architecture offline.

## 🎯 En 3 Minutes

### 1. Installation (1 min)

```bash
# Installer les dépendances
flutter pub get

# Générer les fichiers nécessaires
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Vérification (30 sec)

```bash
# Lancer l'application
flutter run
```

Vérifiez dans la console :
```
✅ Hive initialisé avec succès
```

### 3. Premier Test (1 min 30)

1. **Mode Online** : Effectuer une action → ✅ Succès immédiat
2. **Mode Offline** : Activer mode avion → Effectuer une action → 🟠 Badge "Hors-ligne"
3. **Synchronisation** : Désactiver mode avion → ✅ Sync automatique

**C'est tout ! Vous êtes prêt !**

---

## 📝 Cheat Sheet

### Commandes Essentielles

```bash
# Génération après modification des modèles
flutter pub run build_runner build --delete-conflicting-outputs

# Mode watch (auto-génération)
flutter pub run build_runner watch

# Nettoyer et regénérer (en cas de problème)
flutter pub run build_runner clean && flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'app
flutter run

# Build release
flutter build apk --release
```

### Code Snippets

#### Utiliser OfflineAwareScaffold

```dart
import 'package:get_it/get_it.dart';
import 'package:ldfgroupeigescom_mobile/core/offline/offline.dart';

OfflineAwareScaffold(
  syncManager: GetIt.instance<OfflineSyncManager>(),
  appBar: AppBar(title: Text('Ma Page')),
  body: MyContent(),
)
```

#### Ajouter un Badge Offline

```dart
OfflineBadge(
  isSynced: delivery.isSynced,
  size: OfflineBadgeSize.small,
)
```

#### Action Offline dans un Cubit

```dart
@injectable
class MyCubit extends Cubit<MyState> {
  final OfflineSyncManager syncManager;
  
  MyCubit(this.syncManager) : super(MyInitial());
  
  Future<void> myAction() async {
    // 1. Sauvegarder localement
    await _saveLocally();
    
    // 2. Queue action
    await syncManager.queueAction(
      actionType: 'my_action',
      deliveryId: 'xxx',
      payload: {},
    );
    
    // 3. Émettre état
    final isOffline = await syncManager.isOffline();
    emit(MySuccess(isOffline: isOffline));
  }
}
```

#### Vérifier la Connectivité

```dart
final syncManager = GetIt.instance<OfflineSyncManager>();

// Vérifier si offline
final isOffline = await syncManager.isOffline();

// Écouter les changements
syncManager.connectivityStream.listen((isOnline) {
  print('Connectivité: ${isOnline ? 'Online' : 'Offline'}');
});

// Nombre d'actions en attente
final count = syncManager.getPendingSyncCount();
```

#### Forcer une Synchronisation

```dart
try {
  await syncManager.forceSyncNow();
  print('✅ Synchronisation réussie');
} catch (e) {
  print('❌ Erreur: $e');
}
```

---

## 🎨 Widgets Disponibles

| Widget | Usage | Exemple |
|--------|-------|---------|
| `OfflineAwareScaffold` | Scaffold intelligent | `OfflineAwareScaffold(syncManager: ...)` |
| `ConnectionStatusBar` | Barre d'état | `ConnectionStatusBar(isOnline: true, pendingSyncCount: 3)` |
| `OfflineBadge` | Badge "Hors-ligne" | `OfflineBadge(isSynced: false)` |
| `PendingSyncIndicator` | Compteur actions | `PendingSyncIndicator(count: 5)` |
| `PendingActionsList` | Liste détaillée | `PendingActionsList(actions: [...])` |

---

## 🗂️ Boxes Hive

| Box | Contenu | Accès |
|-----|---------|-------|
| `pending_actions_box` | Actions non sync | `Hive.box<PendingAction>(HiveBoxes.pendingActions)` |
| `deliveries_box` | Cache livraisons | `Hive.box<OfflineDelivery>(HiveBoxes.deliveries)` |
| `tours_box` | Cache tournées | `Hive.box<OfflineTour>(HiveBoxes.tours)` |
| `user_box` | Utilisateur | `Hive.box<OfflineUser>(HiveBoxes.user)` |
| `history_box` | Historique | `Hive.box<OfflineHistoryEntry>(HiveBoxes.history)` |

---

## 🔍 Débuggage Rapide

### Vérifier l'injection

```dart
import 'package:ldfgroupeigescom_mobile/core/offline/di/verify_injection_example.dart';

void main() async {
  // ...
  await verifyOfflineInjection();  // Affiche un rapport
  // ...
}
```

### Voir les actions en attente

```dart
final box = Hive.box<PendingAction>(HiveBoxes.pendingActions);
print('Actions en attente: ${box.length}');
for (final action in box.values) {
  print('  - ${action.actionType} (${action.retryCount} retries)');
}
```

### Nettoyer les données

```dart
await Hive.box<PendingAction>(HiveBoxes.pendingActions).clear();
await Hive.box<OfflineDelivery>(HiveBoxes.deliveries).clear();
// etc...
```

---

## ❌ Erreurs Courantes

### "No adapter found for..."

**Solution :**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Box has already been registered"

**Solution :** Vérifiez que `_initializeHive()` est appelé une seule fois dans `main.dart`.

### "Cannot write, unknown type"

**Solution :** Assurez-vous que l'adapter est enregistré dans `main.dart` :
```dart
Hive.registerAdapter(MyModelAdapter());
```

### Données non synchronisées

**Solution :** Vérifiez :
1. La connectivité (mode avion désactivé)
2. Les logs dans la console
3. Le nombre de retries (max 5)

---

## 📚 Documentation Complète

| Pour... | Lire... |
|---------|---------|
| Installation détaillée | [OFFLINE_SETUP.md](OFFLINE_SETUP.md) |
| Comprendre l'architecture | [ARCHITECTURE_OFFLINE.md](ARCHITECTURE_OFFLINE.md) |
| Migrer un écran | [MIGRATION_GUIDE_OFFLINE.md](MIGRATION_GUIDE_OFFLINE.md) |
| API du module | [lib/core/offline/README.md](lib/core/offline/README.md) |
| Vue d'ensemble | [README_OFFLINE.md](README_OFFLINE.md) |

---

## 🎯 Checklist Développeur

### Nouveau sur le projet ?

- [ ] Lire ce Quick Start
- [ ] Exécuter `flutter pub get`
- [ ] Générer les fichiers avec build_runner
- [ ] Lancer l'app et vérifier les logs
- [ ] Tester en mode offline

### Créer un nouvel écran ?

- [ ] Utiliser `OfflineAwareScaffold`
- [ ] Injecter `OfflineSyncManager` dans le Cubit
- [ ] Ajouter `OfflineBadge` sur les données
- [ ] Gérer le flag `isOffline`
- [ ] Tester offline

### Modifier un modèle Hive ?

- [ ] Modifier le modèle `.dart`
- [ ] Relancer `flutter pub run build_runner build`
- [ ] Vérifier que le `.g.dart` est généré
- [ ] Tester l'app

---

## 🚀 Pour Aller Plus Loin

1. **Comprendre le système** : [ARCHITECTURE_OFFLINE.md](ARCHITECTURE_OFFLINE.md)
2. **Migrer un écran** : [MIGRATION_GUIDE_OFFLINE.md](MIGRATION_GUIDE_OFFLINE.md)
3. **Explorer les exemples** : `lib/core/offline/examples/`

---

**Temps de lecture : 3 minutes • Temps de setup : 5 minutes • Temps de migration (écran simple) : 15 minutes**
