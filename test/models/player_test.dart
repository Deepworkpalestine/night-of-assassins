import 'package:flutter_test/flutter_test.dart';
import 'package:night_of_assassins/models/mafia_role.dart';
import 'package:night_of_assassins/models/player.dart';

void main() {
  group('Player', () {
    test('identifies team membership from the assigned role', () {
      const mafia = Player(id: '1', name: 'Mafia', role: MafiaRole.godfather);
      const citizen = Player(id: '2', name: 'Citizen', role: MafiaRole.doctor);
      const independent = Player(id: '3', name: 'Jester', role: MafiaRole.jester);

      expect(mafia.isMafiaTeam, isTrue);
      expect(mafia.isCitizenTeam, isFalse);
      expect(citizen.isCitizenTeam, isTrue);
      expect(independent.isIndependent, isTrue);
    });

    test('copyWith preserves unchanged values and updates requested values', () {
      const original = Player(
        id: 'player_1',
        name: 'A',
        role: MafiaRole.citizen,
      );

      final updated = original.copyWith(name: 'B', isAlive: false);

      expect(updated.id, original.id);
      expect(updated.name, 'B');
      expect(updated.role, original.role);
      expect(updated.isAlive, isFalse);
    });
  });
}
