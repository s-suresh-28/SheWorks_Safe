import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String password; // In real app, never store plain text
  final String role; // 'worker', 'provider', 'admin', 'none'
  final bool isVerifiedFemale;
  final int age;
  
  // Worker specific
  final List<String> skills; // e.g., Cooking, Cleaning
  
  // Provider specific
  final String location;
  final String contact;
  
  // Rating logic
  final double rating;
  final bool isBanned;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.isVerifiedFemale,
    required this.age,
    this.skills = const [],
    this.location = '',
    this.contact = '',
    this.rating = 5.0,
    this.isBanned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'isVerifiedFemale': isVerifiedFemale,
      'age': age,
      'skills': skills,
      'location': location,
      'contact': contact,
      'rating': rating,
      'isBanned': isBanned,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      isVerifiedFemale: map['isVerifiedFemale'] ?? false,
      age: map['age'] ?? 18,
      skills: List<String>.from(map['skills'] ?? []),
      location: map['location'] ?? '',
      contact: map['contact'] ?? '',
      rating: map['rating']?.toDouble() ?? 5.0,
      isBanned: map['isBanned'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source));
  
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? role,
    bool? isVerifiedFemale,
    int? age,
    List<String>? skills,
    String? location,
    String? contact,
    double? rating,
    bool? isBanned,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isVerifiedFemale: isVerifiedFemale ?? this.isVerifiedFemale,
      age: age ?? this.age,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      rating: rating ?? this.rating,
      isBanned: isBanned ?? this.isBanned,
    );
  }
}

class Job {
  final String id;
  final String providerId;
  final String type; // Cooking, Cleaning, Caretaker, Washing
  final double salary;
  final String timing;
  final String description;
  final String status; // 'open', 'filled'

  Job({
    required this.id,
    required this.providerId,
    required this.type,
    required this.salary,
    required this.timing,
    required this.description,
    this.status = 'open',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'type': type,
      'salary': salary,
      'timing': timing,
      'description': description,
      'status': status,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      providerId: map['providerId'],
      type: map['type'],
      salary: map['salary']?.toDouble() ?? 0.0,
      timing: map['timing'],
      description: map['description'],
      status: map['status'] ?? 'open',
    );
  }

  String toJson() => json.encode(toMap());
  factory Job.fromJson(String source) => Job.fromMap(json.decode(source));
}

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  final String providerId;
  final String status; // 'pending', 'accepted', 'rejected', 'selected'
  
  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.providerId,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'workerId': workerId,
      'providerId': providerId,
      'status': status,
    };
  }

  factory JobApplication.fromMap(Map<String, dynamic> map) {
    return JobApplication(
      id: map['id'],
      jobId: map['jobId'],
      workerId: map['workerId'],
      providerId: map['providerId'],
      status: map['status'] ?? 'pending',
    );
  }

  String toJson() => json.encode(toMap());
  factory JobApplication.fromJson(String source) => JobApplication.fromMap(json.decode(source));
  
  JobApplication copyWith({
    String? id,
    String? jobId,
    String? workerId,
    String? providerId,
    String? status,
  }) {
    return JobApplication(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      workerId: workerId ?? this.workerId,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
    );
  }
}

class ChatMessage {
  final String id;
  final String applicationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isSystemOffer;

  ChatMessage({
    required this.id,
    required this.applicationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isSystemOffer = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'applicationId': applicationId,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isSystemOffer': isSystemOffer,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      applicationId: map['applicationId'],
      senderId: map['senderId'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isSystemOffer: map['isSystemOffer'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory ChatMessage.fromJson(String source) => ChatMessage.fromMap(json.decode(source));
}
