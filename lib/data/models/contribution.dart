class Contribution {
  final String id;
  final String goalId;
  final double amount;
  final String? note;
  final DateTime contributedAt;

  const Contribution({
    required this.id,
    required this.goalId,
    required this.amount,
    this.note,
    required this.contributedAt,
  });

  factory Contribution.fromMap(Map<String, dynamic> map) => Contribution(
        id: map['id'] as String,
        goalId: map['goal_id'] as String,
        amount: (map['amount'] as num).toDouble(),
        note: map['note'] as String?,
        contributedAt: DateTime.parse(map['contributed_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'goal_id': goalId,
        'amount': amount,
        'note': note,
        'contributed_at': contributedAt.toIso8601String(),
      };

  Contribution copyWith({
    double? amount,
    String? note,
    DateTime? contributedAt,
  }) =>
      Contribution(
        id: id,
        goalId: goalId,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        contributedAt: contributedAt ?? this.contributedAt,
      );
}
