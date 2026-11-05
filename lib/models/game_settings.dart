import 'dart:math';

class MafiaGameSettings {
  final int playerCount;
  final int mafiaCount;
  final int killsPerNight;
  final bool hasDoctor;
  final bool hasDetective;
  final bool hasGodfather;
  final bool hasBodyguard;
  final bool hasSpy;
  final bool hasSilencer;
  final bool hasHunter;
  final bool hasJester;
  final bool hasGambler;
  final bool revealEliminatedRole;
  final bool showVoteDetails;

  const MafiaGameSettings({
    this.playerCount = 6,
    this.mafiaCount = 1,
    this.killsPerNight = 1,
    this.hasDoctor = false,
    this.hasDetective = false,
    this.hasGodfather = false,
    this.hasBodyguard = false,
    this.hasSpy = false,
    this.hasSilencer = false,
    this.hasHunter = false,
    this.hasJester = false,
    this.hasGambler = false,
    this.revealEliminatedRole = true,
    this.showVoteDetails = true,
  });

  int get selectedSpecialMafiaCount {
    return (hasGodfather ? 1 : 0) +
        (hasSpy ? 1 : 0) +
        (hasSilencer ? 1 : 0);
  }

  int get selectedNonMafiaSpecialCount {
    return (hasDoctor ? 1 : 0) +
        (hasDetective ? 1 : 0) +
        (hasBodyguard ? 1 : 0) +
        (hasHunter ? 1 : 0) +
        (hasJester ? 1 : 0) +
        (hasGambler ? 1 : 0);
  }

  int get selectedSpecialRolesCount {
    return selectedSpecialMafiaCount + selectedNonMafiaSpecialCount;
  }

  int get maxMafia {
    return max(1, (playerCount - selectedNonMafiaSpecialCount) ~/ 2);
  }

  static int maxMafiaForPlayerCount(int count, [int nonMafiaSpecials = 0]) {
    return max(1, (count - nonMafiaSpecials) ~/ 2);
  }

  int get totalMafiaTeamCount {
    return max(mafiaCount, selectedSpecialMafiaCount);
  }

  int get minimumRequiredPlayers {
    return max(4, totalMafiaTeamCount + selectedNonMafiaSpecialCount + 1);
  }

  MafiaGameSettings copyWith({
    int? playerCount,
    int? mafiaCount,
    int? killsPerNight,
    bool? hasDoctor,
    bool? hasDetective,
    bool? hasGodfather,
    bool? hasBodyguard,
    bool? hasSpy,
    bool? hasSilencer,
    bool? hasHunter,
    bool? hasJester,
    bool? hasGambler,
    bool? revealEliminatedRole,
    bool? showVoteDetails,
  }) {
    final newPlayerCount = playerCount ?? this.playerCount;
    final newHasDoctor = hasDoctor ?? this.hasDoctor;
    final newHasDetective = hasDetective ?? this.hasDetective;
    final newHasGodfather = hasGodfather ?? this.hasGodfather;
    final newHasBodyguard = hasBodyguard ?? this.hasBodyguard;
    final newHasSpy = hasSpy ?? this.hasSpy;
    final newHasSilencer = hasSilencer ?? this.hasSilencer;
    final newHasHunter = hasHunter ?? this.hasHunter;
    final newHasJester = hasJester ?? this.hasJester;
    final newHasGambler = hasGambler ?? this.hasGambler;

    final newSpecialMafiaCount = (newHasGodfather ? 1 : 0) +
        (newHasSpy ? 1 : 0) +
        (newHasSilencer ? 1 : 0);

    final newNonMafiaSpecialCount = (newHasDoctor ? 1 : 0) +
        (newHasDetective ? 1 : 0) +
        (newHasBodyguard ? 1 : 0) +
        (newHasHunter ? 1 : 0) +
        (newHasJester ? 1 : 0) +
        (newHasGambler ? 1 : 0);

    final dynamicMaxMafia =
        max(1, (newPlayerCount - newNonMafiaSpecialCount) ~/ 2);
    final minMafiaRequired = max(1, newSpecialMafiaCount);
    final rawMafia = mafiaCount ?? max(this.mafiaCount, minMafiaRequired);
    final effectiveMin = min(minMafiaRequired, dynamicMaxMafia);
    final clampedMafia = rawMafia.clamp(effectiveMin, dynamicMaxMafia);
    final clampedKills =
        (killsPerNight ?? this.killsPerNight).clamp(1, clampedMafia);

    return MafiaGameSettings(
      playerCount: newPlayerCount,
      mafiaCount: clampedMafia,
      killsPerNight: clampedKills,
      hasDoctor: newHasDoctor,
      hasDetective: newHasDetective,
      hasGodfather: newHasGodfather,
      hasBodyguard: newHasBodyguard,
      hasSpy: newHasSpy,
      hasSilencer: newHasSilencer,
      hasHunter: newHasHunter,
      hasJester: newHasJester,
      hasGambler: newHasGambler,
      revealEliminatedRole: revealEliminatedRole ?? this.revealEliminatedRole,
      showVoteDetails: showVoteDetails ?? this.showVoteDetails,
    );
  }
}
