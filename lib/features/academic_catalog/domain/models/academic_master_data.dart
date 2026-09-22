// Domain models representing the Indian Master Academic Directory.

class AcademicState {
  const AcademicState({
    required this.id,
    required this.name,
    this.code,
    this.type = 'State',
  });

  final String id;
  final String name;
  final String? code;
  final String type;

  factory AcademicState.fromJson(Map<String, dynamic> json) {
    return AcademicState(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      type: json['type'] as String? ?? 'State',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'type': type,
      };
}

class AcademicStream {
  const AcademicStream({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory AcademicStream.fromJson(Map<String, dynamic> json) {
    return AcademicStream(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class CourseType {
  const CourseType({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory CourseType.fromJson(Map<String, dynamic> json) {
    return CourseType(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class AcademicCourse {
  const AcademicCourse({
    required this.id,
    required this.name,
    this.streamId,
    this.courseTypeId,
  });

  final String id;
  final String name;
  final String? streamId;
  final String? courseTypeId;

  factory AcademicCourse.fromJson(Map<String, dynamic> json) {
    return AcademicCourse(
      id: json['id'] as String,
      name: json['name'] as String,
      streamId: json['stream_id'] as String?,
      courseTypeId: json['course_type_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stream_id': streamId,
        'course_type_id': courseTypeId,
      };
}

class AcademicBranch {
  const AcademicBranch({
    required this.id,
    required this.name,
    this.code,
    this.streamId,
  });

  final String id;
  final String name;
  final String? code;
  final String? streamId;

  factory AcademicBranch.fromJson(Map<String, dynamic> json) {
    return AcademicBranch(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      streamId: json['stream_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'stream_id': streamId,
      };
}

class AcademicSemester {
  const AcademicSemester({
    required this.id,
    required this.semesterNumber,
    required this.name,
  });

  final String id;
  final int semesterNumber;
  final String name;

  factory AcademicSemester.fromJson(Map<String, dynamic> json) {
    return AcademicSemester(
      id: json['id'] as String,
      semesterNumber: json['semester_number'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'semester_number': semesterNumber,
        'name': name,
      };
}

class University {
  const University({
    required this.id,
    required this.name,
    this.stateId,
    this.type = 'State Public University',
  });

  final String id;
  final String name;
  final String? stateId;
  final String type;

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'] as String,
      name: json['name'] as String,
      stateId: json['state_id'] as String?,
      type: json['type'] as String? ?? 'State Public University',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state_id': stateId,
        'type': type,
      };
}
