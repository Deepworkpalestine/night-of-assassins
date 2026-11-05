import 'mafia_role.dart';
import 'player.dart';

enum GamePhase {
  seatingArrangement,
  roleDistribution,
  nightAction,
  nightResults,
  discussion,
  voting,
  voteResult,
  hunterRevenge,
  gameOver,
}

enum RoleDistributionStep {
  handoff,
  reveal,
}

class NightResult {
  final List<Player> killedPlayers;
  final List<Player> savedByDoctor;
  final Player? sacrificedBodyguard;
  final Player? protectedByBodyguard;
  final Player? silencedPlayer;

  const NightResult({
    this.killedPlayers = const [],
    this.savedByDoctor = const [],
    this.sacrificedBodyguard,
    this.protectedByBodyguard,
    this.silencedPlayer,
  });
}

class VoteResult {
  final Player? eliminatedPlayer;
  final bool wasSkipped;
  final bool wasTie;
  final Map<String, String?> votesByVoterId;

  const VoteResult({
    this.eliminatedPlayer,
    this.wasSkipped = false,
    this.wasTie = false,
    this.votesByVoterId = const {},
  });
}

class MafiaGameState {
  final GamePhase phase;
  final int currentRound;
  final List<Player> players;
  final int roleDistributionIndex;
  final RoleDistributionStep roleStep;

  final int nightActionIndex;
  final bool nightHandoffDone;
  final List<String> mafiaTargets;
  final String? doctorTarget;
  final String? lastDoctorTarget;
  final String? bodyguardTarget;
  final String? lastBodyguardTarget;
  final String? silencerTarget;
  final String? lastSilencerTarget;
  final String? detectiveTarget;
  final bool? detectiveResultIsMafia;
  final Set<String> detectiveInvestigations;
  final bool? spyChoseSpy;
  final String? spyTarget;
  final MafiaRole? spyResultRole;

  final int votingPlayerIndex;
  final bool votingHandoffDone;
  final Map<String, String?> currentVotes;
  final List<String> tiedPlayerIds;
  final bool isRevote;

  final String? hunterPlayerId;
  final NightResult? lastNightResult;
  final VoteResult? lastVoteResult;

  final RoleTeam? winner;
  final bool jesterWon;
  final bool gamblerWon;
  final Player? winningJester;
  final Player? winningGambler;

  const MafiaGameState({
    this.phase = GamePhase.seatingArrangement,
    this.currentRound = 1,
    this.players = const [],
    this.roleDistributionIndex = 0,
    this.roleStep = RoleDistributionStep.handoff,
    this.nightActionIndex = 0,
    this.nightHandoffDone = false,
    this.mafiaTargets = const [],
    this.doctorTarget,
    this.lastDoctorTarget,
    this.bodyguardTarget,
    this.lastBodyguardTarget,
    this.silencerTarget,
    this.lastSilencerTarget,
    this.detectiveTarget,
    this.detectiveResultIsMafia,
    this.detectiveInvestigations = const {},
    this.spyChoseSpy,
    this.spyTarget,
    this.spyResultRole,
    this.votingPlayerIndex = 0,
    this.votingHandoffDone = false,
    this.currentVotes = const {},
    this.tiedPlayerIds = const [],
    this.isRevote = false,
    this.hunterPlayerId,
    this.lastNightResult,
    this.lastVoteResult,
    this.winner,
    this.jesterWon = false,
    this.gamblerWon = false,
    this.winningJester,
    this.winningGambler,
  });

  List<Player> get alivePlayers => players.where((p) => p.isAlive).toList();
  List<Player> get aliveMafia =>
      players.where((p) => p.isAlive && p.isMafiaTeam).toList();
  List<Player> get aliveNonMafia =>
      players.where((p) => p.isAlive && !p.isMafiaTeam).toList();

  Player get currentRoleDistributionPlayer => players[roleDistributionIndex];
  Player get currentNightActionPlayer => alivePlayers[nightActionIndex];
  Player get currentVotingPlayer => alivePlayers[votingPlayerIndex];

  List<Player> get votablePlayers {
    if (tiedPlayerIds.isNotEmpty) {
      return alivePlayers.where((p) => tiedPlayerIds.contains(p.id)).toList();
    }
    return alivePlayers;
  }

  MafiaGameState copyWith({
    GamePhase? phase,
    int? currentRound,
    List<Player>? players,
    int? roleDistributionIndex,
    RoleDistributionStep? roleStep,
    int? nightActionIndex,
    bool? nightHandoffDone,
    List<String>? mafiaTargets,
    String? doctorTarget,
    bool clearDoctorTarget = false,
    String? lastDoctorTarget,
    String? bodyguardTarget,
    bool clearBodyguardTarget = false,
    String? lastBodyguardTarget,
    String? silencerTarget,
    bool clearSilencerTarget = false,
    String? lastSilencerTarget,
    bool clearLastSilencerTarget = false,
    String? detectiveTarget,
    bool clearDetectiveTarget = false,
    bool? detectiveResultIsMafia,
    Set<String>? detectiveInvestigations,
    bool? spyChoseSpy,
    bool clearSpyChoice = false,
    String? spyTarget,
    MafiaRole? spyResultRole,
    int? votingPlayerIndex,
    bool? votingHandoffDone,
    Map<String, String?>? currentVotes,
    List<String>? tiedPlayerIds,
    bool? isRevote,
    String? hunterPlayerId,
    NightResult? lastNightResult,
    VoteResult? lastVoteResult,
    RoleTeam? winner,
    bool? jesterWon,
    bool? gamblerWon,
    Player? winningJester,
    Player? winningGambler,
  }) {
    return MafiaGameState(
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      players: players ?? this.players,
      roleDistributionIndex: roleDistributionIndex ?? this.roleDistributionIndex,
      roleStep: roleStep ?? this.roleStep,
      nightActionIndex: nightActionIndex ?? this.nightActionIndex,
      nightHandoffDone: nightHandoffDone ?? this.nightHandoffDone,
      mafiaTargets: mafiaTargets ?? this.mafiaTargets,
      doctorTarget: clearDoctorTarget ? null : (doctorTarget ?? this.doctorTarget),
      lastDoctorTarget: lastDoctorTarget ?? this.lastDoctorTarget,
      bodyguardTarget:
          clearBodyguardTarget ? null : (bodyguardTarget ?? this.bodyguardTarget),
      lastBodyguardTarget: lastBodyguardTarget ?? this.lastBodyguardTarget,
      silencerTarget:
          clearSilencerTarget ? null : (silencerTarget ?? this.silencerTarget),
      lastSilencerTarget: clearLastSilencerTarget
          ? null
          : (lastSilencerTarget ?? this.lastSilencerTarget),
      detectiveTarget:
          clearDetectiveTarget ? null : (detectiveTarget ?? this.detectiveTarget),
      detectiveResultIsMafia:
          clearDetectiveTarget ? null : (detectiveResultIsMafia ?? this.detectiveResultIsMafia),
      detectiveInvestigations:
          detectiveInvestigations ?? this.detectiveInvestigations,
      spyChoseSpy: clearSpyChoice ? null : (spyChoseSpy ?? this.spyChoseSpy),
      spyTarget: clearSpyChoice ? null : (spyTarget ?? this.spyTarget),
      spyResultRole: clearSpyChoice ? null : (spyResultRole ?? this.spyResultRole),
      votingPlayerIndex: votingPlayerIndex ?? this.votingPlayerIndex,
      votingHandoffDone: votingHandoffDone ?? this.votingHandoffDone,
      currentVotes: currentVotes ?? this.currentVotes,
      tiedPlayerIds: tiedPlayerIds ?? this.tiedPlayerIds,
      isRevote: isRevote ?? this.isRevote,
      hunterPlayerId: hunterPlayerId ?? this.hunterPlayerId,
      lastNightResult: lastNightResult ?? this.lastNightResult,
      lastVoteResult: lastVoteResult ?? this.lastVoteResult,
      winner: winner ?? this.winner,
      jesterWon: jesterWon ?? this.jesterWon,
      gamblerWon: gamblerWon ?? this.gamblerWon,
      winningJester: winningJester ?? this.winningJester,
      winningGambler: winningGambler ?? this.winningGambler,
    );
  }
}
