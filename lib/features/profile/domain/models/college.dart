/// Model representing a college entry in `public.colleges`.
class College {
  const College({
    required this.id,
    required this.name,
    required this.code,
    this.createdAt,
  });

  final String id;
  final String name;
  final String code;
  final DateTime? createdAt;

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'] as String,
      name: json['name'] as String,
      code: (json['code'] as String?) ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  College copyWith({
    String? name,
    String? code,
  }) {
    return College(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is College && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
