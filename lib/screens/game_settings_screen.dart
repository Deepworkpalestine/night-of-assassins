import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mafia_role.dart';
import '../providers/app_providers.dart';
import '../widgets/gothic_background.dart';
import 'player_entry_screen.dart';

class GameSettingsScreen extends ConsumerStatefulWidget {
  const GameSettingsScreen({super.key});

  @override
  ConsumerState<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends ConsumerState<GameSettingsScreen> {
  bool _showExpandedNumbers = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(mafiaSettingsProvider);
    final notifier = ref.read(mafiaSettingsProvider.notifier);
    final maxMafia = settings.maxMafia;

    return GothicBackground(
      appBar: AppBar(
        backgroundColor: const Color(0xFF13080A),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إعدادات اللعبة',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'عدد اللاعبين',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0E11),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: List.generate(9, (i) => i + 4).map((num) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: _buildNumPill(
                            num: num,
                            selected: settings.playerCount == num,
                            onTap: () => notifier.setPlayerCount(num),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showExpandedNumbers = !_showExpandedNumbers;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF221215),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF422B2F)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showExpandedNumbers ? 'اخفاء' : 'اظهر المزيد',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _showExpandedNumbers
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_showExpandedNumbers) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF261014),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF482127)),
                    ),
                    child: Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 7,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.85,
                          children: List.generate(35, (i) => i + 13).map((num) {
                            return _buildNumPill(
                              num: num,
                              selected: settings.playerCount == num,
                              onTap: () => notifier.setPlayerCount(num),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [48, 49, 50].map((num) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: SizedBox(
                                width: 44,
                                child: _buildNumPill(
                                  num: num,
                                  selected: settings.playerCount == num,
                                  onTap: () => notifier.setPlayerCount(num),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'عدد المافيا',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0E11),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: List.generate(maxMafia, (i) => i + 1).map((mCount) {
                      final isSelected = settings.mafiaCount == mCount;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => notifier.setMafiaCount(mCount),
                            child: Container(
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE53E3A)
                                    : const Color(0xFF211215),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFE53E3A)
                                      : const Color(0xFF422F33),
                                ),
                              ),
                              child: Text(
                                '$mCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFB2A4A6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (settings.mafiaCount > 1) ...[
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'عدد القتل في الليلة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B0E11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: List.generate(settings.mafiaCount, (i) => i + 1).map((kCount) {
                        final isSelected = settings.killsPerNight == kCount;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => notifier.setKillsPerNight(kCount),
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFE53E3A)
                                      : const Color(0xFF211215),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE53E3A)
                                        : const Color(0xFF422F33),
                                  ),
                                ),
                                child: Text(
                                  '$kCount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFFB2A4A6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الأدوار الخاصة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.66,
                  children: [
                    _buildRoleCard(
                      role: MafiaRole.doctor,
                      value: settings.hasDoctor,
                      onChanged: notifier.toggleDoctor,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.detective,
                      value: settings.hasDetective,
                      onChanged: notifier.toggleDetective,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.bodyguard,
                      value: settings.hasBodyguard,
                      onChanged: notifier.toggleBodyguard,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.godfather,
                      value: settings.hasGodfather,
                      onChanged: notifier.toggleGodfather,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.spy,
                      value: settings.hasSpy,
                      onChanged: notifier.toggleSpy,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.silencer,
                      value: settings.hasSilencer,
                      onChanged: notifier.toggleSilencer,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.hunter,
                      value: settings.hasHunter,
                      onChanged: notifier.toggleHunter,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.jester,
                      value: settings.hasJester,
                      onChanged: notifier.toggleJester,
                    ),
                    _buildRoleCard(
                      role: MafiaRole.gambler,
                      value: settings.hasGambler,
                      onChanged: notifier.toggleGambler,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('كشف دور المُقصى'),
                  subtitle: const Text('عرض دور اللاعب عند إقصائه بالتصويت'),
                  activeColor: const Color(0xFFE53E3A),
                  value: settings.revealEliminatedRole,
                  onChanged: notifier.toggleRevealEliminatedRole,
                ),
                SwitchListTile(
                  title: const Text('إظهار التصويتات'),
                  subtitle: const Text('عرض تفاصيل من صوّت لمن بعد التصويت'),
                  activeColor: const Color(0xFFE53E3A),
                  value: settings.showVoteDetails,
                  onChanged: notifier.toggleShowVoteDetails,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (settings.playerCount < settings.minimumRequiredPlayers) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تحتاج ${settings.minimumRequiredPlayers} لاعبين على الأقل مع هذه الإعدادات',
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PlayerEntryScreen()),
                  );
                },
                child: const Text(
                  'التالي',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumPill({
    required int num,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE53E3A) : const Color(0xFF211215),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFE53E3A) : const Color(0xFF422F33),
          ),
        ),
        child: Text(
          '$num',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : const Color(0xFFB2A4A6),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required MafiaRole role,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final info = MafiaRoleInfo.of(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        gradient: value
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF271115), Color(0xFF56181E)],
              )
            : null,
        color: value ? null : const Color(0xFF231114),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? const Color(0xFF6B232A) : const Color(0xFF331B1F),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF211013),
                    title: Text(info.nameAr, textAlign: TextAlign.center),
                    content: Text(info.fullDesc, textAlign: TextAlign.center),
                    actions: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53E3A),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('فهمت'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF382327),
                  border: Border.all(color: const Color(0xFF6C5055)),
                ),
                child: const Text(
                  '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC8B6B9),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    info.imageAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                info.nameAr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                info.shortDesc,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF8E7B7E),
                ),
              ),
              const SizedBox(height: 6),
              Switch(
                value: value,
                activeTrackColor: const Color(0xFFE53E3A),
                activeColor: const Color(0xFF491317),
                inactiveTrackColor: const Color(0xFF2D1F22),
                inactiveThumbColor: const Color(0xFF8F8083),
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
