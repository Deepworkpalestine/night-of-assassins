import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import 'mafia_game_notifier.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

final soundServiceProvider = Provider<SoundService>((ref) {
  return SoundService();
});

class MafiaSettingsNotifier extends StateNotifier<MafiaGameSettings> {
  MafiaSettingsNotifier() : super(const MafiaGameSettings());

  void setPlayerCount(int count) {
    state = state.copyWith(playerCount: count.clamp(4, 50));
  }

  void setMafiaCount(int count) {
    state = state.copyWith(mafiaCount: count);
  }

  void setKillsPerNight(int kills) {
    state = state.copyWith(killsPerNight: kills);
  }

  void toggleDoctor(bool val) => state = state.copyWith(hasDoctor: val);
  void toggleDetective(bool val) => state = state.copyWith(hasDetective: val);
  void toggleGodfather(bool val) => state = state.copyWith(hasGodfather: val);
  void toggleBodyguard(bool val) => state = state.copyWith(hasBodyguard: val);
  void toggleSpy(bool val) => state = state.copyWith(hasSpy: val);
  void toggleSilencer(bool val) => state = state.copyWith(hasSilencer: val);
  void toggleHunter(bool val) => state = state.copyWith(hasHunter: val);
  void toggleJester(bool val) => state = state.copyWith(hasJester: val);
  void toggleGambler(bool val) => state = state.copyWith(hasGambler: val);
  void toggleRevealEliminatedRole(bool val) =>
      state = state.copyWith(revealEliminatedRole: val);
  void toggleShowVoteDetails(bool val) =>
      state = state.copyWith(showVoteDetails: val);
}

final mafiaSettingsProvider =
    StateNotifierProvider<MafiaSettingsNotifier, MafiaGameSettings>((ref) {
  return MafiaSettingsNotifier();
});

class PlayerNamesNotifier extends StateNotifier<List<String>> {
  final SharedPreferences prefs;
  static const _storageKey = 'saved_player_names';

  PlayerNamesNotifier(this.prefs) : super(prefs.getStringList(_storageKey) ?? []);

  void saveNames(List<String> names) {
    state = names;
    prefs.setStringList(_storageKey, names);
  }
}

final playerNamesProvider =
    StateNotifierProvider<PlayerNamesNotifier, List<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PlayerNamesNotifier(prefs);
});

final mafiaGameProvider =
    StateNotifierProvider<MafiaGameNotifier, MafiaGameState>((ref) {
  final settings = ref.watch(mafiaSettingsProvider);
  return MafiaGameNotifier(settings: settings);
});
