import 'mafia_role.dart';

class Player {
  final String id;
  final String name;
  final MafiaRole role;
  final bool isAlive;
  final String? gamblerTargetId;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    this.isAlive = true,
    this.gamblerTargetId,
  });

  MafiaRoleInfo get roleInfo => MafiaRoleInfo.of(role);

  bool get isMafiaTeam => roleInfo.team == RoleTeam.mafia;
  bool get isCitizenTeam => roleInfo.team == RoleTeam.citizens;
  bool get isIndependent => roleInfo.team == RoleTeam.independent;

  Player copyWith({
    String? id,
    String? name,
    MafiaRole? role,
    bool? isAlive,
    String? gamblerTargetId,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isAlive: isAlive ?? this.isAlive,
      gamblerTargetId: gamblerTargetId ?? this.gamblerTargetId,
    );
  }
}
