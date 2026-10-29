/// Environnements d'injection de dépendances (injectable).
///
/// - [kMockEnv] : datasources simulées pour les démos (`USE_MOCK_API=true`).
/// - [kRealEnv] : datasources branchées sur la vraie API (`USE_MOCK_API=false`).
///
/// Une classe sans `env` est enregistrée dans tous les environnements : les
/// features pas encore branchées sur l'API gardent donc leur mock par défaut.
const String kMockEnv = 'mock';
const String kRealEnv = 'real';
