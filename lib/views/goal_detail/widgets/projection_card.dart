import 'package:flutter/material.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/currency_formatter.dart';

class ProjectionCard extends StatelessWidget {
  final double weeklyAverage;
  final double remainingAmount;
  final int? estimatedWeeks;
  final Color color;

  const ProjectionCard({
    super.key,
    required this.weeklyAverage,
    required this.remainingAmount,
    required this.estimatedWeeks,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: color),
                const SizedBox(width: 8),
                Text('Projection',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
            _InfoRow(
              label: 'Moy. hebdomadaire',
              value: CurrencyFormatter.format(weeklyAverage),
              color: color,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Reste à épargner',
              value: CurrencyFormatter.format(remainingAmount),
              color: color,
            ),
            const Divider(height: 20),
            if (estimatedWeeks == null || weeklyAverage <= 0)
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Ajoute des versements pour obtenir une projection.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.flag, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        children: [
                          const TextSpan(text: 'À ce rythme, tu atteindras ton objectif dans '),
                          TextSpan(
                            text: DateHelpers.weeksToLabel(estimatedWeeks!),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: color),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
