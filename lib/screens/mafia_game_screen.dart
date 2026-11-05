import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/mafia_role.dart';
import '../providers/app_providers.dart';
import '../providers/mafia_game_notifier.dart';
import '../services/sound_service.dart';
import '../widgets/gothic_background.dart';
import '../widgets/hold_to_reveal_card.dart';

class MafiaGameScreen extends ConsumerStatefulWidget {
  const MafiaGameScreen({super.key});

  @override
  ConsumerState<MafiaGameScreen> createState() => _MafiaGameScreenState();
}

class _MafiaGameScreenState extends ConsumerState<MafiaGameScreen> {
  late ConfettiController _confettiController;
  bool _hasRevealedCurrentRole = false;
  String? _selectedNightTargetId;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4));
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _confirmExit() async {
    SoundService.playClick();
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F0C10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF47252B)),
        ),
        title: const Text(
          'الخروج من اللعبة؟',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'سيتم إنهاء اللعبة الحالية',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB8A8AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'متابعة',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'الخروج',
              style: TextStyle(
                color: Color(0xFFE53E3A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildTopGameHeader(MafiaGameState state) {
    // Matches top bar in 1000124810.jpg, 1000124811.jpg, 1000124812.jpg
    Widget? centerOrBadge;
    Widget? rightInfo;

    if (state.phase == GamePhase.nightAction && state.nightHandoffDone) {
      final player = state.currentNightActionPlayer;
      final info = player.roleInfo;
      centerOrBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF3A1519).withOpacity(0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFA5414B).withOpacity(0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌙', style: TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Text(
              'مرحلة الليل - ${info.cardTitleAr}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(info.emoji, style: const TextStyle(fontSize: 15)),
          ],
        ),
      );
    } else if (state.phase == GamePhase.discussion) {
      centerOrBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF332412).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5A93A).withOpacity(0.25)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny_rounded, size: 16, color: Color(0xFFE5A93A)),
            SizedBox(width: 6),
            Text(
              'مرحلة النقاش',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE5A93A),
              ),
            ),
          ],
        ),
      );
      rightInfo = Text(
        'الجولة ${state.currentRound}',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E8E90),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            GestureDetector(
              onTap: _confirmExit,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A151B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            if (state.phase == GamePhase.discussion && centerOrBadge != null) ...[
              const SizedBox(width: 10),
              Directionality(
                textDirection: TextDirection.rtl,
                child: centerOrBadge,
              ),
            ],
            Expanded(
              child: state.phase != GamePhase.discussion && centerOrBadge != null
                  ? Center(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: centerOrBadge,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (rightInfo != null)
              Directionality(
                textDirection: TextDirection.rtl,
                child: rightInfo,
              )
            else if (state.phase != GamePhase.discussion &&
                centerOrBadge != null)
              const SizedBox(width: 42),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mafiaGameProvider);
    final settings = ref.watch(mafiaSettingsProvider);
    final notifier = ref.read(mafiaGameProvider.notifier);

    if (state.phase == GamePhase.gameOver) {
      _confettiController.play();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _confirmExit();
      },
      child: GothicBackground(
        child: Column(
          children: [
            _buildTopGameHeader(state),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: _buildPhaseContent(context, state, settings, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseContent(
    BuildContext context,
    MafiaGameState state,
    MafiaGameSettings settings,
    MafiaGameNotifier notifier,
  ) {
    switch (state.phase) {
      case GamePhase.seatingArrangement:
        return _buildSeatingArrangement(state, notifier);
      case GamePhase.roleDistribution:
        return _buildRoleDistribution(state, notifier);
      case GamePhase.nightAction:
        return _buildNightAction(state, notifier);
      case GamePhase.nightResults:
        return _buildNightResults(state, notifier);
      case GamePhase.discussion:
        return _buildDiscussion(state, notifier);
      case GamePhase.voting:
        return _buildVoting(state, notifier);
      case GamePhase.voteResult:
        return _buildVoteResult(state, settings, notifier);
      case GamePhase.hunterRevenge:
        return _buildHunterRevenge(state, notifier);
      case GamePhase.gameOver:
        return _buildGameOver(state, notifier);
    }
  }

  // 1. Seating Arrangement (Matches 1000125506.jpg 100%)
  Widget _buildSeatingArrangement(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final count = state.players.length;
    return Column(
      children: [
        const Icon(
          Icons.groups_rounded,
          color: Color(0xFFA58238),
          size: 44,
        ),
        const SizedBox(height: 8),
        const Text(
          'ترتيب الجلسة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'اجلسوا بشكل دائري بهالترتيب عشان يسهل تمرير الجوال',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Color(0xFF9E8E90)),
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: _CirclePainter(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(count, (i) {
                      final angle = (2 * pi * i / count) - (pi / 2);
                      const radius = 110.0;
                      final dx = radius * cos(angle);
                      final dy = radius * sin(angle);
                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF4D3717),
                                border: Border.all(
                                  color: const Color(0xFFC5A049),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE6BC53),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 78,
                              child: Text(
                                state.players[i].name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C0D14),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFB5242B), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              SoundService.playClick();
              notifier.startRoleDistribution();
            },
            child: const Text(
              'ابدأ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Role Distribution (Matches 1000125508.jpg & 1000125507.jpg 100%)
  Widget _buildRoleDistribution(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final player = state.currentRoleDistributionPlayer;
    if (state.roleStep == RoleDistributionStep.handoff) {
      return Column(
        children: [
          const Spacer(),
          const Icon(
            Icons.smartphone_rounded,
            color: Color(0xFF9E7B32),
            size: 56,
          ),
          const SizedBox(height: 18),
          const Text(
            'أعط الجوال للاعب',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF9E8E90),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            player.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C0D14),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFB5242B), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  SoundService.playClick();
                  setState(() => _hasRevealedCurrentRole = false);
                  notifier.nextRoleDistribution();
                },
                child: Text(
                  'أنا ${player.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${state.players.length} / ${state.roleDistributionIndex + 1}',
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6E5D5F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Column(
      children: [
        const Spacer(),
        HoldToRevealCard(
          roleInfo: player.roleInfo,
          onRevealedOnce: () {
            if (!_hasRevealedCurrentRole) {
              SoundService.playFinish();
              setState(() => _hasRevealedCurrentRole = true);
            }
          },
        ),
        const Spacer(),
        // _RevealBottomArea: shows _InstructionText before reveal, and _NextButton ("التالي") after reveal
        SizedBox(
          height: 76,
          child: Center(
            child: !_hasRevealedCurrentRole
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swipe_up_rounded,
                        color: Color(0xFF9A7D38),
                        size: 32,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'اسحب الكرت للأعلى لمعرفة دورك',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E7B7E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF262223),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3E3738)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        SoundService.playClick();
                        notifier.nextRoleDistribution();
                      },
                      child: const Text(
                        'التالي',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // 3. Night Action (Matches 1000124812.jpg 100%)
  Widget _buildNightAction(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final player = state.currentNightActionPlayer;
    if (!state.nightHandoffDone) {
      return _buildGothicHandoffScreen(
        emoji: '🌙',
        phaseSubtitle: 'مرحلة الليل',
        instruction: 'سلّم الجوال الى',
        playerName: player.name,
        onConfirm: () {
          SoundService.playClick();
          setState(() => _selectedNightTargetId = null);
          notifier.confirmNightHandoff();
        },
      );
    }

    // Detective result screen
    if (player.role == MafiaRole.detective && state.detectiveTarget != null) {
      final target =
          state.players.firstWhere((p) => p.id == state.detectiveTarget);
      final isMafia = state.detectiveResultIsMafia ?? false;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            target.name,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: isMafia
                  ? const Color(0xFFE53E3A)
                  : const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              isMafia ? 'مافيا!' : 'ليس مافيا',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          _buildActionBtn(
            label: 'فهمت، التالي',
            onTap: () {
              SoundService.playClick();
              notifier.nextNightAction();
            },
          ),
        ],
      );
    }

    // Spy mode selection or result screen
    if (player.role == MafiaRole.spy) {
      if (state.spyChoseSpy == null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                player.roleInfo.imageAsset,
                width: 112,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر مهمتك الليلة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'لا يمكنك القتل والتجسس في نفس الليلة',
              style: TextStyle(fontSize: 13, color: Color(0xFF8E7B7E)),
            ),
            const SizedBox(height: 28),
            _buildActionBtn(
              label: 'قتل',
              onTap: () {
                SoundService.playClick();
                notifier.setSpyMode(false);
              },
            ),
            const SizedBox(height: 12),
            _buildSecondaryActionBtn(
              label: 'تجسس',
              onTap: () {
                SoundService.playClick();
                notifier.setSpyMode(true);
              },
            ),
          ],
        );
      }

      if (state.spyTarget != null && state.spyResultRole != null) {
        final target =
            state.players.firstWhere((p) => p.id == state.spyTarget);
        final roleInfo = MafiaRoleInfo.of(state.spyResultRole!);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                roleInfo.imageAsset,
                width: 128,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              target.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              roleInfo.titleAr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53E3A),
              ),
            ),
            const Spacer(),
            _buildActionBtn(
              label: 'فهمت، التالي',
              onTap: () {
                SoundService.playClick();
                notifier.nextNightAction();
              },
            ),
          ],
        );
      }
    }

    final bool isCitizenBehavior = player.roleInfo.isCitizenNightCover ||
        (player.role == MafiaRole.gambler && state.currentRound > 1);
    final bool isSilencer = player.role == MafiaRole.silencer;
    final bool isSilencerSoleMafia =
        isSilencer && state.aliveMafia.length == 1;

    String instruction = 'اختر اسمك من القائمة';
    if (isSilencerSoleMafia) {
      instruction = 'اختر لاعب لقتله (و 🤫 لإسكاته)';
    } else if (isSilencer) {
      instruction = 'اختر لاعب لإسكاته';
    } else if (player.role == MafiaRole.mafia ||
        player.role == MafiaRole.godfather ||
        (player.role == MafiaRole.spy && state.spyChoseSpy == false)) {
      instruction = 'اختر لاعب لقتله';
    } else if (player.role == MafiaRole.doctor ||
        player.role == MafiaRole.bodyguard) {
      instruction = 'اختر لاعب لحمايته';
    } else if (player.role == MafiaRole.detective) {
      instruction = 'اختر لاعب للتحقيق عنه';
    } else if (player.role == MafiaRole.spy && state.spyChoseSpy == true) {
      instruction = 'اختر لاعب للتجسس عليه';
    } else if (player.role == MafiaRole.gambler && state.currentRound == 1) {
      instruction = 'اختر لاعب تراهن على إقصائه';
    }

    final prevMafiaTarget = state.mafiaTargets.isNotEmpty
        ? state.players.firstWhere((p) => p.id == state.mafiaTargets.last)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          instruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (player.isMafiaTeam && prevMafiaTarget != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1216),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF5C2229)),
            ),
            child: Text(
              'المافيا الآخر اختار: ${prevMafiaTarget.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
        const SizedBox(height: 22),
        Expanded(
          child: ListView(
            children: state.alivePlayers.map((candidate) {
              if (isSilencerSoleMafia) {
                final bool isSelf = candidate.id == player.id;
                final bool canKillRow = !isSelf;
                final bool silenceSelfDisabled =
                    isSelf && state.lastSilencerTarget == player.id;
                final bool isSilencedSelected =
                    state.silencerTarget == candidate.id;
                final bool isKillSelected =
                    _selectedNightTargetId == candidate.id;

                return GestureDetector(
                  onTap: canKillRow
                      ? () {
                          SoundService.playClick();
                          setState(() {
                            _selectedNightTargetId =
                                isKillSelected ? null : candidate.id;
                          });
                        }
                      : null,
                  child: Container(
                    height: 58,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isKillSelected
                          ? const Color(0xFF4A151B).withOpacity(0.85)
                          : const Color(0xFF2D1A1D).withOpacity(0.62),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isKillSelected
                            ? const Color(0xFFE53E3A)
                            : isSilencedSelected
                                ? const Color(0xFFAB47BC)
                                : const Color(0xFF6E484C).withOpacity(0.38),
                        width: isKillSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: canKillRow ? 1.0 : 0.45,
                          child: Text(
                            candidate.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (silenceSelfDisabled)
                          const Text(
                            '(أسكتّ نفسك سابقاً)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8E7B7E),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              // Solution 2: Silent toggle (NO click sound!)
                              notifier.toggleSilencerTarget(candidate.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSilencedSelected
                                    ? const Color(0xFF6A1B9A)
                                    : const Color(0xFF2A1419),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSilencedSelected
                                      ? const Color(0xFFCE93D8)
                                      : const Color(0xFF4D2930),
                                ),
                              ),
                              child: Text(
                                isSilencedSelected ? '🤫 صامت' : '🤫',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }

              bool disabled = false;
              String tag = '';
              if (isCitizenBehavior && candidate.id != player.id) {
                disabled = true;
              }
              if (!isCitizenBehavior &&
                  player.role != MafiaRole.doctor &&
                  player.role != MafiaRole.silencer &&
                  candidate.id == player.id) {
                disabled = true;
              }
              if (player.role == MafiaRole.silencer &&
                  candidate.id == player.id &&
                  state.lastSilencerTarget == player.id) {
                disabled = true;
                tag = '(أسكتّ نفسك سابقاً)';
              }
              if (player.role == MafiaRole.doctor &&
                  state.lastDoctorTarget == candidate.id) {
                disabled = true;
                tag = '(حميته سابقاً)';
              }
              if (player.role == MafiaRole.bodyguard &&
                  state.lastBodyguardTarget == candidate.id) {
                disabled = true;
                tag = '(حميته سابقاً)';
              }

              final bool isSelected = _selectedNightTargetId == candidate.id;

              return Opacity(
                opacity: disabled ? 0.35 : 1.0,
                child: GestureDetector(
                  onTap: disabled
                      ? null
                      : () {
                          SoundService.playClick();
                          setState(() {
                            _selectedNightTargetId =
                                isSelected ? null : candidate.id;
                          });
                        },
                  child: Container(
                    height: 58,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A151B).withOpacity(0.85)
                          : const Color(0xFF2D1A1D).withOpacity(0.62),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE53E3A)
                            : const Color(0xFF6E484C).withOpacity(0.38),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          candidate.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (tag.isNotEmpty)
                          Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8E7B7E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedNightTargetId != null
                  ? const Color(0xFF8C0D14)
                  : const Color(0xFF232021),
              disabledBackgroundColor: const Color(0xFF232021),
              foregroundColor: Colors.white,
              disabledForegroundColor: const Color(0xFF6E6667),
              side: _selectedNightTargetId != null
                  ? const BorderSide(color: Color(0xFFB5242B), width: 1.5)
                  : BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _selectedNightTargetId == null
                ? null
                : () {
                    final chosenId = _selectedNightTargetId;
                    setState(() => _selectedNightTargetId = null);
                    SoundService.playClick();
                    notifier.performNightAction(chosenId);
                  },
            child: const Text(
              'تأكيد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Night Results
  Widget _buildNightResults(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final res = state.lastNightResult!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '🌅',
          style: TextStyle(fontSize: 52),
        ),
        const SizedBox(height: 12),
        const Text(
          'نتائج الليلة',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        if (res.killedPlayers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0D10).withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3E2429)),
            ),
            child: const Text(
              'لم يُقتل أحد الليلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        else
          ...res.killedPlayers.map(
            (p) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3D1218),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE53E3A)),
              ),
              child: Text(
                'تم قتل ${p.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ...res.savedByDoctor.map(
          (p) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0D10).withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3E2429)),
            ),
            child: Text(
              '${p.name} نجا بفضل الدكتور!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ),
        if (res.sacrificedBodyguard != null &&
            res.protectedByBodyguard != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0D10).withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3E2429)),
            ),
            child: Text(
              '${res.sacrificedBodyguard!.name} ضحى بنفسه لحماية ${res.protectedByBodyguard!.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amberAccent,
              ),
            ),
          ),
        if (res.silencedPlayer != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF28122E).withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFAB47BC)),
            ),
            child: Text(
              '🤫 تم إسكات ${res.silencedPlayer!.name} ولا يمكنه الكلام في النقاش!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE1BEE7),
              ),
            ),
          ),
        const Spacer(),
        _buildActionBtn(
          label: 'متابعة',
          onTap: () {
            SoundService.playClick();
            notifier.continueAfterNight();
          },
        ),
      ],
    );
  }

  // 5. Discussion (Matches 1000124811.jpg 100% for both Pre-Night & Post-Night!)
  Widget _buildDiscussion(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final bool isPreNight = state.lastNightResult == null;
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          '💬',
          style: TextStyle(fontSize: 52),
        ),
        const SizedBox(height: 14),
        const Text(
          'كل واحد يبرّي نفسه',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isPreNight ? 'تعرفوا على بعض قبل ما يبدأ الليل' : 'ناقشوا فيما بينكم',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Color(0xFF9E8E90)),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: ListView(
            children: state.alivePlayers
                .map(
                  (p) => Container(
                    height: 58,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          const Color(0xFF3B1519).withOpacity(0.65),
                          const Color(0xFF4A181D).withOpacity(0.45),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7A353C).withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (!isPreNight &&
                            state.lastNightResult?.silencedPlayer?.id == p.id)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A154B),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFAB47BC),
                              ),
                            ),
                            child: const Text(
                              '🤫 صامت',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE1BEE7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _buildActionBtn(
          label: isPreNight ? 'ابدأ الليل' : 'ابدأ التصويت',
          onTap: () {
            SoundService.playClick();
            if (isPreNight) {
              notifier.startNight();
            } else {
              notifier.startVoting();
            }
          },
        ),
      ],
    );
  }

  // 6. Voting
  Widget _buildVoting(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final voter = state.currentVotingPlayer;
    if (!state.votingHandoffDone) {
      return _buildGothicHandoffScreen(
        emoji: '🗳️',
        phaseSubtitle: state.isRevote ? 'إعادة التصويت' : 'مرحلة التصويت',
        instruction: 'سلّم الجوال الى',
        playerName: voter.name,
        onConfirm: () {
          SoundService.playClick();
          notifier.confirmVotingHandoff();
        },
      );
    }

    final candidates =
        state.votablePlayers.where((p) => p.id != voter.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.isRevote ? 'صوّت بين المتعادلين' : 'من تعتقدون أنه المافيا؟',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'اختر من تريد إقصاءه',
          style: TextStyle(fontSize: 14, color: Color(0xFF8E7B7E)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: candidates
                .map(
                  (c) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0D10).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3E2429)),
                    ),
                    child: ListTile(
                      title: Text(
                        c.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: const Text(
                        'تصويت',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53E3A),
                        ),
                      ),
                      onTap: () {
                        SoundService.playClick();
                        notifier.castVote(c.id);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        _buildSecondaryActionBtn(
          label: 'تخطي التصويت',
          onTap: () {
            SoundService.playClick();
            notifier.castVote(null);
          },
        ),
      ],
    );
  }

  // 7. Vote Result
  Widget _buildVoteResult(
    MafiaGameState state,
    MafiaGameSettings settings,
    MafiaGameNotifier notifier,
  ) {
    final res = state.lastVoteResult!;
    final eliminated = res.eliminatedPlayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (res.wasSkipped)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0D10).withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3E2429)),
            ),
            child: const Text(
              'تم تخطي التصويت! لم يتم إقصاء أحد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        else if (res.wasTie)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B0D10).withOpacity(0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3E2429)),
            ),
            child: const Text(
              'تعادل! لم يتم إقصاء أحد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        else if (eliminated != null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF3D1218),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE53E3A)),
            ),
            child: Column(
              children: [
                const Text(
                  'تم إقصاء',
                  style: TextStyle(fontSize: 13, color: Color(0xFFB8A8AA)),
                ),
                const SizedBox(height: 4),
                Text(
                  eliminated.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (settings.revealEliminatedRole) ...[
                  const SizedBox(height: 8),
                  Text(
                    eliminated.roleInfo.titleAr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53E3A),
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (settings.showVoteDetails) ...[
          const Text(
            'تفاصيل التصويت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: _buildGroupedVotes(state, res),
            ),
          ),
        ] else
          const Spacer(),
        _buildActionBtn(
          label: 'متابعة',
          onTap: () {
            SoundService.playClick();
            notifier.continueAfterVote();
          },
        ),
      ],
    );
  }

  List<Widget> _buildGroupedVotes(MafiaGameState state, VoteResult res) {
    final Map<String, List<String>> grouped = {};
    final List<String> skippedVoters = [];

    for (final entry in res.votesByVoterId.entries) {
      final voterName =
          state.players.firstWhere((p) => p.id == entry.key).name;
      if (entry.value == null) {
        skippedVoters.add(voterName);
      } else {
        grouped.putIfAbsent(entry.value!, () => []).add(voterName);
      }
    }

    final sortedTargets = grouped.keys.toList()
      ..sort((a, b) => grouped[b]!.length.compareTo(grouped[a]!.length));

    final List<Widget> widgets = [];
    for (final targetId in sortedTargets) {
      final targetName =
          state.players.firstWhere((p) => p.id == targetId).name;
      final voters = grouped[targetId]!;
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B0D10).withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3E2429)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    targetName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53E3A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${voters.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'صوّت له: ${voters.join('، ')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB8A8AA),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (skippedVoters.isNotEmpty) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1B0D10).withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF3E2429)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تخطي التصويت',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFFB8A8AA),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF382327),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${skippedVoters.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                skippedVoters.join('، '),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E7B7E),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  // 8. Hunter Revenge
  Widget _buildHunterRevenge(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    final hunter =
        state.players.firstWhere((p) => p.id == state.hunterPlayerId);
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            hunter.roleInfo.imageAsset,
            width: 112,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'الصياد ينتقم! (${hunter.name})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'يختار لاعب لإطلاق النار عليه',
          style: TextStyle(fontSize: 14, color: Color(0xFF8E7B7E)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: state.alivePlayers
                .map(
                  (c) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0D10).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3E2429)),
                    ),
                    child: ListTile(
                      title: Text(
                        c.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      trailing: const Text(
                        'إطلاق النار',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE53E3A),
                        ),
                      ),
                      onTap: () {
                        SoundService.playFailed();
                        notifier.performHunterRevenge(c.id);
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // 9. Game Over
  Widget _buildGameOver(
    MafiaGameState state,
    MafiaGameNotifier notifier,
  ) {
    String headline = '';
    if (state.jesterWon) {
      headline = 'المهرج فاز!';
    } else if (state.winner == RoleTeam.citizens) {
      headline = 'فاز المواطنون!';
    } else {
      headline = 'فازت المافيا!';
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'مبروك!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'عدد الجولات: ${state.currentRound}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8E7B7E)),
            ),
            if (state.gamblerWon && state.winningGambler != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF381428),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.4)),
                ),
                child: Text(
                  'المراهن (${state.winningGambler!.name}) فاز أيضاً!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'الأدوار',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: state.players.map((p) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0D10).withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF3E2429)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                p.roleInfo.imageAsset,
                                width: 40,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          p.roleInfo.titleAr,
                          style: const TextStyle(
                            color: Color(0xFFE53E3A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            _buildActionBtn(
              label: 'إعادة اللعب',
              onTap: () {
                SoundService.playClick();
                notifier.initializeGame(
                  state.players.map((p) => p.name).toList(),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSecondaryActionBtn(
              label: 'العودة للصفحة الرئيسية',
              onTap: () {
                SoundService.playClick();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  // Matches 1000124812.jpg 100% (Centered moon/icon + phase subtitle + "سلّم الجوال الى" + player name + compact centered button "أنا X")
  Widget _buildGothicHandoffScreen({
    required String emoji,
    required String phaseSubtitle,
    required String instruction,
    required String playerName,
    required VoidCallback onConfirm,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 14),
          Text(
            phaseSubtitle,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF9E8E90),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFFC8B6B9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            playerName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onConfirm,
              child: Text(
                'أنا $playerName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53E3A),
          disabledBackgroundColor: const Color(0xFFE53E3A).withOpacity(0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF1B0D10).withOpacity(0.92),
          side: const BorderSide(color: Color(0xFF3E2429)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 118.0;
    final paint = Paint()
      ..color = const Color(0xFFE53E3A).withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
