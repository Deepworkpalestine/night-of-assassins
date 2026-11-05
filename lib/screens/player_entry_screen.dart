import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/sound_service.dart';
import '../widgets/gothic_background.dart';
import 'mafia_game_screen.dart';

class PlayerEntryScreen extends ConsumerStatefulWidget {
  const PlayerEntryScreen({super.key});

  @override
  ConsumerState<PlayerEntryScreen> createState() => _PlayerEntryScreenState();
}

class _PlayerEntryScreenState extends ConsumerState<PlayerEntryScreen> {
  late List<TextEditingController> _controllers;

  static const List<String> _defaultArabicNames = [
    'أحمد',
    'سارة',
    'خالد',
    'ليلى',
    'عمر',
    'نور',
    'فهد',
    'ريم',
    'سلطان',
    'جنى',
  ];

  @override
  void initState() {
    super.initState();
    final count = ref.read(mafiaSettingsProvider).playerCount;
    final saved = ref.read(playerNamesProvider);
    _controllers = List.generate(count, (i) {
      final text = i < saved.length && saved[i].trim().isNotEmpty
          ? saved[i]
          : (i < _defaultArabicNames.length
              ? _defaultArabicNames[i]
              : 'لاعب ${i + 1}');
      final ctrl = TextEditingController(text: text);
      ctrl.addListener(() {
        if (mounted) setState(() {});
      });
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _allNamesFilled {
    return _controllers.every((c) => c.text.trim().isNotEmpty);
  }

  bool _isDuplicate(int index) {
    final val = _controllers[index].text.trim();
    if (val.isEmpty) return false;
    for (int i = 0; i < _controllers.length; i++) {
      if (i != index && _controllers[i].text.trim() == val) {
        return true;
      }
    }
    return false;
  }

  bool get _hasDuplicateNames {
    for (int i = 0; i < _controllers.length; i++) {
      if (_isDuplicate(i)) return true;
    }
    return false;
  }

  void _startGame() {
    SoundService.playClick();
    if (!_allNamesFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال أسماء جميع اللاعبين')),
      );
      return;
    }
    if (_hasDuplicateNames) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن تكرار الأسماء')),
      );
      return;
    }

    final names = _controllers.map((c) => c.text.trim()).toList();
    ref.read(playerNamesProvider.notifier).saveNames(names);
    ref.read(mafiaGameProvider.notifier).initializeGame(names);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MafiaGameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canStart = _allNamesFilled && !_hasDuplicateNames;

    return GothicBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'اللاعبين',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              'أدخل أسماء جميع اللاعبين',
              textAlign: TextAlign.right,
              style: TextStyle(color: Color(0xFFB8A8AA), fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                final isDup = _isDuplicate(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B0D10).withOpacity(0.92),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDup
                                ? const Color(0xFFE53E3A)
                                : const Color(0xFF3E2429),
                            width: isDup ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF38141A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _controllers[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'اسم اللاعب',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDup)
                        const Padding(
                          padding: EdgeInsets.only(top: 4, right: 8),
                          child: Text(
                            'لا يمكن تكرار الأسماء',
                            style: TextStyle(
                              color: Color(0xFFE53E3A),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53E3A),
                  disabledBackgroundColor:
                      const Color(0xFFE53E3A).withOpacity(0.4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: canStart ? _startGame : null,
                child: const Text(
                  'ابدأ اللعبة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
