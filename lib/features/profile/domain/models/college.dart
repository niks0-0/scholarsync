/// Model representing a college entry in `public.colleges`.
class College {
  const College({
    required this.id,
    required this.name,
    required this.code,
    this.stateId,
    this.universityId,
    this.category,
    this.city,
    this.createdAt,
  });

  final String id;
  final String name;
  final String code;
  final String? stateId;
  final String? universityId;
  final String? category;
  final String? city;
  final DateTime? createdAt;

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'] as String,
      name: json['name'] as String,
      code: (json['code'] as String?) ?? '',
      stateId: json['state_id'] as String?,
      universityId: json['university_id'] as String?,
      category: json['category'] as String?,
      city: json['city'] as String?,
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
      if (stateId != null) 'state_id': stateId,
      if (universityId != null) 'university_id': universityId,
      if (category != null) 'category': category,
      if (city != null) 'city': city,
    };
  }

  College copyWith({
    String? name,
    String? code,
    String? stateId,
    String? universityId,
    String? category,
    String? city,
  }) {
    return College(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      stateId: stateId ?? this.stateId,
      universityId: universityId ?? this.universityId,
      category: category ?? this.category,
      city: city ?? this.city,
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
