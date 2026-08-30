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
  static const alertTriangle = LucideIcons.triangleAlert;
  static const info          = LucideIcons.info;
  static const logout        = LucideIcons.logOut;
  static const settings      = LucideIcons.settings;
  static const help          = LucideIcons.helpCircle;
  static const notification  = LucideIcons.bell;
  static const camera        = LucideIcons.camera;
  static const pdf           = LucideIcons.fileText;
  static const note          = LucideIcons.stickyNote;

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
