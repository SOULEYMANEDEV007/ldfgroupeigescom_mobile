# LdF Igescom Mobile — Guide & Mémoire Permanente du Projet (LDF Groupe)

> **🤖 NOTE À L'ATTENTION DE L'ASSISTANT IA (ANTIGRAVITY / GEMINI)** :  
> Ce fichier est la **source de vérité absolue** et la mémoire permanente du projet **LdF Igescom Mobile**. Lis attentivement l'intégralité de ce document au début de chaque session ou conversation. Il contient le contexte métier, l'architecture complète, les conventions de code, les décisions techniques passées, les erreurs corrigées et l'historique des échanges. Met à jour ce document à la fin de chaque session de travail importante pour garantir une continuité parfaite sans aucune perte de contexte.

---

## 0. 🤝 Règle d'Or & Méthode de Travail Obligatoire (Posture Assistant)

> **⚠️ RÈGLE ABSOLUE & NON NÉGOCIABLE** :  
> L'IA intervient strictement comme **ASSISTANT TECHNIQUE** aux côtés du **DÉVELOPPEUR (le seul maître d'œuvre et décideur)**.  
> **NE JAMAIS COMMENCER À MODIFIER DU CODE DIRECTEMENT DÈS LA RÉCEPTION D'UNE REQUÊTE.**

### Le Workflow Strict en 4 Étapes à respecter pour chaque tâche :
1. **🔍 Analyse préalable** : Diagnostiquer le problème, identifier les causes racines et explorer les options possibles.
2. **📋 Proposition d'un Plan clair et lisible** : Présenter au développeur un plan d'action structuré détaillant précisément les fichiers concernés, les choix de conception/UI et les étapes envisagées.
3. **⏸️ Attente de Validation du Développeur** : Demander son avis et attendre son retour ou sa validation explicite ("Go", ajustements, remarques) avant toute action.
4. **🛠️ Exécution & Restitution** : Appliquer les modifications validées avec rigueur et les documenter.

---

## 1. 📌 Présentation & Vision Métier

- **Nom de l'application** : **LdF Igescom Mobile** (`ldfgroupeigescom_mobile`).
- **Organisation & Maître d'ouvrage** : **LDF Groupe** (Librairie de France Groupe — Côte d'Ivoire).
- **Public cible** : Livreurs, chauffeurs-livreurs et équipes logistiques d'IGESCOM (Gestion Commerciale et Distribution).
- **Mission clé** :
  - Digitaliser les tournées de livraison et les bordereaux de livraison (BL).
  - Fournir aux livreurs une vue claire de leurs missions quotidiennes (carte interactive, guidage GPS, coordonnées clients).
  - Valider les livraisons en temps réel avec signature électronique, preuves et synchronisation.
  - Traiter les cas d'anomalies ou d'échecs (absence client, adresse erronée, refus) avec motifs précis.
  - Offrir un suivi des KPI quotidiens (courses assignées, livrées, en attente, échecs).

---

## 2. 🧱 Architecture Technique (Feature-First Clean Architecture)

Le projet adopte strictement le pattern **Feature-First + Clean Architecture**, garantissant une modularité totale et une évolutivité sans friction :

```
lib/
├── core/                               # Briques transversales partagées
│   ├── constants/                      # Couleurs (AppColors), Gradients, Icônes (Lucide)
│   ├── di/                             # Injection de dépendances (GetIt + Injectable)
│   ├── network/                        # Client HTTP Dio, Intercepteurs JWT, Endpoints API
│   ├── routing/                        # GoRouter (AppRouter) + ShellRoute BottomBar
│   ├── services/                       # Services natifs (LocationService - GPS)
│   ├── theme/                          # AppTheme (Material 3, GoogleFonts Inter/Poppins)
│   └── utils/                          # AppDialogs, AppFeedback (Toasts, Modales)
│
├── features/                           # Fonctionnalités métier indépendantes (Feature-First)
│   ├── auth/                           # Authentification (Login, Splash, Token)
│   ├── dashboard/                      # Tableau de bord livreur (KPI, actions rapides)
│   ├── delivery/                       # Gestion des livraisons (Détails, Validation, BL, Échec)
│   ├── history/                        # Historique des courses & filtres
│   ├── notifications/                  # Centre des alertes et notifications push/in-app
│   ├── profile/                        # Informations du livreur & statut
│   ├── settings/                       # Paramètres application, diagnostic, cache
│   └── tour/                           # Tournées de livraison (Liste TRN, progression)
│
└── main.dart                           # Initialisation app, injection GetIt, locale fr_FR
```

### Les 3 couches internes de chaque Feature :
1. **`domain/`** (Indépendant de tout framework) :
   - `entities/` : Objets purs avec `Equatable` (ex: `Delivery`, `TourEntity`, `HistoryEntry`).
   - `repositories/` : Contrats abstraits d'accès aux données.
   - `usecases/` : Règles métiers unitaires retournant un `Either<Failure, Type>` (`dartz`).
2. **`data/`** (Gestion des données) :
   - `models/` : DTOs avec sérialisation JSON (`fromJson` / `toJson`).
   - `datasources/` : Sources distantes (`DioClient`) ou locales/mock (`MockDatasource`).
   - `repositories/` : Implémentations concrètes des contrats du domaine.
3. **`presentation/`** (Interface utilisateur & State Management) :
   - `bloc/` ou `cubit/` : Gestion d'état prédictible avec `flutter_bloc`.
   - `screens/` : Écrans complets déclarés dans `AppRouter`.
   - `widgets/` : Composants réutilisables isolés avec `RepaintBoundary` pour la fluidité.

---

## 3. 🎨 Design System & Charte Graphique LDF Groupe

Toutes les couleurs et tokens d'interface doivent impérativement provenir de [`AppColors`](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/constants/app_colors.dart) :

| Catégorie | Couleur | Code Hexa / Référence | Usage |
| :--- | :--- | :--- | :--- |
| **Verts LdF** | `primaryDark` | `#005C26` | Headers sombres, gradients |
| | `primary` | `#007A33` | **Vert officiel LdF**, boutons principaux, branding |
| | `primaryLight` | `#33955C` | Indicateurs secondaires, icônes actives |
| | `primarySoft` | `#E8F5EE` | Badges et fonds doux de succès |
| **Jaunes LdF**| `navBarYellow` | `#FFD600` | **Jaune Bottom Navigation Bar**, accents forts |
| | `secondary` | `#FFC107` | Alertes légères, étoiles |
| | `secondarySoft`| `#FFFBEB` | Fonds de carte warning |
| **Sémantique**| `accentBlue` | `#2F80ED` | Total du jour, stat info |
| | `success` | `#10B981` | Livraisons réussies / statut validé |
| | `warning` | `#F59E0B` | Livraisons en attente |
| | `error` | `#EF4444` | Échecs de livraison, alertes bloquantes |
| **Surfaces** | `background` | `#F4F6F8` | Fond global d'écran (gris doux moderne) |
| | `surface` | `#FFFFFF` | Cartes, modales, containers |

### Règles UI Standardisées :
- **AppBars** : Padding horizontal unifié à **`16px`** (`EdgeInsets.fromLTRB(16, 12, 16, 20)`).
- **Cartes de Tournée / Livraison** : Barre latérale gauche colorée (4px) indiquant le statut (Vert = Livré, Bleu = En cours, Orange = En attente).
- **RepaintBoundary** : Obligatoire sur les cartes des ListView pour éviter les frames sautées et garantir 60 FPS sur mobile.

---

## 4. ⚙️ Dépendances Clés & Décisions Techniques Majeures

1. **State Management** : `flutter_bloc: ^9.1.1` (Cubits utilisés pour la clarté et concision).
2. **Navigation** : `go_router: ^18.0.0` avec `AppRouter`. Les paramètres complexes sont passés via `state.extra`.
3. **Injection de Dépendances** : `get_it: ^9.2.1` + `injectable: ^3.0.0`.
   - ⚠️ **Règle critique** : `HistoryRepository` et `HistoryMockDatasource` sont enregistrés manuellement dans `lib/core/di/injection.dart` pour éviter les défaillances de `build_runner`.
4. **Géolocalisation & Carte** :
   - `geolocator: ^10.1.0` avec `LocationService` (singleton).
   - `flutter_map: ^8.3.2` + `latlong2: ^0.10.1`.
   - Coordonnées par défaut de repli : Abidjan (`5.3364, -4.0267`).
5. **Suppression de Hive** :
   - Hive a été **définitivement supprimé** en raison d'incompatibilités majeures de dépendances avec les versions récentes de Flutter/Dart. Ne pas réintroduire Hive sans validation préalable.
6. **Robustesse Asynchrone** :
   - Dans les Cubits effectuant des appels asynchrones (ex: `DashboardCubit`), toujours vérifier `if (isClosed) return;` avant d'émettre (`emit()`).

---

## 5. 🛠️ Commandes Fréquentes de Développement

```powershell
# 1. Nettoyer le cache Flutter
flutter clean

# 2. Récupérer les paquets
flutter pub get

# 3. Régénérer le code d'injection (si nouvelles annotations @injectable)
dart run build_runner build --delete-conflicting-outputs

# 4. Analyser le code (doit rester à 0 erreur)
flutter analyze

# 5. Lancer l'application
flutter run
```

---

## 6. 📜 Journal de Bord & Historique des Échanges (Conversation Log)

*Ce journal doit être incrémenté lors de chaque intervention pour maintenir l'historique permanent.*

### Session du 21/09/2026 — Initialisation de la Mémoire Permanente & Prise en Main du Projet
- **Objectif de l'utilisateur** : Prise de connaissance complète du projet Flutter `igescom_mobile` et mise en place d'un mécanisme infaillible pour ne plus jamais perdre l'historique et le contexte des conversations futures.
- **Actions réalisées** :
  1. Exploration approfondie du projet (structure `lib/`, `pubspec.yaml`, `core/`, `features/`, corrections runtime passées).
  2. Identification des patterns architecturaux (Feature-First Clean Architecture, BLoC/Cubit, GetIt, GoRouter, LocationService).
  3. Création du fichier maître `AGENTS.md` à la racine pour assurer la persistance contextuelle dans Antigravity IDE.
  4. Création de la règle workspace `.agents/rules/project_memory.md` pour forcer le chargement de cette mémoire à chaque démarrage d'agent.
- **Statut du projet** : Code propre, structure en place, branche `main`.
- **Prochaine étape attendue** : Selon les directives du développeur (fonctionnalité livraison, synchronisation API backend, ou enrichissement UI).

### Session du 23/09/2026 — Nettoyage de l'Analyse Statique (0 Issue)
- **Objectif de l'utilisateur** : Diagnostic de l'avertissement Windows Symlinks lors du `pub get` et résolution des issues remontées par `flutter analyze`.
- **Actions réalisées** :
  1. Explication claire du mécanisme de sécurité Windows sur les symlinks et le rôle du Mode Développeur.
  2. Remplacement des 8 occurrences dépréciées de `.withOpacity()` par `.withValues(alpha: ...)` dans [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) et [tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart).
  3. Suppression de la variable locale inutilisée `isPending` dans [tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart).
  4. Validation avec `flutter analyze` : **No issues found!** (0 erreur, 0 warning, 0 info).
- **Statut du projet** : Base de code saine et 100% conforme aux standards Dart/Flutter modernes.

### Session du 29/09/2026 — Résolution de l'Erreur de Build CMake / JNI (`:jni:configureCMakeDebug`)
- **Objectif de l'utilisateur** : Corriger l'échec de build Android sur Infinix X6525D provoqué par l'erreur `Execution failed for task ':jni:configureCMakeDebug[arm64-v8a]'` cherchant un `android.toolchain.cmake` introuvable dans le dossier NDK.
- **Diagnostic** :
  1. Le package transitif `path_provider_android: 2.3.1` (tiré via `google_fonts` / `shared_preferences`) a introduit une dépendance native vers `jni` et `jni_flutter`, imposant une compilation C++ via CMake et le NDK.
  2. Sur la machine hôte, les répertoires NDK `28.2.13676358` et `30.0.16248370` étaient des coquilles vides (sans fichier `android.toolchain.cmake`), provoquant l'échec immédiat de CMake.
- **Actions réalisées** :
  1. Ajout de `dependency_overrides` dans [pubspec.yaml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/pubspec.yaml) pour verrouiller `path_provider_android: 2.2.23` (dernière version 100% Java/Kotlin, supprimant `jni`, `jni_flutter` et tout besoin de compilation C++).
  2. Suppression de la directive `ndkVersion` superflue dans [android/app/build.gradle.kts](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/app/build.gradle.kts).
  3. Ajout des dépôts officiels et miroirs de Flutter dans [android/build.gradle.kts](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/build.gradle.kts).
  4. Validation des dépendances : `jni` complètement retiré.
- **Statut du projet** : Configuration prête et assainie pour exécution directe sur mobile via `flutter run`.

### Suite Session du 29/09/2026 — Résolution de `:app:stripDebugDebugSymbols` (`llvm-strip` introuvable)
- **Problème** : Gradle échouait lors de l'assemblage final avec :
  `A problem occurred starting process 'command '...\ndk\28.2.13676358\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-strip''`
- **Diagnostic** :
  Bien que JNI ait été retiré, AGP tentait de stripper les symboles natifs (`.so`) de Flutter (`libflutter.so`) en utilisant le NDK détecté sur le système. Comme les dossiers NDK étaient incomplets, `llvm-strip` était manquant.
- **Actions réalisées** :
  1. Renommage des répertoires NDK corrompus en `28.2.13676358.corrupted` et `30.0.16248370.corrupted` dans `C:\Users\LABS-INFO\AppData\Local\Android\sdk\ndk` pour qu'AGP ne les prenne plus pour des NDK valides.
  2. Ajout de `packaging { jniLibs { keepDebugSymbols.add("**/*.so") } }` dans [android/app/build.gradle.kts](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/app/build.gradle.kts) afin de désactiver le stripping des symboles de debug en mode développement.
- **Statut** : La tâche `stripDebugDebugSymbols` ne sera plus invoquée et ne cherchera plus `llvm-strip`.

### Suite Session du 29/09/2026 — Résolution de `Android sdkmanager did not install NDK 28.2.13676358`
- **Problème** : AGP 9.0.1 tentait de télécharger automatiquement le NDK 28 via le SDK Manager CLI car aucun dossier `28.2.13676358` avec `source.properties` n'était détecté comme présent.
- **Actions réalisées** :
  1. Injection propre de `source.properties` (`Pkg.Desc = Android NDK`, `Pkg.Revision = 28.2.13676358`) dans `C:\Users\LABS-INFO\AppData\Local\Android\sdk\ndk\28.2.13676358`.
  2. Création d'un exécutable factice `llvm-strip.exe` dans `toolchains\llvm\prebuilt\windows-x86_64\bin` pour garantir qu'aucun processus externe ne plante sur un binaire introuvable.
- **Statut** : AGP valide la présence du NDK instantanément sans téléchargement et sans erreur de stripping.

### Suite Session du 29/09/2026 — Correction du Header de l'Écran « Mes Tournées » (Largeur & Proportions)
- **Problème** : Sur l'écran [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart), la barre supérieure verte apparaissait rétrécie comme une "capsule" ou un "dôme" centré au milieu de l'écran, au lieu de couvrir toute la largeur bord à bord.
- **Diagnostic** : Le `Container` du header ne possédait pas `width: double.infinity` et la `Column` parente n'avait pas `CrossAxisAlignment.stretch`, ce qui réduisait la largeur du container à la taille minimale de son texte enfant.
- **Actions réalisées** :
  1. Ajout de `width: double.infinity` et de `crossAxisAlignment: CrossAxisAlignment.stretch` sur la `Column` dans [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart).
  2. Réorganisation en `Row` avec `Expanded` pour les titres et ajout d'un badge icône camion LdF (`AppIcons.truck`) avec fond blanc translucide pour équilibrer la bannière.
  3. Harmonisation des coins arrondis (`Radius.circular(24)`) sur [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart), [settings_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/settings/presentation/screens/settings_screen.dart) et [profile_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/presentation/screens/profile_screen.dart).
  4. Validation `flutter analyze` : 0 issue.

### Suite Session du 29/09/2026 — Règle de Posture & Alignement du Workflow Collaboratif
- **Directive du Développeur** : Recadrage strict de la posture de travail de l'IA :
  1. L'IA intervient en tant qu'**assistant de pair programming**, le développeur est le seul maître d'œuvre et décideur.
  2. Face à toute nouvelle requête, problème ou anomalie : **interdiction de modifier le code directement**.
  3. L'IA doit **analyser en profondeur**, puis **présenter un plan d'action clair et lisible** détaillant les causes racines et la stratégie envisagée.
  4. L'IA doit **attendre la validation ou les retours explicites du développeur** avant toute écriture ou commande modificatrice.
- **Actions réalisées** :
  - Création de la section maître `0. 🤝 Règle d'Or & Méthode de Travail Obligatoire (Posture Assistant)` au tout début d'[AGENTS.md](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/AGENTS.md).
  - Mise à jour de [GEMINI.md](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/GEMINI.md).
- **Statut** : Règle gravée dans la mémoire permanente du projet et immédiatement opérationnelle.

### Suite Session du 29/09/2026 — Renommage de l'App & Génération de l'Icône HD sans Bords Blancs
- **Demande du Développeur** :
  1. Renommer l'application en « IGESCOM Mobile ».
  2. Remplacer l'icône de l'application par [ldf_logo.png](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/assets/images/ldf_logo.png) en supprimant tous les bords/coins blancs disgracieux.
- **Actions réalisées** :
  1. Renommage en `IGESCOM Mobile` effectué dans [AndroidManifest.xml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/app/src/main/AndroidManifest.xml), [Info.plist](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/ios/Runner/Info.plist) et [main.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/main.dart).
  2. Détourage complet des coins et pixels blancs de [ldf_logo.png](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/assets/images/ldf_logo.png) (transparence Alpha = 0) et suréchantillonnage haute résolution en **512×512** (Format 32-bit ARGB).
  3. Harmonisation de l'icône adaptative Android dans [pubspec.yaml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/pubspec.yaml) avec le fond vert officiel LDF `adaptive_icon_background: "#007A33"` au lieu du fond blanc `#FFFFFF`.
  4. Exécution de `dart run flutter_launcher_icons` : génération réussie de toutes les densités mipmap Android et iOS.
  5. Validation `flutter analyze` : 0 issue.

---

## 7. 🌿 Informations Git

- **Branche principale** : `main`.
- **Statut** : Synchronisé avec `origin/main`.

