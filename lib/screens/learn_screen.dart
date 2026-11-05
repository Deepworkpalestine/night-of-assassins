import 'package:flutter/material.dart';
import '../models/mafia_role.dart';
import '../widgets/gothic_background.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GothicBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'شرح اللعبة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            title: 'هدف اللعبة',
            body: 'المواطنون يحاولون اكتشاف المافيا والتصويت على طردهم.\n'
                'المافيا تحاول القضاء على المواطنين دون أن يتم اكتشافها.',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'شروط الفوز',
            body: 'المواطنون يفوزون: إذا تم طرد جميع أعضاء المافيا.\n'
                'المافيا تفوز: إذا تساوى عدد المافيا مع المواطنين.',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'مرحلة الليل',
            body: 'كل لاعب يأخذ الجوال بشكل سري ويقوم بدوره:\n'
                '- المافيا: يختار ضحية للقتل.\n'
                '- المحقق: يختار لاعب للتحقيق.\n'
                '- الدكتور: يختار لاعب لحمايته.\n'
                '- المواطن: يمرر الجوال (يختار اسمه كتمويه).',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'مرحلة النهار',
            body: '1. التحقيق: كل لاعب يتكلم ويبرئ نفسه.\n'
                '2. الاستجواب: كل لاعب يختار شخص يستجوبه.\n'
                '3. التصويت: المجموعة تقرر من يُطرد.',
          ),
          const SizedBox(height: 18),
          const Text(
            'الأدوار',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...MafiaRoleInfo.roles.values.map((info) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B0D10).withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3E2429)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      info.imageAsset,
                      width: 64,
                      height: 94,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.titleAr,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          info.fullDesc,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB8A8AA),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          _buildInfoCard(
            title: 'نصائح',
            body: '- راقب ردود فعل اللاعبين أثناء النقاش.\n'
                '- لا تكشف دورك بسهولة إذا كنت محقق أو دكتور.\n'
                '- إذا كنت مافيا، حاول توجيه الشكوك نحو الآخرين.\n'
                '- الدكتور لا يمكنه حماية نفس الشخص مرتين متتاليتين.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String body}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0D10).withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3E2429)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53E3A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFB8A8AA),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
