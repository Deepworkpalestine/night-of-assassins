import 'package:flutter_test/flutter_test.dart';
import 'package:night_of_assassins/models/game_settings.dart';

void main() {
  group('MafiaGameSettings', () {
    test('provides sensible defaults', () {
      const settings = MafiaGameSettings();

      expect(settings.playerCount, 6);
      expect(settings.mafiaCount, 1);
      expect(settings.killsPerNight, 1);
      expect(settings.minimumRequiredPlayers, 4);
      expect(settings.selectedSpecialRolesCount, 0);
    });

    test('counts selected special roles by team', () {
      const settings = MafiaGameSettings(
        hasDoctor: true,
        hasGodfather: true,
        hasJester: true,
      );

      expect(settings.selectedSpecialMafiaCount, 1);
      expect(settings.selectedNonMafiaSpecialCount, 2);
      expect(settings.selectedSpecialRolesCount, 3);
      expect(settings.totalMafiaTeamCount, 1);
    });

    test('calculates the maximum Mafia count after special citizen roles', () {
      const settings = MafiaGameSettings(
        playerCount: 10,
        hasDoctor: true,
        hasJester: true,
      );

      expect(settings.maxMafia, 4);
      expect(MafiaGameSettings.maxMafiaForPlayerCount(10, 2), 4);
    });

    test('keeps enough Mafia members for selected Mafia specialties', () {
      final settings = const MafiaGameSettings().copyWith(
        hasGodfather: true,
        hasSpy: true,
      );

      expect(settings.mafiaCount, 2);
      expect(settings.selectedSpecialMafiaCount, 2);
    });

    test('does not allow more nightly kills than Mafia members', () {
      final settings = const MafiaGameSettings(
        playerCount: 10,
        mafiaCount: 3,
      ).copyWith(killsPerNight: 9);

      expect(settings.killsPerNight, 3);
    });
  });
}
