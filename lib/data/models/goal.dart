class Goal {
  final String id;
  final String name;
  final String? description;
  final double targetAmount;
  final int iconCode;
  final String colorHex;
  final DateTime? deadline;
  final String status; // 'active' | 'completed' | 'archived'
  final DateTime createdAt;
  final int sortOrder;

  // Champs calculés (non stockés en BD)
  final double currentAmount;

  const Goal({
    required this.id,
    required this.name,
    this.description,
    required this.targetAmount,
    this.iconCode = 57746,
    this.colorHex = '#2E7D32',
    this.deadline,
    this.status = 'active',
    required this.createdAt,
    this.sortOrder = 0,
    this.currentAmount = 0.0,
  });

  // Calculs dérivés
  double get progressPercent =>
      targetAmount > 0 ? (currentAmount / targetAmount * 100).clamp(0, 100) : 0;

  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  /// Estimation semaines restantes basée sur la moyenne hebdomadaire
  int? estimatedWeeksRemaining(double avgWeeklyContribution) {
    if (avgWeeklyContribution <= 0) return null;
    return (remainingAmount / avgWeeklyContribution).ceil();
  }

  factory Goal.fromMap(Map<String, dynamic> map) => Goal(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        targetAmount: (map['target_amount'] as num).toDouble(),
        iconCode: map['icon_code'] as int,
        colorHex: map['color_hex'] as String,
        deadline: map['deadline'] != null
            ? DateTime.parse(map['deadline'] as String)
            : null,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        sortOrder: map['sort_order'] as int,
        currentAmount: (map['current_amount'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'target_amount': targetAmount,
        'icon_code': iconCode,
        'color_hex': colorHex,
        'deadline': deadline?.toIso8601String(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'sort_order': sortOrder,
      };

  Goal copyWith({
    String? name,
    String? description,
    double? targetAmount,
    int? iconCode,
    String? colorHex,
    DateTime? deadline,
    String? status,
    int? sortOrder,
    double? currentAmount,
  }) =>
      Goal(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        targetAmount: targetAmount ?? this.targetAmount,
        iconCode: iconCode ?? this.iconCode,
        colorHex: colorHex ?? this.colorHex,
        deadline: deadline ?? this.deadline,
        status: status ?? this.status,
        createdAt: createdAt,
        sortOrder: sortOrder ?? this.sortOrder,
        currentAmount: currentAmount ?? this.currentAmount,
      );
}
