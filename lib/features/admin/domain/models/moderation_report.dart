class ModerationReport {
  const ModerationReport({
    required this.id,
    this.reporterId,
    this.reporterName,
    required this.reportedUserId,
    this.reportedUserName,
    required this.entityType,
    required this.entityId,
    required this.reason,
    this.evidenceUrl,
    this.priority = 'medium',
    this.status = 'pending',
    this.resolutionAction = 'none',
    this.resolutionNotes,
    this.assignedAdminId,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? reporterId;
  final String? reporterName;
  final String reportedUserId;
  final String? reportedUserName;
  final String entityType; // user, post, comment, message, note, marketplace, event, club
  final String entityId;
  final String reason;
  final String? evidenceUrl;
  final String priority; // low, medium, high, urgent
  final String status; // pending, in_review, resolved, dismissed
  final String resolutionAction; // none, warned, suspended, deleted_content, banned
  final String? resolutionNotes;
  final String? assignedAdminId;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ModerationReport.fromJson(Map<String, dynamic> json) {
    return ModerationReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String?,
      reporterName: json['reporter'] != null && json['reporter'] is Map
          ? (json['reporter'] as Map<String, dynamic>)['full_name'] as String?
          : null,
      reportedUserId: json['reported_user_id'] as String? ?? '',
      reportedUserName: json['reported_user'] != null && json['reported_user'] is Map
          ? (json['reported_user'] as Map<String, dynamic>)['full_name'] as String?
          : null,
      entityType: json['entity_type'] as String? ?? 'user',
      entityId: json['entity_id'] as String? ?? '',
      reason: json['reason'] as String? ?? 'No reason specified',
      evidenceUrl: json['evidence_url'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
      resolutionAction: json['resolution_action'] as String? ?? 'none',
      resolutionNotes: json['resolution_notes'] as String?,
      assignedAdminId: json['assigned_admin_id'] as String?,
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'reported_user_id': reportedUserId,
      'entity_type': entityType,
      'entity_id': entityId,
      'reason': reason,
      'evidence_url': evidenceUrl,
      'priority': priority,
      'status': status,
      'resolution_action': resolutionAction,
      'resolution_notes': resolutionNotes,
      'assigned_admin_id': assignedAdminId,
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  ModerationReport copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? reportedUserId,
    String? reportedUserName,
    String? entityType,
    String? entityId,
    String? reason,
    String? evidenceUrl,
    String? priority,
    String? status,
    String? resolutionAction,
    String? resolutionNotes,
    String? assignedAdminId,
    DateTime? resolvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModerationReport(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedUserName: reportedUserName ?? this.reportedUserName,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      reason: reason ?? this.reason,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      resolutionAction: resolutionAction ?? this.resolutionAction,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
