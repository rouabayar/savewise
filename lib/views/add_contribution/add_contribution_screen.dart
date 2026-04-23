import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/contribution.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/contribution_repository.dart';
import '../../viewmodels/goal_detail_viewmodel.dart';
import '../../core/utils/date_helpers.dart';

class AddContributionScreen extends StatefulWidget {
  final String goalId;
  const AddContributionScreen({super.key, required this.goalId});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final contribution = Contribution(
      id: const Uuid().v4(),
      goalId: widget.goalId,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      contributedAt: _selectedDate,
    );

    await context.read<GoalDetailViewModel>().addContribution(
          contribution,
          context.read<GoalRepository>(),
          context.read<ContributionRepository>(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Versement de ${contribution.amount.toStringAsFixed(2)} € ajouté !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un versement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Montant ─────────────────────────────────────
            TextFormField(
              controller: _amountCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Montant (€) *',
                hintText: '0,00',
                prefixIcon: Icon(Icons.euro_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final cleaned = v?.replaceAll(',', '.') ?? '';
                final n = double.tryParse(cleaned);
                if (n == null || n <= 0) return 'Entrez un montant valide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Note ─────────────────────────────────────────
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                hintText: 'Ex : prime, économies janvier…',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 8),

            // ── Date ─────────────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date du versement'),
              subtitle: Text(DateHelpers.format(_selectedDate)),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Modifier'),
              ),
            ),
            const SizedBox(height: 32),

            // ── Bouton submit ─────────────────────────────────
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _submit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Enregistrement…' : 'Confirmer le versement'),
            ),
          ],
        ),
      ),
    );
  }
}
