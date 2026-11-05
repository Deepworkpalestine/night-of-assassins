import 'package:flutter_test/flutter_test.dart';
import 'package:night_of_assassins/models/mafia_role.dart';

void main() {
  group('MafiaRoleInfo', () {
    test('defines information for every role', () {
      expect(MafiaRoleInfo.roles.keys.toSet(), MafiaRole.values.toSet());

      for (final role in MafiaRole.values) {
        final info = MafiaRoleInfo.of(role);
        expect(info.role, role);
        expect(info.nameAr, isNotEmpty);
        expect(info.shortDesc, isNotEmpty);
        expect(info.imageAsset, startsWith('assets/images/roles/'));
      }
    });

    test('assigns the expected teams to core roles', () {
      expect(MafiaRoleInfo.of(MafiaRole.citizen).team, RoleTeam.citizens);
      expect(MafiaRoleInfo.of(MafiaRole.doctor).team, RoleTeam.citizens);
      expect(MafiaRoleInfo.of(MafiaRole.mafia).team, RoleTeam.mafia);
      expect(MafiaRoleInfo.of(MafiaRole.godfather).team, RoleTeam.mafia);
      expect(MafiaRoleInfo.of(MafiaRole.spy).team, RoleTeam.mafia);
      expect(MafiaRoleInfo.of(MafiaRole.silencer).team, RoleTeam.mafia);
      expect(MafiaRoleInfo.of(MafiaRole.jester).team, RoleTeam.independent);
      expect(MafiaRoleInfo.of(MafiaRole.gambler).team, RoleTeam.independent);
    });
  });
}
