import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Catalogue d'icônes centralisé — toujours Lucide, jamais Icons.*
/// Modifier ici suffit pour changer une icône dans toute l'app.
abstract class AppIcons {
  // ── Navigation ────────────────────────────────────────────────────────────
  static const home          = LucideIcons.house;
  static const homeFilled    = LucideIcons.housePlus;
  static const truck         = LucideIcons.truck;
  static const truckMoving   = LucideIcons.truckElectric;
  static const profile       = LucideIcons.userCircle;
  static const profileFilled = LucideIcons.userCheck;

  // ── Actions ───────────────────────────────────────────────────────────────
  static const back          = LucideIcons.arrowLeft;
  static const forward       = LucideIcons.arrowRight;
  static const chevronRight  = LucideIcons.chevronRight;
  static const filter        = LucideIcons.filter;
  static const search        = LucideIcons.search;
  static const close         = LucideIcons.x;
  static const share         = LucideIcons.share2;
  static const phone         = LucideIcons.phone;
  static const phoneCall     = LucideIcons.phoneCall;
  static const play          = LucideIcons.play;
  static const check         = LucideIcons.check;
  static const checkCircle   = LucideIcons.checkCircle;
  static const checkCheck    = LucideIcons.checkCheck;
  static const alertTriangle = LucideIcons.triangleAlert;
  static const info          = LucideIcons.info;
  static const logout        = LucideIcons.logOut;
  static const settings      = LucideIcons.settings;
  static const help          = LucideIcons.helpCircle;
  static const notification  = LucideIcons.bell;
  static const bellRing      = LucideIcons.bellRing;
  static const bellOff       = LucideIcons.bellOff;
  static const camera        = LucideIcons.camera;
  static const pdf           = LucideIcons.fileText;
  static const note          = LucideIcons.stickyNote;
  static const trash         = LucideIcons.trash2;
  static const refresh       = LucideIcons.refreshCw;

  // ── Document & Visionneuse ────────────────────────────────────────────────
  static const printer       = LucideIcons.printer;
  static const download      = LucideIcons.download;
  static const zoomIn        = LucideIcons.zoomIn;
  static const zoomOut       = LucideIcons.zoomOut;
  static const maximize      = LucideIcons.maximize2;
  static const fileCheck     = LucideIcons.fileCheck2;

  // ── Authentification & Sécurité ───────────────────────────────────────────
  static const lock          = LucideIcons.lock;
  static const eye           = LucideIcons.eye;
  static const eyeOff        = LucideIcons.eyeOff;
  static const shield        = LucideIcons.shield;
  static const shieldCheck   = LucideIcons.shieldCheck;
  static const fingerprint   = LucideIcons.fingerprint;

  // ── Préférences & Système ─────────────────────────────────────────────────
  static const moon          = LucideIcons.moon;
  static const sun           = LucideIcons.sun;
  static const globe         = LucideIcons.globe;
  static const navigation    = LucideIcons.navigation;
  static const volume2       = LucideIcons.volume2;
  static const volumeX       = LucideIcons.volumeX;
  static const smartphone    = LucideIcons.smartphone;
  static const sparkles      = LucideIcons.sparkles;
  static const sliders       = LucideIcons.sliders;
  static const cloudOff      = LucideIcons.cloudOff;

  // ── Livraison & Tournée ───────────────────────────────────────────────────
  static const route         = LucideIcons.route;
  static const mapPin        = LucideIcons.mapPin;
  static const map           = LucideIcons.map;
  static const car           = LucideIcons.car;
  static const package       = LucideIcons.package;
  static const packageCheck  = LucideIcons.packageCheck;
  static const packageX      = LucideIcons.packageX;
  static const receipt       = LucideIcons.receipt;
  static const scale         = LucideIcons.scale;
  static const wallet        = LucideIcons.wallet;
  static const clock         = LucideIcons.clock;
  static const calendar      = LucideIcons.calendar;

  // ── Statuts ───────────────────────────────────────────────────────────────
  static const error         = LucideIcons.circleX;
  static const warning       = LucideIcons.octagonAlert;
  static const success       = LucideIcons.circleCheck;
  static const pending       = LucideIcons.clock4;
  static const cancelled     = LucideIcons.ban;
  static const history       = LucideIcons.history;
  static const inbox         = LucideIcons.inbox;

  // ── Profil & Identité ─────────────────────────────────────────────────────
  static const person        = LucideIcons.user;
  static const building      = LucideIcons.building2;
  static const badge         = LucideIcons.badgeCheck;
  static const mail          = LucideIcons.mail;

  // ── Dashboard ─────────────────────────────────────────────────────────────
  static const list          = LucideIcons.list;
  static const listOrdered   = LucideIcons.listOrdered;
}
