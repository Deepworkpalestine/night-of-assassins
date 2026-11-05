import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/mafia_role.dart';
import '../models/player.dart';

class MafiaGameNotifier extends StateNotifier<MafiaGameState> {
  final MafiaGameSettings settings;
  final Random _random = Random();

  MafiaGameNotifier({required this.settings}) : super(const MafiaGameState());

  void initializeGame(List<String> playerNames) {
    final List<MafiaRole> rolePool = [];

    // 1. Assign Mafia Team roles (Special Mafia roles count within mafiaCount!)
    int remainingMafia = settings.mafiaCount;
    if (settings.hasGodfather && remainingMafia > 0) {
      rolePool.add(MafiaRole.godfather);
      remainingMafia--;
    }
    if (settings.hasSpy && remainingMafia > 0) {
      rolePool.add(MafiaRole.spy);
      remainingMafia--;
    }
    if (settings.hasSilencer && remainingMafia > 0) {
      rolePool.add(MafiaRole.silencer);
      remainingMafia--;
    }
    for (int i = 0; i < remainingMafia; i++) {
      rolePool.add(MafiaRole.mafia);
    }

    // 2. Assign Citizen Special & Independent roles
    if (settings.hasDoctor) rolePool.add(MafiaRole.doctor);
    if (settings.hasDetective) rolePool.add(MafiaRole.detective);
    if (settings.hasBodyguard) rolePool.add(MafiaRole.bodyguard);
    if (settings.hasHunter) rolePool.add(MafiaRole.hunter);
    if (settings.hasJester) rolePool.add(MafiaRole.jester);
    if (settings.hasGambler) rolePool.add(MafiaRole.gambler);

    // 3. Fill remaining slots with Citizens
    while (rolePool.length < playerNames.length) {
      rolePool.add(MafiaRole.citizen);
    }
    if (rolePool.length > playerNames.length) {
      rolePool.length = playerNames.length;
    }

    rolePool.shuffle(_random);

    final players = List<Player>.generate(
      playerNames.length,
      (i) => Player(
        id: 'player_$i',
        name: playerNames[i],
        role: rolePool[i],
      ),
    );

    state = MafiaGameState(
      phase: GamePhase.seatingArrangement,
      currentRound: 1,
      players: players,
    );
  }

  void startRoleDistribution() {
    state = state.copyWith(
      phase: GamePhase.roleDistribution,
      roleDistributionIndex: 0,
      roleStep: RoleDistributionStep.handoff,
    );
  }

  void nextRoleDistribution() {
    if (state.roleStep == RoleDistributionStep.handoff) {
      state = state.copyWith(roleStep: RoleDistributionStep.reveal);
    } else {
      if (state.roleDistributionIndex + 1 < state.players.length) {
        state = state.copyWith(
          roleDistributionIndex: state.roleDistributionIndex + 1,
          roleStep: RoleDistributionStep.handoff,
        );
      } else {
        // After all players reveal their roles in Round 1, enter pre-night discussion (1000124811.jpg)
        state = state.copyWith(phase: GamePhase.discussion);
      }
    }
  }

  void startNight() {
    state = state.copyWith(
      phase: GamePhase.nightAction,
      nightActionIndex: 0,
      nightHandoffDone: false,
      mafiaTargets: [],
      clearDoctorTarget: true,
      clearBodyguardTarget: true,
      clearSilencerTarget: true,
      clearDetectiveTarget: true,
      clearSpyChoice: true,
    );
  }

  void confirmNightHandoff() {
    state = state.copyWith(nightHandoffDone: true);
  }

  void setSpyMode(bool choseSpy) {
    state = state.copyWith(spyChoseSpy: choseSpy);
  }

  /// Toggles the Silencer's target silently (Solution 2 when Silencer is sole surviving Mafia).
  void toggleSilencerTarget(String targetPlayerId) {
    if (state.silencerTarget == targetPlayerId) {
      state = state.copyWith(clearSilencerTarget: true);
    } else {
      state = state.copyWith(silencerTarget: targetPlayerId);
    }
  }

  void performNightAction(String? targetPlayerId) {
    final currentPlayer = state.currentNightActionPlayer;
    final role = currentPlayer.role;

    if (role == MafiaRole.mafia || role == MafiaRole.godfather) {
      final updatedTargets = List<String>.from(state.mafiaTargets);
      if (targetPlayerId != null) {
        updatedTargets.add(targetPlayerId);
      }
      state = state.copyWith(mafiaTargets: updatedTargets);
      nextNightAction();
      return;
    }

    if (role == MafiaRole.silencer) {
      final bool isSoleMafia = state.aliveMafia.length == 1;
      if (isSoleMafia) {
        // Solution 2: Silencer pre-toggled 🤫 silently (or left it empty) and now tapped a player to kill
        final updatedTargets = List<String>.from(state.mafiaTargets);
        if (targetPlayerId != null) {
          updatedTargets.add(targetPlayerId);
        }
        state = state.copyWith(mafiaTargets: updatedTargets);
        nextNightAction();
      } else {
        // Other Mafia members exist: Silencer's task is silencing only
        state = state.copyWith(
          silencerTarget: targetPlayerId,
          clearSilencerTarget: targetPlayerId == null,
        );
        nextNightAction();
      }
      return;
    }

    if (role == MafiaRole.spy) {
      if (state.spyChoseSpy == true && targetPlayerId != null) {
        final target = state.players.firstWhere((p) => p.id == targetPlayerId);
        state = state.copyWith(
          spyTarget: targetPlayerId,
          spyResultRole: target.role,
        );
      } else {
        final updatedTargets = List<String>.from(state.mafiaTargets);
        if (targetPlayerId != null) {
          updatedTargets.add(targetPlayerId);
        }
        state = state.copyWith(mafiaTargets: updatedTargets);
        nextNightAction();
      }
      return;
    }

    if (role == MafiaRole.doctor) {
      state = state.copyWith(doctorTarget: targetPlayerId);
      nextNightAction();
      return;
    }

    if (role == MafiaRole.bodyguard) {
      state = state.copyWith(bodyguardTarget: targetPlayerId);
      nextNightAction();
      return;
    }

    if (role == MafiaRole.detective && targetPlayerId != null) {
      final target = state.players.firstWhere((p) => p.id == targetPlayerId);
      final updatedHistory = Set<String>.from(state.detectiveInvestigations);
      bool isMafiaResult = target.isMafiaTeam;

      // العراب يخدع المحقق في المرة الأولى فقط
      if (target.role == MafiaRole.godfather &&
          !updatedHistory.contains(target.id)) {
        isMafiaResult = false;
      }
      updatedHistory.add(target.id);

      state = state.copyWith(
        detectiveTarget: targetPlayerId,
        detectiveResultIsMafia: isMafiaResult,
        detectiveInvestigations: updatedHistory,
      );
      return;
    }

    if (role == MafiaRole.gambler && state.currentRound == 1 && targetPlayerId != null) {
      final updatedPlayers = state.players.map((p) {
        if (p.id == currentPlayer.id) {
          return p.copyWith(gamblerTargetId: targetPlayerId);
        }
        return p;
      }).toList();
      state = state.copyWith(players: updatedPlayers);
      nextNightAction();
      return;
    }

    // Citizen, Hunter, Jester, or Gambler in rounds > 1
    nextNightAction();
  }

  void nextNightAction() {
    if (state.nightActionIndex + 1 < state.alivePlayers.length) {
      state = state.copyWith(
        nightActionIndex: state.nightActionIndex + 1,
        nightHandoffDone: false,
        clearDetectiveTarget: true,
        clearSpyChoice: true,
      );
    } else {
      resolveNight();
    }
  }

  void resolveNight() {
    final List<Player> killed = [];
    final List<Player> savedByDoc = [];
    Player? sacrificedBg;
    Player? protectedByBg;

    // Count Mafia target votes and select up to killsPerNight targets
    final Map<String, int> targetCounts = {};
    for (final t in state.mafiaTargets) {
      targetCounts[t] = (targetCounts[t] ?? 0) + 1;
    }
    final sortedTargets = targetCounts.keys.toList()
      ..sort((a, b) => targetCounts[b]!.compareTo(targetCounts[a]!));
    final chosenTargets = sortedTargets.take(settings.killsPerNight).toList();

    List<Player> updatedPlayers = List<Player>.from(state.players);

    for (final targetId in chosenTargets) {
      final targetPlayer = updatedPlayers.firstWhere((p) => p.id == targetId);

      if (state.doctorTarget == targetId) {
        savedByDoc.add(targetPlayer);
      } else if (state.bodyguardTarget == targetId) {
        final bgIndex = updatedPlayers.indexWhere(
          (p) => p.isAlive && p.role == MafiaRole.bodyguard,
        );
        if (bgIndex != -1) {
          final bgPlayer = updatedPlayers[bgIndex];
          sacrificedBg = bgPlayer;
          protectedByBg = targetPlayer;
          updatedPlayers[bgIndex] = bgPlayer.copyWith(isAlive: false);
          killed.add(bgPlayer);
        } else {
          final idx = updatedPlayers.indexWhere((p) => p.id == targetId);
          updatedPlayers[idx] = targetPlayer.copyWith(isAlive: false);
          killed.add(targetPlayer);
        }
      } else {
        final idx = updatedPlayers.indexWhere((p) => p.id == targetId);
        updatedPlayers[idx] = targetPlayer.copyWith(isAlive: false);
        killed.add(targetPlayer);
      }
    }

    Player? silencedPlayer;
    if (state.silencerTarget != null) {
      final sIdx = updatedPlayers.indexWhere(
        (p) => p.id == state.silencerTarget && p.isAlive,
      );
      if (sIdx != -1) {
        silencedPlayer = updatedPlayers[sIdx];
      }
    }

    state = state.copyWith(
      phase: GamePhase.nightResults,
      players: updatedPlayers,
      lastDoctorTarget: state.doctorTarget,
      lastBodyguardTarget: state.bodyguardTarget,
      lastSilencerTarget: state.silencerTarget,
      clearLastSilencerTarget: state.silencerTarget == null,
      lastNightResult: NightResult(
        killedPlayers: killed,
        savedByDoctor: savedByDoc,
        sacrificedBodyguard: sacrificedBg,
        protectedByBodyguard: protectedByBg,
        silencedPlayer: silencedPlayer,
      ),
    );
  }

  void continueAfterNight() {
    if (_checkTeamWinConditions()) return;
    state = state.copyWith(phase: GamePhase.discussion);
  }

  void startVoting({List<String> tiedIds = const [], bool isRevote = false}) {
    state = state.copyWith(
      phase: GamePhase.voting,
      votingPlayerIndex: 0,
      votingHandoffDone: false,
      currentVotes: {},
      tiedPlayerIds: tiedIds,
      isRevote: isRevote,
    );
  }

  void confirmVotingHandoff() {
    state = state.copyWith(votingHandoffDone: true);
  }

  void castVote(String? votedPlayerId) {
    final voter = state.currentVotingPlayer;
    final updatedVotes = Map<String, String?>.from(state.currentVotes);
    updatedVotes[voter.id] = votedPlayerId;

    if (state.votingPlayerIndex + 1 < state.alivePlayers.length) {
      state = state.copyWith(
        currentVotes: updatedVotes,
        votingPlayerIndex: state.votingPlayerIndex + 1,
        votingHandoffDone: false,
      );
    } else {
      state = state.copyWith(currentVotes: updatedVotes);
      _resolveVotes();
    }
  }

  void _resolveVotes() {
    int skipCount = 0;
    final Map<String, int> tallies = {};

    for (final entry in state.currentVotes.entries) {
      final targetId = entry.value;
      if (targetId == null) {
        skipCount++;
      } else {
        tallies[targetId] = (tallies[targetId] ?? 0) + 1;
      }
    }

    int highestVotes = 0;
    for (final c in tallies.values) {
      if (c > highestVotes) highestVotes = c;
    }

    if (skipCount > highestVotes || highestVotes == 0) {
      state = state.copyWith(
        phase: GamePhase.voteResult,
        lastVoteResult: VoteResult(
          wasSkipped: true,
          votesByVoterId: state.currentVotes,
        ),
      );
      return;
    }

    final topCandidates = tallies.entries
        .where((e) => e.value == highestVotes)
        .map((e) => e.key)
        .toList();

    if (topCandidates.length > 1) {
      if (!state.isRevote) {
        startVoting(tiedIds: topCandidates, isRevote: true);
        return;
      } else {
        state = state.copyWith(
          phase: GamePhase.voteResult,
          tiedPlayerIds: [],
          isRevote: false,
          lastVoteResult: VoteResult(
            wasTie: true,
            votesByVoterId: state.currentVotes,
          ),
        );
        return;
      }
    }

    final eliminatedId = topCandidates.first;
    _eliminateByVote(eliminatedId);
  }

  void _eliminateByVote(String eliminatedId) {
    final target = state.players.firstWhere((p) => p.id == eliminatedId);
    final updatedPlayers = state.players.map((p) {
      if (p.id == eliminatedId) return p.copyWith(isAlive: false);
      return p;
    }).toList();

    bool gamblerTriggered = state.gamblerWon;
    Player? winningGambler = state.winningGambler;
    for (final p in updatedPlayers) {
      if (p.role == MafiaRole.gambler && p.gamblerTargetId == eliminatedId) {
        gamblerTriggered = true;
        winningGambler = p;
      }
    }

    final bool isJester = target.role == MafiaRole.jester;

    state = state.copyWith(
      phase: GamePhase.voteResult,
      players: updatedPlayers,
      tiedPlayerIds: [],
      isRevote: false,
      jesterWon: isJester ? true : state.jesterWon,
      winningJester: isJester ? target : state.winningJester,
      gamblerWon: gamblerTriggered,
      winningGambler: winningGambler,
      lastVoteResult: VoteResult(
        eliminatedPlayer: target,
        votesByVoterId: state.currentVotes,
      ),
    );
  }

  void continueAfterVote() {
    if (state.jesterWon) {
      state = state.copyWith(
        phase: GamePhase.gameOver,
        winner: RoleTeam.independent,
      );
      return;
    }

    final eliminated = state.lastVoteResult?.eliminatedPlayer;
    if (eliminated != null &&
        eliminated.role == MafiaRole.hunter &&
        state.alivePlayers.isNotEmpty) {
      state = state.copyWith(
        phase: GamePhase.hunterRevenge,
        hunterPlayerId: eliminated.id,
      );
      return;
    }

    if (_checkTeamWinConditions()) return;

    state = state.copyWith(
      currentRound: state.currentRound + 1,
    );
    startNight();
  }

  void performHunterRevenge(String targetPlayerId) {
    final updatedPlayers = state.players.map((p) {
      if (p.id == targetPlayerId) return p.copyWith(isAlive: false);
      return p;
    }).toList();

    state = state.copyWith(players: updatedPlayers);
    if (_checkTeamWinConditions()) return;

    state = state.copyWith(
      currentRound: state.currentRound + 1,
    );
    startNight();
  }

  bool _checkTeamWinConditions() {
    final mafiaAlive = state.aliveMafia.length;
    final nonMafiaAlive = state.aliveNonMafia.length;

    if (mafiaAlive == 0) {
      state = state.copyWith(
        phase: GamePhase.gameOver,
        winner: RoleTeam.citizens,
      );
      return true;
    }

    if (mafiaAlive >= nonMafiaAlive) {
      state = state.copyWith(
        phase: GamePhase.gameOver,
        winner: RoleTeam.mafia,
      );
      return true;
    }

    return false;
  }
}
