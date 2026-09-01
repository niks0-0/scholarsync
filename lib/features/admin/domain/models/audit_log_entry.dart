class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    this.adminId,
    required this.action,
    required this.targetType,
    this.targetId,
    this.metadata = const {},
    this.createdAt,
  });

  final String id;
  final String? adminId;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      id: json['id'] as String,
      adminId: json['admin_id'] as String?,
      action: json['action'] as String? ?? 'UNKNOWN',
      targetType: json['target_type'] as String? ?? 'general',
      targetId: json['target_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admin_id': adminId,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      'metadata': metadata,
    };
  }
}
