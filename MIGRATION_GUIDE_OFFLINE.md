# 🔄 Guide de Migration Offline

Ce guide vous aide à migrer vos écrans existants pour supporter l'architecture offline.

## 📋 Checklist de Migration

### Pour un nouvel écran

- [ ] Utiliser `OfflineAwareScaffold` au lieu de `Scaffold`
- [ ] Injecter `OfflineSyncManager` dans le Cubit/Bloc
- [ ] Ajouter `OfflineBadge` sur les éléments non synchronisés
- [ ] Gérer le flag `isOffline` dans les states
- [ ] Tester en mode offline

### Pour un écran existant

- [ ] Lire le code existant
- [ ] Identifier les actions réseau
- [ ] Modifier le Cubit pour utiliser `syncManager`
- [ ] Mettre à jour l'UI avec les indicateurs
- [ ] Tester la migration

## 🎯 Scénarios de Migration

### Scénario 1 : Écran Simple (Lecture uniquement)

**Avant :**
```dart
class TourListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tournées')),
      body: BlocBuilder<TourCubit, TourState>(
        builder: (context, state) {
          if (state is TourLoaded) {
            return ListView.builder(
              itemCount: state.tours.length,
              itemBuilder: (context, index) {
                return TourCard(tour: state.tours[index]);
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

**Après :**
```dart
class TourListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final syncManager = GetIt.instance<OfflineSyncManager>();
    
    return OfflineAwareScaffold(  // ← Changement 1
      syncManager: syncManager,
      appBar: AppBar(title: Text('Tournées')),
      body: BlocBuilder<TourCubit, TourState>(
        builder: (context, state) {
          if (state is TourLoaded) {
            return ListView.builder(
              itemCount: state.tours.length,
              itemBuilder: (context, index) {
                return TourCard(tour: state.tours[index]);
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

**Modifications :**
1. Remplacer `Scaffold` par `OfflineAwareScaffold`
2. Injecter `syncManager`
3. C'est tout ! La barre de statut apparaît automatiquement

---

### Scénario 2 : Écran avec Actions (Écriture)

**Avant :**
```dart
@injectable
class DeliveryCubit extends Cubit<DeliveryState> {
  final UpdateDeliveryStatusUseCase updateStatusUseCase;

  DeliveryCubit(this.updateStatusUseCase) : super(DeliveryInitial());

  Future<void> validateDelivery(Delivery delivery) async {
    emit(DeliveryUpdating(delivery));
    final result = await updateStatusUseCase(delivery.id, DeliveryStatus.delivered);
    result.fold(
      (error) => emit(DeliveryUpdateError(delivery, error)),
      (updated) => emit(DeliveryUpdated(updated)),
    );
  }
}
```

**Après :**
```dart
@injectable
class DeliveryCubit extends Cubit<DeliveryState> {
  final UpdateDeliveryStatusUseCase updateStatusUseCase;
  final OfflineSyncManager syncManager;  // ← Changement 1

  DeliveryCubit(
    this.updateStatusUseCase,
    this.syncManager,  // ← Changement 2
  ) : super(DeliveryInitial());

  Future<void> validateDelivery(
    Delivery delivery, {
    String? notes,  // ← Changement 3 (paramètres optionnels)
  }) async {
    emit(DeliveryUpdating(delivery));
    
    try {
      // 1. Mettre à jour localement
      final updated = delivery.copyWith(status: DeliveryStatus.delivered);
      await _saveLocalDelivery(updated);  // ← Changement 4
      
      // 2. Queue pour sync
      await syncManager.queueAction(  // ← Changement 5
        actionType: 'validate_delivery',
        deliveryId: delivery.id,
        payload: {
          'validated_at': DateTime.now().toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );
      
      // 3. Émettre succès avec indicateur offline
      final isOffline = await syncManager.isOffline();
      emit(DeliveryUpdated(updated, isOffline: isOffline));  // ← Changement 6
    } catch (e) {
      emit(DeliveryUpdateError(delivery, e.toString()));
    }
  }
  
  // ← Changement 7 : Nouvelle méthode
  Future<void> _saveLocalDelivery(Delivery delivery) async {
    final box = Hive.box<OfflineDelivery>(HiveBoxes.deliveries);
    final offline = OfflineDelivery.fromEntity(delivery);
    offline.markAsModified();
    await box.put(delivery.id, offline);
  }
}
```

**Modifications :**
1. Ajouter `OfflineSyncManager` en dépendance
2. Injecter dans le constructeur
3. Ajouter paramètres optionnels si nécessaire
4. Sauvegarder localement d'abord
5. Utiliser `queueAction` au lieu d'appel API direct
6. Ajouter flag `isOffline` dans le state
7. Créer méthode de sauvegarde locale

**State à modifier :**
```dart
// Avant
class DeliveryUpdated extends DeliveryState {
  final Delivery delivery;
  const DeliveryUpdated(this.delivery);
}

// Après
class DeliveryUpdated extends DeliveryState {
  final Delivery delivery;
  final bool isOffline;  // ← Nouveau
  
  const DeliveryUpdated(this.delivery, {this.isOffline = false});
  
  @override
  List<Object?> get props => [delivery, isOffline];  // ← Modifier
}
```

---

### Scénario 3 : Affichage des Badges

**Avant :**
```dart
class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(delivery.clientName),
        subtitle: Text(delivery.address),
        trailing: Icon(_getStatusIcon(delivery.status)),
      ),
    );
  }
}
```

**Après :**
```dart
class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Row(  // ← Changement 1
          children: [
            Expanded(child: Text(delivery.clientName)),
            FutureBuilder<bool>(  // ← Changement 2
              future: _isDeliverySynced(delivery.id),
              builder: (context, snapshot) {
                return OfflineBadge(
                  isSynced: snapshot.data ?? true,
                  size: OfflineBadgeSize.small,
                );
              },
            ),
          ],
        ),
        subtitle: Text(delivery.address),
        trailing: Icon(_getStatusIcon(delivery.status)),
      ),
    );
  }
  
  // ← Changement 3 : Nouvelle méthode
  Future<bool> _isDeliverySynced(String deliveryId) async {
    final box = Hive.box<OfflineDelivery>(HiveBoxes.deliveries);
    final offline = box.get(deliveryId);
    return offline?.isSynced ?? true;
  }
}
```

**Modifications :**
1. Encapsuler le titre dans un `Row`
2. Ajouter `OfflineBadge` avec `FutureBuilder`
3. Créer méthode pour vérifier synchronisation

---

### Scénario 4 : Feedback Utilisateur

**Avant :**
```dart
BlocListener<DeliveryCubit, DeliveryState>(
  listener: (context, state) {
    if (state is DeliveryUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Livraison validée')),
      );
    }
  },
  child: // ...
)
```

**Après :**
```dart
BlocListener<DeliveryCubit, DeliveryState>(
  listener: (context, state) {
    if (state is DeliveryUpdated) {
      final message = state.isOffline  // ← Changement 1
          ? '✅ Livraison validée (synchronisation en attente)'
          : '✅ Livraison validée';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: state.isOffline  // ← Changement 2
              ? Colors.orange
              : Colors.green,
        ),
      );
    }
  },
  child: // ...
)
```

**Modifications :**
1. Adapter le message selon `isOffline`
2. Changer la couleur pour indiquer le mode

---

## 🛠️ Outils de Migration

### Vérificateur de Migration

Créez ce fichier pour vérifier la migration :

```dart
// lib/core/offline/migration_checker.dart
class MigrationChecker {
  static Future<void> checkScreen(String screenName) async {
    print('🔍 Vérification de la migration: $screenName');
    
    // Vérifier que OfflineSyncManager est injecté
    try {
      GetIt.instance<OfflineSyncManager>();
      print('  ✅ OfflineSyncManager disponible');
    } catch (e) {
      print('  ❌ OfflineSyncManager NON disponible');
    }
    
    // Vérifier que les boxes sont ouvertes
    try {
      Hive.box<OfflineDelivery>(HiveBoxes.deliveries);
      print('  ✅ Boxes Hive ouvertes');
    } catch (e) {
      print('  ❌ Boxes Hive NON ouvertes');
    }
  }
}
```

### Script de Migration Automatique

Pour les projets avec beaucoup d'écrans :

```bash
# find_scaffolds.sh
grep -r "Scaffold(" lib/features/ --include="*.dart"
```

## ⚠️ Pièges Courants

### 1. Oublier de sauvegarder localement

❌ **Incorrect :**
```dart
await syncManager.queueAction(...);
// Pas de sauvegarde locale !
```

✅ **Correct :**
```dart
await _saveLocalDelivery(updated);
await syncManager.queueAction(...);
```

### 2. Ne pas gérer le flag isOffline

❌ **Incorrect :**
```dart
emit(DeliveryUpdated(updated));
// Pas d'indicateur !
```

✅ **Correct :**
```dart
final isOffline = await syncManager.isOffline();
emit(DeliveryUpdated(updated, isOffline: isOffline));
```

### 3. Oublier les badges UI

❌ **Incorrect :**
```dart
// Rien n'indique que la donnée n'est pas synchronisée
ListTile(title: Text(delivery.clientName))
```

✅ **Correct :**
```dart
ListTile(
  title: Row(
    children: [
      Text(delivery.clientName),
      OfflineBadge(isSynced: delivery.isSynced),
    ],
  ),
)
```

## 📊 Checklist Finale

Avant de considérer la migration terminée :

- [ ] `OfflineAwareScaffold` utilisé
- [ ] `OfflineSyncManager` injecté dans le Cubit
- [ ] Actions sauvegardées localement avec `_saveLocalDelivery`
- [ ] `queueAction` utilisé au lieu d'appel API direct
- [ ] Flag `isOffline` géré dans les states
- [ ] `OfflineBadge` affiché sur les données non synchronisées
- [ ] Feedback utilisateur adapté (messages, couleurs)
- [ ] Tests en mode offline effectués
- [ ] Tests de synchronisation effectués
- [ ] Documentation mise à jour

## 🧪 Tests de Migration

Après migration, tester ces scénarios :

1. **Mode Online** :
   - [ ] Actions s'exécutent normalement
   - [ ] Aucun badge "Hors-ligne"
   - [ ] Messages de succès verts

2. **Mode Offline** :
   - [ ] Actions s'enregistrent localement
   - [ ] Badges "Hors-ligne" affichés
   - [ ] Messages orange avec mention "synchronisation en attente"

3. **Retour Réseau** :
   - [ ] Synchronisation automatique
   - [ ] Badges disparaissent après sync
   - [ ] Aucune perte de données

4. **Persistance** :
   - [ ] Fermer et rouvrir l'app offline
   - [ ] Les actions sont toujours là
   - [ ] Sync démarre au retour du réseau

## 📚 Ressources

- [Architecture Offline](ARCHITECTURE_OFFLINE.md)
- [Guide d'installation](OFFLINE_SETUP.md)
- [Documentation du module](lib/core/offline/README.md)
- [Exemples](lib/core/offline/examples/)

## 🆘 Aide

En cas de problème pendant la migration :

1. Vérifier les logs de la console
2. Utiliser `OfflineInjectionCheck` pour vérifier l'injection
3. Consulter les exemples dans `lib/core/offline/examples/`
4. Vérifier que build_runner a bien généré les fichiers `.g.dart`
