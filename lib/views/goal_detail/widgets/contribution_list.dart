import 'package:flutter/material.dart';
import '../../../data/models/contribution.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helpers.dart';

class ContributionList extends StatelessWidget {
  final List<Contribution> contributions;
  final Color color;
  final void Function(String id)? onDelete;

  const ContributionList({
    super.key,
    required this.contributions,
    required this.color,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.savings_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text(
                  'Aucun versement pour l\'instant.\nAppuie sur + pour commencer !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: contributions.map((c) => _ContributionTile(
        contribution: c,
        color: color,
        onDelete: onDelete != null ? () => onDelete!(c.id) : null,
      )).toList(),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  final Contribution contribution;
  final Color color;
  final VoidCallback? onDelete;

  const _ContributionTile({
    required this.contribution,
    required this.color,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Widget tile = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.arrow_upward, color: color, size: 18),
        ),
        title: Text(
          CurrencyFormatter.format(contribution.amount),
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
        subtitle: Text(
          contribution.note ?? 'Versement',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Text(
          DateHelpers.formatShort(contribution.contributedAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: Key(contribution.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Supprimer ce versement ?'),
            content: Text(
              'Versement de ${CurrencyFormatter.format(contribution.amount)} '
              'du ${DateHelpers.formatShort(contribution.contributedAt)}',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Supprimer',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: tile,
    );
  }
}
