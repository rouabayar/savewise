import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/add_goal_viewmodel.dart';
import '../../data/repositories/goal_repository.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();

  static const _colors = [
    '#2E7D32', '#1976D2', '#7B1FA2',
    '#E53935', '#F57C00', '#00838F',
  ];

  static const _icons = [
    Icons.savings,    Icons.flight,      Icons.laptop,
    Icons.directions_car, Icons.school, Icons.home,
    Icons.favorite,   Icons.beach_access, Icons.fitness_center,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddGoalViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel objectif')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nom
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'objectif *',
                hintText: 'Ex : Voyage au Japon',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              onChanged: vm.setName,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Ce champ est obligatoire' : null,
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              maxLines: 2,
              onChanged: vm.setDescription,
            ),
            const SizedBox(height: 16),
            // Montant cible
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Montant cible (€) *',
                prefixIcon: Icon(Icons.euro_outlined),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => vm.setTargetAmount(double.tryParse(v) ?? 0),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Entrez un montant valide';
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Couleur
            Text('Couleur', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: _colors.map((hex) {
                final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                final selected = vm.colorHex == hex;
                return GestureDetector(
                  onTap: () => vm.setColorHex(hex),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: Colors.black54, width: 3)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Icône
            Text('Icône', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons.map((icon) {
                final selected = vm.iconCode == icon.codePoint;
                final color = Color(
                    int.parse(vm.colorHex.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => vm.setIconCode(icon.codePoint),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Icon(icon,
                        color: selected ? color : Colors.grey.shade500),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Date limite optionnelle
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(vm.deadline == null
                  ? 'Date limite (optionnel)'
                  : 'Échéance : ${vm.deadline!.day}/${vm.deadline!.month}/${vm.deadline!.year}'),
              trailing: vm.deadline != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => vm.setDeadline(null),
                    )
                  : null,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (d != null) vm.setDeadline(d);
              },
            ),
            const SizedBox(height: 32),
            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(vm.error!,
                    style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton(
              onPressed: vm.isSaving
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final success = await vm.save(context.read<GoalRepository>());
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Objectif créé avec succès !')),
                        );
                        Navigator.pop(context);
                        vm.reset();
                      }
                    },
              child: vm.isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Créer l\'objectif'),
            ),
          ],
        ),
      ),
    );
  }
}
