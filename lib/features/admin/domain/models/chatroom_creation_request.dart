class ChatRoomCreationRequest {
  const ChatRoomCreationRequest({
    required this.id,
    required this.requesterId,
    required this.name,
    this.description,
    required this.category,
    this.collegeId,
    this.branch,
    this.semester,
    this.subjectId,
    required this.joiningPolicy,
    this.communityGuidelines,
    required this.status,
    this.assignedReviewerId,
    this.reviewerRemarks,
    this.reviewedAt,
    this.createdAt,
  });

  final String id;
  final String requesterId;
  final String name;
  final String? description;
  final String category;
  final String? collegeId;
  final String? branch;
  final int? semester;
  final String? subjectId;
  final String joiningPolicy;
  final String? communityGuidelines;
  final String status; // 'pending', 'under_review', 'approved', 'rejected'
  final String? assignedReviewerId;
  final String? reviewerRemarks;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  factory ChatRoomCreationRequest.fromJson(Map<String, dynamic> json) {
    return ChatRoomCreationRequest(
      id: json['id']?.toString() ?? '',
      requesterId: json['requester_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? 'academic',
      collegeId: json['college_id']?.toString(),
      branch: json['branch']?.toString(),
      semester: json['semester'] as int?,
      subjectId: json['subject_id']?.toString(),
      joiningPolicy: json['joining_policy']?.toString() ?? 'public_academic',
      communityGuidelines: json['community_guidelines']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      assignedReviewerId: json['assigned_reviewer_id']?.toString(),
      reviewerRemarks: json['reviewer_remarks']?.toString(),
      reviewedAt: json['reviewed_at'] != null ? DateTime.tryParse(json['reviewed_at'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
