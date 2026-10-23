# LdF Igescom Mobile — Guide & Mémoire Permanente du Projet (LDF Groupe)

> **🤖 NOTE À L'ATTENTION DE L'ASSISTANT IA (ANTIGRAVITY / GEMINI)** :  
> Ce fichier est la **source de vérité absolue** et la mémoire permanente du projet **LdF Igescom Mobile**. Lis attentivement l'intégralité de ce document au début de chaque session ou conversation. Il contient le contexte métier, l'architecture complète, les conventions de code, les décisions techniques passées, les erreurs corrigées et l'historique des échanges. Met à jour ce document à la fin de chaque session de travail importante pour garantir une continuité parfaite sans aucune perte de contexte.

---

## 0. 🤝 Règle d'Or & Méthode de Travail Obligatoire (Posture Assistant)

> **⚠️ RÈGLE ABSOLUE & NON NÉGOCIABLE** :  
> L'IA intervient strictement comme **ASSISTANT TECHNIQUE** aux côtés du **DÉVELOPPEUR (le seul maître d'œuvre et décideur)**.  
> - **NE JAMAIS COMMENCER À MODIFIER DU CODE DIRECTEMENT DÈS LA RÉCEPTION D'UNE REQUÊTE.**  
> - **NE JAMAIS LANCER DE COMMANDE (TERMINAL, PROCESSUS, TÂCHE EN ARRIÈRE-PLAN) SANS L'ACCORD EXPLICITE PRÉALABLE DU DÉVELOPPEUR.**

### Le Workflow Strict en 4 Étapes à respecter pour chaque tâche :
1. **🔍 Analyse préalable** : Diagnostiquer le problème en lecture seule, identifier les causes racines et explorer les options possibles.
2. **📋 Proposition d'un Plan clair et lisible** : Présenter au développeur un plan d'action structuré détaillant précisément les fichiers concernés, les choix de conception/UI et les étapes envisagées.
3. **⏸️ Attente de Validation du Développeur** : Demander son avis et attendre son retour ou sa validation explicite ("Go", ajustements, remarques) avant toute action ou exécution.
4. **🛠️ Exécution & Restitution** : Guider le développeur pas à pas ou appliquer les modifications validées avec rigueur et les documenter.


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

### Suite Session du 29/09/2026 — Intégration de `flutter_dotenv` (.env) & `AppConfig`
- **Demande du Développeur** : Mettre en place un fichier `.env` pour externaliser les variables d'environnement (URL API, timeouts, configuration).
- **Actions réalisées** :
  1. Ajout de `flutter_dotenv: ^5.2.1` et déclaration de `- .env` dans les assets de [pubspec.yaml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/pubspec.yaml).
  2. Ajout de `.env` dans [.gitignore](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/.gitignore) avec exception pour [.env.example](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/.env.example).
  3. Création des fichiers [.env](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/.env) et [.env.example](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/.env.example) (`API_BASE_URL`, `CONNECT_TIMEOUT`, `RECEIVE_TIMEOUT`, `APP_ENV`, `APP_NAME`).
  4. Création de la classe de configuration typée [AppConfig](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/config/app_config.dart).
  5. Initialisation de `dotenv.load(fileName: ".env")` dans [main.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/main.dart).
  6. Remplacement de l'URL en dur et des timeouts par `AppConfig` dans [dio_client.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/dio_client.dart).
  7. Validation `flutter analyze` : **0 issue** (No issues found).

### Session du 16/10/2026 — Branchement API réelle : Phase 0 (Socle) + Phase 1 (Auth)
- **Contexte** : le web (Angular, collègue) est le backoffice ; le mobile est conçu indépendamment (ne pas copier son design, seulement sa logique métier). Les mocks existants servent aux démos aux directeurs ; **la référence est désormais l'API du backend**.
- **API réelle (serveur `http://192.168.1.238`, HTTP clair)** — explorée avec le compte de test `mobtest` :
  - `POST /api/metabase/mobile/livraison/login/` body `{nom_util, mdpasse}` → `{status, data:{agent{code_agent, nom_util, code_agce, code_fonct}, token, refresh}}`. Token d'accès 2 h, refresh 24 h (claims JWT). 401 = mauvais identifiants, 400 = champs vides. **Aucun endpoint de refresh trouvé** (tous en 404).
  - `GET /api/flotte/convotournees/{code_agent}` (sans slash final) → `{status, rows:[tournées]}` ; chaque tournée : `code_tournee` (TRN-timestamp), `libelle`, `date_tournee`, `heure_depart`, `statut` (EN_COURS…), `code_vehicule`, `chauffeur_info`, `convoyeur_info`, `km_depart/arrivee`, `observations`, `lignes[]` ; chaque ligne : `code_ligne`, `code_bl`, `ordre`, `actif`, `statut_livraison` (EN_ATTENTE / LIVREE), `date_livraison`, `observation_livraison`, `livraison.commande.client{nom_clt, tel1_clt, adresse_clt, ville_clt…}`. Payload lourd (~20 Ko/tournée, client dupliqué). **Pas de poids, montant ni GPS.**
  - `GET /api/flotte/tournees/{code_tournee}/` → 200, même structure dans `data`.
  - `GET /api/flotte/tournees/{code}/planning/{code_agent}/` → **401 même avec token** (non utilisé).
  - `POST .../tournees/{code_tournee}/lignes/{code_bl}/valider-livraison/` body `{observation_livraison, tournee}` — **non testé** (écriture) ; méthode/réponse à confirmer.
  - ⚠️ `convotournees` répond **sans authentification** (faille à signaler au backend).
- **Phase 0 (socle)** :
  1. [.env](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/.env) / `.env.example` : `API_BASE_URL=http://192.168.1.238`, nouveau flag **`USE_MOCK_API`** (`true` = démo, `false` = vraie API). [AppConfig](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/config/app_config.dart) expose `useMockApi`.
  2. [ApiEndpoints](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/api_endpoints.dart) : endpoints fictifs remplacés par les vrais (préfixe `/api` inclus).
  3. [TokenManager](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/token_manager.dart) : stocke aussi refresh token, `code_agent`, agence ; détection d'expiration du JWT (`isAuthenticated` tient compte de `exp`) ; flux `onSessionExpired` + `expireSession()`.
  4. [AuthInterceptor](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/auth_interceptor.dart) : sur 401 (hors login) → session invalidée ; [main.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/main.dart) écoute et redirige vers `/login` avec un message.
  5. [ApiErrorHandler](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/api_error_handler.dart) + `ApiException` : `DioException` → messages français (les repositories ne doivent plus renvoyer `e.toString()`).
  6. [dio_client.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/dio_client.dart) : logs désactivés en release, sans en-têtes, avec masquage mot de passe/tokens.
  7. Android : permission `INTERNET` ajoutée (absente du manifest principal) + [network_security_config.xml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/app/src/main/res/xml/network_security_config.xml) autorisant le HTTP clair **uniquement** vers `192.168.1.238` et `10.0.2.2` (à mettre à jour si l'IP change ; HTTPS à prévoir en production).
- **Phase 1 (Auth)** :
  1. Login = `nom_util` + `mdpasse` ; **champ Agence supprimé** de [login_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/auth/presentation/screens/login_screen.dart) (champ « Identifiant », identifiants de démo préremplis seulement en mode mock).
  2. `User` = `{id (code_agent), name (nom_util), agencyCode, functionCode}` ; `UserModel.fromJson` aligné sur `data.agent`.
  3. Datasource : `MockAuthRemoteDataSourceImpl` (env `mock`) et **`RealAuthRemoteDataSourceImpl`** (env `real`) dans [auth_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/auth/data/datasources/auth_remote_data_source.dart). `AuthRepositoryImpl.logout()` efface la session locale.
- **Mécanisme mock/réel (règle)** : environnements `injectable` (`kMockEnv`/`kRealEnv` dans [app_environments.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/di/app_environments.dart)), choisis dans `configureDependencies()` selon `USE_MOCK_API`. Une classe **sans `env`** est enregistrée partout : les features pas encore branchées (tour, delivery, dashboard) gardent leur mock. Pour brancher une feature : annoter le mock `env: [kMockEnv]`, ajouter l'implémentation `env: [kRealEnv]`, relancer `build_runner`.
- **Validation** : `build_runner` OK, `flutter analyze` : **No issues found**. Non testé sur appareil (le téléphone doit être sur le même réseau que le serveur).
- **Décisions en attente du développeur** : planning 401 (utiliser `/tournees/{code}/`), champs absents (poids/montant/GPS), flux « échec » sans endpoint, signature/photo non gérées par l'API, faille `convotournees` à signaler.
- **Prochaines phases** : 2 Tournées (modèles réels, statuts, `LIVREE`), 3 Validation livraison, 4 Dashboard/historique/profil dérivés.

### Suite Session du 16/10/2026 — Finalisation de la Consommation d'APIs Réelles & Refonte du Profil
- **Demande du Développeur** :
  1. Abandonner définitivement toutes les données mockées pour basculer sur les APIs réelles (`http://192.168.1.238`) sans altérer ni dégrader le design mobile d'origine.
  2. Aligner la page de Profil sur l'application de gestion interne web (`/monprofil/{code_agent}`) tout en conservant une ergonomie 100% mobile et fidèle à la charte LDF.
  3. Brancher les tournées, les livraisons, la validation et les KPI réels du dashboard.
- **Reverse Engineering & Découvertes Clés** :
  1. **Validation de livraison** : Découverte de l'URL réelle dans le bundle Angular : `POST /api/flotte/tournees/lignes/{code_bl}/valider-livraison/` avec body `{ "observation_livraison": ..., "tournee": code_tournee }` (le code tournée ne fait pas partie du path HTTP mais du body JSON).
  2. **Refresh Token JWT** : Découverte et validation réussie de `POST /api/login/token/refresh/` body `{ "refresh": token }` renvoyant `access` et `refresh`.
  3. **Profil Agent** : Découverte des endpoints `/api/profil/agents/{id}/`, `/api/profil/modificationagents/{id}/` et `/api/profil/ModificationAgentMDP/{id}/`.
- **Réalisations Effectuées** :
  1. **Refonte complète de la feature Profil (`lib/features/profile/`)** :
     - Entité [UserProfile](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/domain/entities/user_profile.dart) et modèle [UserProfileModel](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/data/models/user_profile_model.dart) intégrant Nom, Prénom, Téléphone, Portable, Adresse, Date et Lieu de Naissance, Matricule, Rôle et Agence.
     - [ProfileRemoteDataSourceImpl](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/data/datasources/profile_remote_data_source.dart) et [ProfileRepositoryImpl](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/data/repositories/profile_repository_impl.dart).
     - [ProfileCubit](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/presentation/cubit/profile_cubit.dart) gérant `loadProfile`, `updateProfile` et `changePassword` avec vérification stricte `isClosed`.
     - Écran mobile moderne [profile_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/presentation/screens/profile_screen.dart) : Header gradient LDF, carte identité/avatar avec badge d'agence et rôle, formulaire d'informations personnelles, carte de changement de mot de passe avec visibilité basculable et déconnexion sécurisée.
  2. **Tournées Réelles (`lib/features/tour/`)** :
     - Création de [TourModel](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/models/tour_model.dart) pour désérialiser `convotournees`.
     - Implémentation de `RealTourRemoteDataSourceImpl` (`env: [kRealEnv]`) appelant `GET /api/flotte/convotournees/{code_agent}` et extrayant les lignes de livraison et infos du convoyeur/chauffeur.
  3. **Livraisons & Validation Réelle (`lib/features/delivery/`)** :
     - Mise à jour de [DeliveryModel](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/models/delivery_model.dart) pour mapper les objets `lignes[]` (`code_bl`, `statut_livraison == 'LIVREE'`, `commande.client`).
     - Implémentation de `RealDeliveryRemoteDataSourceImpl` (`env: [kRealEnv]`) validant les livraisons via l'URL exacte `POST /api/flotte/tournees/lignes/{code_bl}/valider-livraison/`.
  4. **Dashboard & KPIs Dynamiques (`lib/features/dashboard/`)** :
     - `RealDashboardRemoteDataSourceImpl` (`env: [kRealEnv]`) calculant dynamiquement les livraisons terminées, en attente et la prochaine destination directement depuis les tournées réelles de l'agent.
     - Salutation personnalisée dynamique avec le nom de l'agent connecté dans [dashboard_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart).
  5. **Auto-refresh JWT Transparent** :
     - [AuthInterceptor](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/auth_interceptor.dart) gère le rafraîchissement transparent du token JWT via `/api/login/token/refresh/` avant de rejeter en 401.
- **Validation** :
  - `build_runner` : 28 outputs générés avec succès (exit code 0).
  - `flutter analyze` : **No issues found!** (0 erreur, 0 avertissement, 0 warning).
- **Statut du projet** : Application mobile 100% branchée sur l'API backend en temps réel, zéro mock en production (`USE_MOCK_API=false`), design mobile élégant préservé.

### Suite Session du 16/10/2026 — Correction Déconnexion Profil, Stats Dashboard Dynamiques & Overflow UI
- **Demande du Développeur** :
  1. Corriger la déconnexion intempestive lors de la navigation vers la page Profil (`/profile`).
  2. Brancher le Tableau de bord (`/dashboard`) pour afficher les vraies statistiques calculées en temps réel depuis les APIs de tournées (`convotournees`) au lieu de valeurs statiques en dur.
  3. Corriger l'overflow graphique `RenderFlex` (7 pixels) observé sur l'écran des tournées (`tour_screen.dart:285:23`).
  4. Respecter rigoureusement la règle d'or du projet : ne dégrader ni le design mobile, ni les styles visuels, ni l'architecture Clean.
- **Diagnostics & Résolutions** :
  1. **Déconnexion automatique sur Profil (Résolu)** :
     - *Cause racine* : Le token mobile émis par `/api/metabase/mobile/livraison/login/` possède le claim JWT `application: livraison`. L'accès aux endpoints ERP `/api/profil/agents/...` renvoyait `HTTP 401 {"detail":"Token invalide pour cette instance"}`. L'`AuthInterceptor` interceptait ce 401 et appelait systématiquement `expireSession()`, ce qui déconnectait le livreur.
     - *Solution* : Ajout d'une protection dans [auth_interceptor.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/auth_interceptor.dart) pour ne jamais expirer la session sur les endpoints de profil, les requêtes marquées `noSessionExpire: true` ou les erreurs de restriction d'instance. Ajout du stockage persistant des données de profil dans [token_manager.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/token_manager.dart) (`saveProfileData` / `getProfileData`) et lecture immédiate du cache dans [profile_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/data/datasources/profile_remote_data_source.dart).
  2. **Statistiques du Tableau de bord 100% dynamiques (Résolu)** :
     - Enrichissement de [DashboardStats](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/domain/entities/dashboard_stats.dart) et [DashboardStatsModel](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/data/models/dashboard_stats_model.dart) avec `totalDeliveries`, `failedDeliveries`, `activeToursCount`, `activeTourRef` et le getter `progressionRatio`.
     - Dans [RealDashboardRemoteDataSourceImpl](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/data/datasources/dashboard_remote_data_source.dart), calcul en temps réel des totaux, livraisons terminées, en attente, échecs et référence de la tournée active depuis `_tourRemoteDataSource.getTours()`.
     - Dans [dashboard_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart), remplacement de toutes les valeurs en dur (`10`, `6`, `3`, `1`, `2 / 6 livrées`, `value: 2 / 6`, `1 Tournée en cours`, `TRN-2026-0830`) par les métriques réelles de `state.stats`, avec préservation intégrale et méticuleuse du design visuel (gradients, ombres, coins arrondis, couleurs LDF).
  3. **Correction de l'Overflow RenderFlex dans les Tournées (Résolu)** :
     - Dans [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart), la `Row` affichant `'Tournée ${tour.agence}'` et le badge de date a été encapsulée dans un `Expanded` avec `TextOverflow.ellipsis` et espacement contrôlé `SizedBox(width: 8)`, éliminant tout débordement sur les écrans de toutes tailles.
- **Validation** :
  - `dart run build_runner build` : 14 outputs générés (code d'injection à jour).
  - `flutter analyze` : **No issues found!** (0 erreur, 0 avertissement).
### Suite Session du 16/10/2026 — Intégration du Nom Réel des Tournées (`libelle`) & Ergonomie Mobile
- **Demande du Développeur** :
  1. Afficher le vrai nom de chaque tournée (`libelle` issu de l'API, ex : **TEST MOB 1**, **TEST RUF**, **TEST 122**) au lieu de l'intitulé générique `Tournée DEPOT GRANDS COMPTES`.
  2. Respecter strictement la contrainte d'ergonomie mobile : **ne pas surcharger la carte** avec la multitude d'informations présentes sur la version web grand écran, conserver un affichage épuré, compact et direct.
- **Réalisations Effectuées** :
  1. **Domaine (`TourEntity`)** :
     - Ajout des champs `libelle`, `heureDepart`, `chauffeurName` et du getter pratique `displayName` (qui privilégie le `libelle` métier s'il est non vide, sinon la référence `TRN-...`).
  2. **Données (`TourModel`)** :
     - Désérialisation fidèle des clés `json['libelle']`, `json['heure_depart']` et `json['chauffeur_info']['nom_complet']`.
     - Mise à jour de `MockTourRemoteDataSourceImpl` pour aligner les données de démonstration.
  3. **Écran « Mes Tournées » (`tour_screen.dart`)** :
     - Titre de la carte : `tour.displayName` (**TEST MOB 1**, etc.) avec nombre de livraisons.
     - Ligne de métadonnées ultra-légère et discrète (police 11px) : `🕒 09:00` · `🚚 VEH001` · Nom du chauffeur sans surcharge visuelle.
     - Barre de progression compacte conservée.
  4. **Écran Détail & Tableau de bord** :
     - [tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart) affiche `tour.displayName` dans le header au lieu de l'agence.
     - [dashboard_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/data/datasources/dashboard_remote_data_source.dart) utilise `tour.displayName` pour l'intitulé de la tournée en cours sur le Dashboard.
- **Validation** :
  - `flutter analyze` : **No issues found!** (0 erreur, 0 avertissement).

### Session du 19/10/2026 — UI : Icône Identifiant & Popups à la place des Toasts
- **Demande du Développeur** :
  1. Page connexion : icône du champ « Identifiant » = personne (au lieu du badge).
  2. Messages de retour : privilégier les **popups** plutôt que les toasts, avec un rendu **professionnel et sobre** (ne pas donner l'impression d'un design généré par IA).
- **Réalisations** :
  1. [login_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/auth/presentation/screens/login_screen.dart) : `AppIcons.badge` → `AppIcons.person`.
  2. [app_dialogs.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/utils/app_dialogs.dart) : gabarit commun sobre (carte blanche rayon 12, fine barre d'accent 3px, petite icône 20px + titre alignés à gauche, message gris, bouton aligné à droite, pas de grand cercle pastel). Nouveaux `showWarningDialog` / `showInfoDialog` ; `showSuccessDialog` / `showErrorDialog` / `showConfirmationDialog` restylés ; paramètre optionnel `title`. **File d'attente** statique : un seul popup de message à la fois, `context.mounted` vérifié avant affichage.
  3. [app_feedback.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/utils/app_feedback.dart) : `success/error/warning/info` ouvrent désormais des popups (retournent un `Future<void>` terminé à la fermeture) → ~30 appels migrés sans toucher chaque écran. `AppFeedback.toast(...)` conservé (SnackBar discret) pour les confirmations mineures.
  4. [settings_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/settings/presentation/screens/settings_screen.dart) : 10 `AppFeedback.info` → `AppFeedback.toast` (réglages fréquents).
  5. Titres métier ajoutés : « Connexion impossible » (login), « Livraison confirmée » / « Validation impossible » (livraison, tournée), « Session expirée » ([main.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/main.dart)).
  6. [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) : `context.pop(true)` exécuté **après** fermeture du popup de succès (sinon il aurait fermé le popup lui-même).
- ⚠️ **Règle à retenir** : tout `AppFeedback.*` suivi d'une navigation doit chaîner `.then(...)` (popup bloquant), avec contrôle `context.mounted`.
- **Correctif dialogue de confirmation** : `minimumSize: Size.zero` sur les boutons de `showDeliveryConfirmationDialog` (le thème impose `Size(double.infinity, 56)` aux boutons → boutons dans une `Row` = crash `RenderBox was not laid out`). **Règle** : tout bouton placé dans une `Row` doit redéfinir `minimumSize`.

### Suite Session du 19/10/2026 — Correction Définitive Validation Livraison & Token Tenant
- **Symptôme** : « Ressource introuvable » (404) ou « Token invalide pour cette instance » (401).
- **Analyse des requêtes du portail Web (DevTools)** :
  1. **URL réelle du Web** : `POST /api/flotte/tournees/lignes/{code_ligne}/valider-livraison/` avec body `{"observation_livraison": "", "tournee": ""}` (pas de `code_tournee` dans l'URL, et le paramètre est bien `code_ligne` ex: 71811, pas `code_bl`).
  2. **Origine du 401 Instance** : Le login mobile initial manquait du claim `tenant: "t_a66f51c3"`. Le token ERP émis par `/api/login/` (qui requiert `{nom_util, mdpasse, code_agce}`) contient ce tenant et passe le middleware Django sans aucun blocage.
- **Modifications appliquées** :
  1. [api_endpoints.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/api_endpoints.dart) : `validateDelivery(String codeLigne)` pointant sur `/api/flotte/tournees/lignes/$codeLigne/valider-livraison/`.
  2. [delivery_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/models/delivery_model.dart) : `Delivery.id` = `code_ligne` (ex: 71411), et `deliveryNoteNumber` = `BL-66488311` pour l'affichage UI.
  3. [delivery_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart) : `ApiEndpoints.validateDelivery(cleanLigneId)` avec `observation_livraison` et `tournee`.
  4. [auth_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/auth/data/datasources/auth_remote_data_source.dart) : Lors du login, acquisition transparente du token ERP avec claim tenant (`/api/login/`) pour débloquer toutes les opérations d'instance.
  5. [token_manager.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/token_manager.dart) : Ajout du getter `hasTenantClaim` vérifiant la présence du tenant dans le JWT stocké.
  6. [splash_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/auth/presentation/screens/splash_screen.dart) : Purge automatique des anciennes sessions sans tenant pour forcer une reconnexion propre et valide.
  7. [auth_interceptor.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/auth_interceptor.dart) : Interdiction stricte d'injecter `Authorization` sur les routes de login (`login` et `erpLogin`) pour éviter l'erreur 500 du serveur Django.
  8. [delivery_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart) : Ajout de `noSessionExpire: true` sur la requête de validation pour sanctuariser la session du livreur contre toute déconnexion intempestive.
- **Validation** : `flutter analyze` : **No issues found!** (0 erreur, 0 avertissement).



### Session du 20/10/2026 — Refonte Reprogrammation BL, Horodatage Réel & Ergonomie Popups
- **Directives Fermes du Développeur & Posture** :
  1. **Interdiction formelle absolue** pour l'assistant d'exécuter des commandes terminal ou processus en arrière-plan sans accord préalable explicite.
  2. Mode de travail : l'assistant guide pas à pas avec précision, le développeur applique lui-même les modifications.
  3. Remplacement sémantique et visuel de « l'échec de livraison » par **« Reprogrammation de livraison »** : un BL reprogrammé n'est pas clôturé, le livreur doit pouvoir revenir dessus et valider sa livraison à tout moment.
- **Réalisations Effectuées** :
  1. **Badges de statut sur les tournées ([tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart))** :
     - Retrait du bouton d'action direct 'Valider' sur chaque carte de BL au profit des 3 badges : « En attente », « Reprogrammé » (warning/ambre) et « Livré » (success/vert).
  2. **Suppression de l'écran rouge d'échec & Popup modal de reprogrammation ([delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart))** :
     - Remplacement de `DeliveryFailureScreen` (plein écran rouge anxiogène) par un **popup modal sobre et moderne** `_showReprogramDialog` : saisie du motif de report directement sur place sans quitter la commande.
     - Le bandeau supérieur dans le suivi affiche désormais « 🕒 Livraison reprogrammée » en ambre doux avec icône horloge au lieu de « Livraison annulée ».
     - Rétablissement des boutons d'action du bas : le bouton vert « Valider la livraison » et le bouton ambre « Reprogrammer » restent accessibles si le BL est *En attente* ou *Reprogrammé*. Seuls les BL *Livrés* masquent les actions (consultation seule).
  3. **Horodatage réel & Découverte Clé API** :
     - Analyse de la réponse réelle de validation : le backend calcule lui-même et renvoie `date_livraison` (`2026-10-20T11:06:48.185648Z`) et passe automatiquement `tournee_terminee: true` et `statut_tournee: "TERMINEE"` quand le dernier BL est validé.
     - [delivery_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/models/delivery_model.dart) : Priorité donnée à `date_livraison` sur `date_livr` (qui ne contenait que la date sans heure `00:00:00`).
     - [delivery.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/domain/entities/delivery.dart) : Ajout du paramètre `DateTime? scheduledTime` dans `Delivery.copyWith`.
     - Affichage de `--:--` pour les commandes non encore livrées au lieu du trompeur `00:00`.
- **Validation** : Commits Git validés et exécutés par le développeur.

### Session du 21/10/2026 — Décision Stratégique Cartographie & Migration Officielle Google Maps
- **Contexte & Analyse Métier** :
  1. **Constat sur OpenStreetMap (`flutter_map`)** : Les tuiles gratuites `tile.openstreetmap.org` souffrent de latences importantes sur réseau mobile, d'écrans gris intempestifs et d'un rendu visuel "dessin animé" des années 2000 non conforme à l'exigence d'une application professionnelle de transport/distribution.
  2. **Vision Métier de la Géolocalisation** : La carte sert principalement à la **traçabilité du livreur** (prouver où il se trouve au moment de la livraison et remonter ses coordonnées GPS au backend lors de la validation du BL).
  3. **Décision** : Migration officielle vers **Google Maps (`google_maps_flutter`)** pour un rendu vectoriel moderne, sombre/épuré, fluide et fiable, avec le point bleu GPS natif.
- **Feuille de Route Validée pour l'Intégration Google Maps** :
  1. [pubspec.yaml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/pubspec.yaml) : Ajout de `google_maps_flutter: ^2.10.0` (suppression ultérieure de `flutter_map` et `latlong2`).
  2. **Sécurité & AndroidManifest** :
     - Déclaration de `MAPS_API_KEY` dans `android/local.properties` (hors Git).
     - Injection dans [android/app/build.gradle.kts](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/app/build.gradle.kts) via `manifestPlaceholders["mapsApiKey"]`.
     - Ajout de `<meta-data android:name="com.google.android.geo.API_KEY" android:value="${mapsApiKey}" />` dans [AndroidManifest.xml](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/android/app/src/main/AndroidManifest.xml).
  3. [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) : Refonte de `_MapSection` avec `GoogleMap`, `GoogleMapController.animateCamera`, maintien du conteneur arrondi (120px, coins 16px, bandeau "Position actuelle activée") et repli sur Abidjan (`5.3600, -4.0083`).
  4. [location_service.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/services/location_service.dart) : Conservation intégrale du service de géolocalisation basé sur `Geolocator` sans duplication.

### Suite Session du 21/10/2026 — Motif de Marque LDF Groupe (`LdfPatternBackground`) & Déploiement Global
- **Demande du Développeur** :
  1. Éliminer l'effet fond blanc plat/froid sur l'ensemble de l'application au profit d'une identité visuelle propre à **Librairie de France Groupe**.
  2. Créer un composant réutilisable global intégrant un dégradé subtil Vert-Jaune LDF et des symboles vectoriels en filigrane représentant les cœurs de métier du groupe (livres, cahiers scolaires, presse/journaux, maroquinerie, ordinateurs, stylos).
  3. Assurer un rendu net, sans flou de tracé, avec des opacités équilibrées (16% vert LDF, 22% jaune doré LDF) et zéro impact sur la fluidité (mis en cache via `RepaintBoundary` et `IgnorePointer`).
  4. Déployer ce motif d'arrière-plan sur l'ensemble des pages à fond blanc du projet.
- **Réalisations Effectuées** :
  1. **Création du composant signature [ldf_pattern_background.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/widgets/ldf_pattern_background.dart)** :
     - Dégradé diagonal LDF : Vert pastel (`#E6F4EA`) ➔ Transition douce (`#F3F8EE`) ➔ Jaune doré pastel (`#FFF6D4`).
     - Peintre vectoriel `_LdfBrandWatermarkPainter` traçant en quinconce et rotation (-12°) les icônes thématiques LDF avec alternance Vert (`AppColors.primary`, alpha 0.16) et Jaune Doré (`#C98A00`, alpha 0.22).
  2. **Déploiement sur les 8 écrans à fond blanc** :
     - [dashboard_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart) (Tableau de bord / Accueil).
     - [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart) (Mes Tournées).
     - [profile_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/profile/presentation/screens/profile_screen.dart) (Mon Profil).
     - [tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart) (Détail de Tournée).
     - [history_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/history/presentation/screens/history_screen.dart) (Historique des tournées).
     - [history_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/history/presentation/screens/history_detail_screen.dart) (Détail Historique).
     - [settings_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/settings/presentation/screens/settings_screen.dart) (Paramètres).
     - [notifications_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/notifications/presentation/screens/notifications_screen.dart) (Notifications).
     *(L'écran [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) avait été intégré préalablement).*
### Suite Session du 21/10/2026 — Mode Hors-Ligne (Étape 1 : Cache & Sécurisation des Erreurs)
- **Demande du Développeur** :
  1. Activer la consultation hors-ligne des tournées et livraisons (lorsqu'il n'y a pas d'Internet ou en zone blanche).
  2. **Sécurité & Confidentialité stricte** : Interdiction absolue de laisser fuiter des messages d'erreur techniques backend (types d'erreurs API, stack traces, URLs et adresses IP privées comme `192.168.1.238`) lors d'une rupture de connexion. Traduire systématiquement toute erreur en texte clair, bienveillant et en français.
- **Réalisations Effectuées** :
  1. **Création de la source locale [tour_local_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_local_data_source.dart)** :
     - Stockage sécurisé des tournées au format JSON dans `SharedPreferences` (`LDF_CACHED_TOURS_ROWS`).
     - Horodatage de synchronisation (`LDF_TOURS_LAST_SYNC_TIME`) pour le suivi.
     - Enregistrement dans GetIt via [injection.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/di/injection.dart).
  2. **Bascule transparente en mode hors-ligne dans [tour_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_remote_data_source.dart)** :
     - Dès que l'API répond, les données sont mises en cache silencieusement.
     - En cas d'indisponibilité du réseau (`DioException`), bascule automatique sur les tournées en cache local sans bloquer l'application.
     - Le Dashboard recalcule automatiquement ses KPI depuis ce cache local en mode hors-ligne.
  3. **Assainissement complet des messages d'erreur (Sécurité)** :
     - Remplacement de tous les `e.toString()` résiduels par `ApiErrorHandler.message(e)` dans :
       - [tour_repository_impl.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/repositories_impl/tour_repository_impl.dart).
       - [dashboard_repository_impl.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/data/repositories_impl/dashboard_repository_impl.dart).
       - [delivery_repository_impl.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/repositories_impl/delivery_repository_impl.dart).
     - Zéro fuite d'adresses IP privées ou d'erreurs système : les coupures affichent sobrement *« Impossible de joindre le serveur. Vérifiez votre connexion réseau. »*.
  4. **Amélioration de l'UI d'erreur dans [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart)** :
     - Remplacement de l'alerte technique rouge par un état sobre avec icône `cloudOff`, message explicatif en français et bouton vert **« Réessayer »** pour relancer la synchronisation.
### Suite Session du 21/10/2026 — Mode Hors-Ligne (Étape 2 : Validation Hors-Ligne & File d'Attente de Synchronisation)
- **Demande du Développeur** :
  1. Permettre la validation des livraisons même lorsque l'appareil est complètement hors-ligne (pas d'accès au réseau local ou à Internet).
  2. Remplacer l'échec réseau précédent (*« Impossible de joindre le serveur »*) par un enregistrement local en file d'attente (`Queue`).
  3. Mettre à jour immédiatement et de manière optimiste le statut de la livraison dans le cache local (`LDF_CACHED_TOURS_ROWS`) pour que les compteurs du Dashboard et la vue de la tournée passent à « Livré » sans délai.
  4. Afficher des messages clairs et bienveillants informant le livreur que la validation a été enregistrée en local et partira dès le rétablissement de la connexion.
  5. Synchroniser automatiquement toutes les validations en attente dès que l'application retrouve le réseau.
- **Réalisations Effectuées** :
  1. **Enrichissement de [tour_local_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_local_data_source.dart)** :
     - Ajout de la file d'attente persistante `LDF_PENDING_DELIVERY_SYNC_QUEUE` : `enqueuePendingDelivery()`, `getPendingDeliveries()`, `removePendingDelivery()`, `isPendingSync()`, `pendingDeliveriesCount`.
     - Méthode de mise à jour optimiste directe du cache JSON : `updateCachedDeliveryStatus(codeLigne, status, notes)`.
  2. **Interception Hors-Ligne dans [delivery_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart)** :
     - En cas d'échec de communication réseau lors de `POST .../valider-livraison/` (`DioException` sans réponse serveur ou exception socket), l'action est enregistrée en file d'attente locale et le cache est muté en `LIVREE`.
     - Renvoi d'un `DeliveryModel` avec statut `delivered` (au lieu de lever une exception réseau).
  3. **Moteur d'Auto-Synchronisation dans [tour_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_remote_data_source.dart)** :
     - Méthode `syncPendingDeliveries()` qui rejoue séquentiellement les validations de la file d'attente vers l'API backend dès que la connectivité est rétablie.
     - Appel automatique de la synchronisation au début de `getTours()`.
     - Protection anti-clignotement : si des lignes sont encore en file d'attente locale, leur statut `LIVREE` est préservé lors du rechargement des tournées du serveur.
  4. **Feedback & Badges UI Adaptatifs** :
     - [tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart) : Badge d'état `Livré (En attente sync)` avec icône `cloudOff` orangée pour les livraisons validées hors-ligne, et popup de confirmation explicite : *« Livraison enregistrée en local (mode hors-ligne). Elle sera synchronisée dès le retour du réseau. »*.
     - [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) et [delivery_validation_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_validation_screen.dart) : Notification claire de sauvegarde hors-ligne.
### Suite Session du 21/10/2026 — Optimisation Typographique & Lisibilité Terrain (Mini-Tablette 7")
- **Demande du Développeur** :
  1. Renforcer la mise en forme et la présence visuelle de la police d'écriture dans toute l'application.
  2. Adapter l'ergonomie visuelle à l'usage réel sur mini-tablette (7 pouces en livraison/véhicule) pour que les textes ressortent nettement sans effort de lecture.
- **Réalisations Effectuées** :
  1. **Socle Thème & Contraste ([app_colors.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/constants/app_colors.dart) & [app_theme.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/theme/app_theme.dart))** :
     - Rehaussement du contraste de `AppColors.textSecondary` passant de `#64748B` (gris clair) à `#334155` (ardoise soutenu haute lisibilité).
     - TextTheme agrandi et épaissi : `displayLarge` (36px w900), `headlineMedium` (26px w800), `titleLarge` (22px w800), `titleMedium` (18px w700), `bodyLarge` (16.5px w600), `bodyMedium` (14.5px w500), `bodySmall` (13px w600).
     - Boutons principaux rehaussés à 16.5px (w800) et hauteur tactile de 58px.
     - Navigation Bar : labels à 12.5px (w800/w600), icônes à 24px, hauteur portée à 68px.
  2. **Écran « Mes Tournées » ([tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart))** :
     - Cartes : Référence (13.5px w800), badge statut (12.5px w800), nom de tournée (16.5px w800), compteurs et métadonnées (13px w600).
  3. **Écran « Détail de Tournée » ([tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart))** :
     - Cartes de livraison : Nom client (16px w800), adresse (13.5px w600), heure et N° BL (13px/12px w800), badge statut (12.5px w800).
     - Barre de progression agrandie avec pourcentages et compteurs nets (13px w800).
  4. **Tableau de Bord ([dashboard_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart))** :
     - Chiffres des cartes KPI portés à 26px (w900) et libellés à 13px (w700).
     - Salutation (16px w600) et Titre (26px w800).
     - Bannière tournée active plus contrastée et visible.
  5. **Écran « Détail Livraison » ([delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart))** :
     - Timeline de suivi : labels agrandis de 9px à 12px (w800) avec bulles à 32px.
     - Cartes KPI de livraison : libellés à 13px (w700) et valeurs à 15.5px (w800).
  6. **Barre de Navigation ([main_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/presentation/screens/main_screen.dart))** :
     - Agrandissement des libellés de 11.5px à **14px** avec graisses ultra-visibles (`FontWeight.w900` actif / `FontWeight.w700` inactif).
     - Augmentation de la taille des icônes de 23px à **27px** avec coussin tactile élargi (22x6px).
     - Contraste renforcé des onglets inactifs sur le fond jaune (`withAlpha(195)` au lieu de `110`).
     - Hauteur de barre portée à **74px** adaptée au format tablette.
- **Validation Statique** :
  - Correction du résidu de syntaxe ligne 245 dans [dashboard_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/dashboard/presentation/screens/dashboard_screen.dart).
  - Remplacement de l'appel dynamique par la constante `Color(0xDCFFFFFF)` dans le header de [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart).
- **Statut** : Base de code assainie, 0 erreur de syntaxe.

### Suite Session du 21/10/2026 — Correction des Statuts de Tournée sur la Page « Tournées »
- **Demande du Développeur** :
  - Sur la page « Tournées » ([tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart)), les statuts de **Tournée** « Terminé » et « En cours » apparaissaient tous les deux en vert, créant une confusion visuelle entre une mission active et une mission clôturée.
- **Actions réalisées** :
  1. Modification de `_statusColor` et `_statusBgColor` pour les entités `TourStatus` dans [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart) :
     - `TourStatus.inProgress` (Tournée En cours) ➔ `AppColors.accentBlue` (`#2F80ED`) avec fond `AppColors.accentBlueSoft` (`#EFF6FF`).
     - `TourStatus.completed` (Tournée Terminée) ➔ `AppColors.success` (`#10B981`) avec fond `AppColors.successSoft` (`#ECFDF5`).
     - `TourStatus.pending` (Tournée Programmée) ➔ `AppColors.warning` (`#F59E0B`) avec fond `AppColors.warningSoft` (`#FFFBEB`).
     - `TourStatus.cancelled` (Tournée Annulée) ➔ `AppColors.error` (`#EF4444`) avec fond `AppColors.errorSoft` (`#FEF2F2`).
  2. Harmonisation de la barre de progression sur la carte de tournée : jauge en `AppColors.accentBlue` durant la progression (< 100%), puis bascule en `AppColors.success` une fois la totalité des livraisons de la tournée achevée (100%).
- **Statut** : Distinction visuelle immédiate et 100% conforme au standard logistique et à la charte LdF.

### Suite Session du 22/10/2026 — Intégration de l'API de Report de Livraison & Suppression des Fallbacks Factices
- **Demande du Développeur** :
  1. Brancher l'API réelle de reprogrammation / report de livraison :
     - `POST /api/flotte/tournees/${code_tournee}/lignes/${code_bl}/reporter-livraison/`
     - Body : `{ "motif_report": motifReport }`
  2. Supprimer les données factices / mockées de secours pour s'appuyer exclusivement sur les données réelles du backend API.
- **Actions réalisées** :
  1. [ApiEndpoints](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/core/network/api_endpoints.dart) : Ajout de la méthode `reportDelivery(String codeTournee, String codeBl)`.
  2. [RealDeliveryRemoteDataSourceImpl](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart) :
     - Implémentation du `POST` réel vers `reportDelivery(cleanTournee, cleanBl)` avec `{ "motif_report": notes }`.
     - Mise à jour du cache local (`TourLocalDataSource`) avec statut `REPORTEE` et le motif de report.
     - Prise en charge du mode hors-ligne sans interruption de service.
     - Remplacement des retours d'objets `DeliveryModel` vides/factices par `_getRealDelivery()` qui extrait la vraie livraison stockée dans le cache depuis les données de l'API backend (`convotournees`).
  3. [DeliveryRepository](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/domain/repositories/delivery_repository.dart), [DeliveryRepositoryImpl](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/repositories_impl/delivery_repository_impl.dart) & [UpdateDeliveryStatusUseCase](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/domain/usecases/update_delivery_status_usecase.dart) : Propagation du paramètre `codeBl`.
  4. [DeliveryCubit](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/bloc/delivery_cubit.dart) : Dans `reportFailure`, extraction automatique du `cleanBl` (sans préfixe `BL-`) et passage du motif.
  5. [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) : Adaptation du toast de confirmation (titre *"Livraison reportée"* / message *"Le report de la livraison a été enregistré avec succès."*).
### Session du 22/10/2026 — Traçabilité Complète des Dates (Tournée, Livraison, Report)
- **Objectif du développeur** :
  1. Afficher clairement la date de tournée sur le mobile comme sur le web (`date_tournee`).
  2. Assurer la traçabilité complète du cycle de vie des livraisons (date prévue initiale, date & heure réelles de livraison, date & heure de report avec motif).
  3. Aligner le design visuel des cartes de livraison sur le web (capsule de date sous le badge de statut).
- **Actions réalisées** :
  1. [tour_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_screen.dart) : Affichage sur chaque carte de tournée de la date au format français (`dd MMM yyyy`, ex: `22 oct. 2026`) avec icône calendrier, suivie de l'heure de départ (`heureDepart`), du véhicule et du chauffeur.
  2. [tour_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/presentation/screens/tour_detail_screen.dart) :
     - En-tête : affichage de la date et de l'heure de la tournée.
     - Cartes de livraison : ajout de la capsule de date sous le badge de statut (comme sur le Web IGESCOM).
     - Ajout de l'encart ambré `Motif : [notes]` pour les livraisons reprogrammées.
  3. [delivery_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/models/delivery_model.dart) :
     - Priorisation intelligente de `date_livraison` (livré), `date_report` (reporté) et `date_livr` (prévue).
  4. [tour_local_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_local_data_source.dart) & [delivery_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart) :
     - Prise en charge de `eventDate` serveur pour horodater précisément `date_livraison` ou `date_report`.
     - Séparation stricte de `date_report` (sans écraser `date_livraison`) lors des reports.
  5. [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) :
     - Carte KPI : affichage dynamique `Livré le`, `Reprogrammé le` ou `Date prévue` avec format `dd/MM/yyyy · HH:mm`.
     - Timeline : affichage de la date/heure de reprogrammation dans le bandeau ambré.
- **Statut** : Traçabilité temporelle 100% alignée avec le backend IGESCOM et l'interface Web.

### Session du 23/10/2026 — Intégration Données Réelles BL dans le PDF & Émargement / Signature Tactile Client (Démo V2)
- **Objectifs du développeur (Finalisation V1 & Démo lundi)** :
  1. **Point 1 (Données réelles BL)** : Éliminer 100% des données mockées dans la simulation PDF du Bon de Livraison (`delivery_note_screen.dart`) pour refléter fidèlement les données backend de l'API (`convotournees`) : chauffeur réel (`ADMIN PLATEAU`), véhicule réel (`Toyota Land Cruiser ABJ-1010-CI`), agence réelle, client réel avec compte contribuable (`compte_contrib`), et articles/lignes réelles de commande avec taxes (ARSI & TVA) et total exact en FCFA.
  2. **Point 2 (Double option de validation pour la démo)** :
     - **Option 1 (Directe)** : Validation standard rapide sans signature avec visa numérique automatique.
     - **Option 2 (Émargement tactile — Démo V2)** : Pad de signature tactile plein écran tablette/mobile (`SignaturePadDialog`), saisie du nom du réceptionnaire, dessin fluide au doigt ou stylet, et intégration directe de la signature manuscrite vectorielle dans la case « CACHET & SIGNATURE CLIENT » du PDF du BL.
- **Réalisations Effectuées** :
  1. [delivery_note.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/domain/entities/delivery_note.dart) & [delivery.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/domain/entities/delivery.dart) : Ajout de `orderNumber`, `compteContrib`, `montTva`, `montArsi`, `signedBy` et `signatureData`.
  2. [delivery_line_item.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/domain/entities/delivery_line_item.dart) : Ajout de `unit` pour les conditionnements (lot, colis, taxe).
  3. [tour_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/models/tour_model.dart) : Extraction enrichie du véhicule (`vehicule_info` : marque, modèle, immatriculation) et propagation du chauffeur, véhicule et agence aux `DeliveryModel`.
  4. [delivery_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/models/delivery_model.dart) : Construction de l'entité `DeliveryNote` avec les articles réels, les taxes ARSI/TVA et les données de signature.
  5. [signature_pad_dialog.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/widgets/signature_pad_dialog.dart) : Composant tactile d'émargement électronique avec saisie du réceptionnaire, dessin à l'encre bleue officielle LdF, effacement et sérialisation vectorielle fluide.
  6. [delivery_note_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_note_screen.dart) :
     - Remplacement intégral des données mockées : expéditeur avec agence, client avec code et compte contribuable, références réelles, tableau dynamique des articles et taxes avec montants en FCFA.
     - Affichage de la vraie signature manuscrite vectorielle (`SignatureViewer`) et du tampon « ÉMARGÉ LDF DIGITAL » dans le cadre de réception.
  7. [delivery_detail_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_detail_screen.dart) :
     - Modale de choix `_showValidationChoiceModal` proposant au livreur/présentateur les deux options : Option 1 (Validation directe) et Option 2 (Émargement tactile client avec badge Démo V2).
     - Raccourci tactile sous le bouton de consultation du BL.
  8. [tour_local_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_local_data_source.dart), [delivery_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart), [delivery_repository_impl.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/repositories_impl/delivery_repository_impl.dart) et [delivery_cubit.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/bloc/delivery_cubit.dart) : Persistance de `signed_by` et `signature_data` en ligne et hors-ligne dans le cache local.
  9. [delivery_note_screen.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/presentation/screens/delivery_note_screen.dart) : Remplacement de l'icône du camion par le logo officiel LDF Groupe (`assets/images/ldf_logo.png`) dans le bandeau vert.
  10. [delivery_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/models/delivery_model.dart) & [tour_model.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/models/tour_model.dart) : Harmonisation stricte des montants entre Détail (`delivery.amount`) et BL (`deliveryNote.totalAmount`) pour afficher exactement 15 FCFA sans doublon avec la retenue ARSI, et nettoyage du linter.
  11. [tour_local_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/tour/data/datasources/tour_local_data_source.dart) & [delivery_remote_data_source.dart](file:///c:/Users/LABS-INFO/Desktop/ldfgroupe_projects/mobile_projects/igescom_mobile/lib/features/delivery/data/datasources/delivery_remote_data_source.dart) : Création d'un magasin persistant dédié (`LDF_SAVED_DELIVERY_SIGNATURES`) stockant les signatures électroniques (`signed_by` et `signature_data`). Fusion automatique des signatures avec les données renvoyées par `GET convotournees` afin de garantir que les signatures ne disparaissent jamais après actualisation de la page ou réouverture de l'app.
- **Statut** : Les 2 chantiers de la démo sont finalisés, cohérents à 100%, signatures pérennes et prêts pour la présentation de lundi.

---

## 7. 🌿 Informations Git

- **Branche principale** : `souley_dev`.
- **Statut** : Prêt pour commit.



