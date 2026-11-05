import 'package:flutter/material.dart';

enum MafiaRole {
  citizen,
  mafia,
  doctor,
  detective,
  godfather,
  bodyguard,
  spy,
  silencer,
  hunter,
  jester,
  gambler,
}

enum RoleTeam {
  citizens,
  mafia,
  independent,
}

class MafiaRoleInfo {
  final MafiaRole role;
  final String nameAr;
  final String cardTitleAr;
  final String titleAr;
  final String emoji;
  final String shortDesc;
  final String fullDesc;
  final RoleTeam team;
  final Color color;
  final IconData icon;
  final String imageAsset;
  final bool isCitizenNightCover;

  const MafiaRoleInfo({
    required this.role,
    required this.nameAr,
    required this.cardTitleAr,
    required this.titleAr,
    required this.emoji,
    required this.shortDesc,
    required this.fullDesc,
    required this.team,
    required this.color,
    required this.icon,
    required this.imageAsset,
    this.isCitizenNightCover = false,
  });

  static const Map<MafiaRole, MafiaRoleInfo> roles = {
    MafiaRole.citizen: MafiaRoleInfo(
      role: MafiaRole.citizen,
      nameAr: 'مواطن',
      cardTitleAr: 'مواطن',
      titleAr: 'المواطن',
      emoji: '👤',
      shortDesc: 'يحاول اكتشاف المافيا من خلال النقاش والتصويت.',
      fullDesc: 'حاول اكتشاف المافيا من خلال النقاش والتصويت.',
      team: RoleTeam.citizens,
      color: Color(0xFF4CAF50),
      icon: Icons.person_outline,
      imageAsset: 'assets/images/roles/citizen.png',
      isCitizenNightCover: true,
    ),
    MafiaRole.mafia: MafiaRoleInfo(
      role: MafiaRole.mafia,
      nameAr: 'مافيا',
      cardTitleAr: 'مافيا',
      titleAr: 'المافيا',
      emoji: '🔪',
      shortDesc: 'يختار لاعب لقتله كل ليلة ويحاول إخفاء هويته أثناء النهار.',
      fullDesc: 'اختر لاعب لقتله كل ليلة واخف هويتك عن الآخرين.',
      team: RoleTeam.mafia,
      color: Color(0xFFE53E3A),
      icon: Icons.person_off_outlined,
      imageAsset: 'assets/images/roles/mafia.png',
    ),
    MafiaRole.doctor: MafiaRoleInfo(
      role: MafiaRole.doctor,
      nameAr: 'الدكتور',
      cardTitleAr: 'دكتور',
      titleAr: 'الدكتور',
      emoji: '💊',
      shortDesc: 'يحمي لاعب من القتل كل ليلة',
      fullDesc: 'يمكنك حماية لاعب واحد كل ليلة من القتل.',
      team: RoleTeam.citizens,
      color: Color(0xFF26A69A),
      icon: Icons.medical_services_outlined,
      imageAsset: 'assets/images/roles/doctor.png',
    ),
    MafiaRole.detective: MafiaRoleInfo(
      role: MafiaRole.detective,
      nameAr: 'المحقق',
      cardTitleAr: 'محقق',
      titleAr: 'المحقق',
      emoji: '🔍',
      shortDesc: 'يكشف هوية لاعب كل ليلة',
      fullDesc: 'يمكنك التحقق من هوية لاعب واحد كل ليلة.',
      team: RoleTeam.citizens,
      color: Color(0xFF42A5F5),
      icon: Icons.manage_search_rounded,
      imageAsset: 'assets/images/roles/detective.png',
    ),
    MafiaRole.godfather: MafiaRoleInfo(
      role: MafiaRole.godfather,
      nameAr: 'العراب',
      cardTitleAr: 'عراب',
      titleAr: 'العراب',
      emoji: '🎩',
      shortDesc: 'قائد المافيا يخدع المحقق',
      fullDesc:
          'قائد المافيا. لن يتمكن المحقق من كشف حقيقتك في المحاولة الأولى ويظن أنك مواطن.',
      team: RoleTeam.mafia,
      color: Color(0xFFE53E3A),
      icon: Icons.workspace_premium_outlined,
      imageAsset: 'assets/images/roles/mafia_leader.png',
    ),
    MafiaRole.bodyguard: MafiaRoleInfo(
      role: MafiaRole.bodyguard,
      nameAr: 'الحارس',
      cardTitleAr: 'حارس',
      titleAr: 'الحارس',
      emoji: '🛡️',
      shortDesc: 'يحمي لاعب ويموت بدلاً عنه',
      fullDesc:
          'كل ليلة تختار لاعب لحمايته من هجوم المافيا. اذا تم استهدافه تموت بدلاً عنه. لا يمكنك حماية نفس اللاعب ليلتين متتاليتين.',
      team: RoleTeam.citizens,
      color: Color(0xFF5C6BC0),
      icon: Icons.shield_outlined,
      imageAsset: 'assets/images/roles/bodyguard.png',
    ),
    MafiaRole.spy: MafiaRoleInfo(
      role: MafiaRole.spy,
      nameAr: 'الجاسوس',
      cardTitleAr: 'جاسوس',
      titleAr: 'الجاسوس',
      emoji: '🕵️',
      shortDesc: 'يقتل أو يتجسس كل ليلة',
      fullDesc:
          'بالإضافة لقدرتك على القتل يمكنك التجسس على أي لاعب وكشف هويته. لا يمكنك التجسس والقتل في الليلة نفسها.',
      team: RoleTeam.mafia,
      color: Color(0xFFAB47BC),
      icon: Icons.visibility_outlined,
      imageAsset: 'assets/images/roles/spy.png',
    ),
    MafiaRole.silencer: MafiaRoleInfo(
      role: MafiaRole.silencer,
      nameAr: 'الكاتم',
      cardTitleAr: 'كاتم',
      titleAr: 'الكاتم',
      emoji: '🤫',
      shortDesc: 'يسكت لاعب كل ليلة فيمنعه من الكلام',
      fullDesc:
          'عضو مافيا يسكت لاعباً كل ليلة فيمنعه من التحدث أثناء نقاش النهار. لا يمكنك إسكات نفسك ليلتين متتاليتين، وإذا كنت المافيا الوحيد يمكنك القتل والإسكات معاً.',
      team: RoleTeam.mafia,
      color: Color(0xFF8E24AA),
      icon: Icons.volume_off_outlined,
      imageAsset: 'assets/images/roles/silencer.png',
    ),
    MafiaRole.hunter: MafiaRoleInfo(
      role: MafiaRole.hunter,
      nameAr: 'الصياد',
      cardTitleAr: 'صياد',
      titleAr: 'الصياد',
      emoji: '🎯',
      shortDesc: 'ينتقم عند إقصائه بالتصويت',
      fullDesc:
          'اذا تم التصويت لإقصائك يمكنك الانتقام بإطلاق النار على لاعب قبل مغادرتك اللعبة.',
      team: RoleTeam.citizens,
      color: Color(0xFFFF7043),
      icon: Icons.gps_fixed_rounded,
      imageAsset: 'assets/images/roles/hunter.png',
      isCitizenNightCover: true,
    ),
    MafiaRole.jester: MafiaRoleInfo(
      role: MafiaRole.jester,
      nameAr: 'المهرج',
      cardTitleAr: 'مهرج',
      titleAr: 'المهرج',
      emoji: '🃏',
      shortDesc: 'يفوز اذا تم إقصاؤه بالتصويت',
      fullDesc:
          'هدفك هو أن يتم التصويت لإقصائك. اذا حدث ذلك تفوز باللعبة.',
      team: RoleTeam.independent,
      color: Color(0xFFFFCA28),
      icon: Icons.theater_comedy_outlined,
      imageAsset: 'assets/images/roles/jester.png',
      isCitizenNightCover: true,
    ),
    MafiaRole.gambler: MafiaRoleInfo(
      role: MafiaRole.gambler,
      nameAr: 'المراهن',
      cardTitleAr: 'مراهن',
      titleAr: 'المراهن',
      emoji: '🎲',
      shortDesc: 'يراهن على إقصاء لاعب بالتصويت',
      fullDesc:
          'في الليلة الأولى اختر لاعباً تراهن على إقصائه بالتصويت. اذا تم التصويت لإقصائه تفوز باللعبة.',
      team: RoleTeam.independent,
      color: Color(0xFFEC407A),
      icon: Icons.casino_outlined,
      imageAsset: 'assets/images/roles/gambler.png',
    ),
  };

  static MafiaRoleInfo of(MafiaRole role) => roles[role]!;
}
