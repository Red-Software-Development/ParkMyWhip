import 'dart:convert';
import 'dart:developer';

class SupabaseUserModel {
  final String id;
  final String email;
  final String fullName;
  final bool emailVerified;
  final String? avatarUrl;
  final String? phoneNumber;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupabaseUserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.phoneNumber,
    this.metadata = const <String, dynamic>{},
  });

  SupabaseUserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? emailVerified,
    String? avatarUrl,
    String? phoneNumber,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupabaseUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      emailVerified: emailVerified ?? this.emailVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      metadata: metadata ?? Map<String, dynamic>.from(this.metadata),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SupabaseUserModel.fromJson(Map<String, dynamic> json) {
    return SupabaseUserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      emailVerified: json['emailVerified'] as bool? ?? json['email_confirmed'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      phoneNumber: json['phoneNumber'] as String? ?? json['phone'] as String?,
      metadata: _safeMetadata(json['metadata']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'emailVerified': emailVerified,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    log('Invalid date "$value", defaulting to now.', name: 'SupabaseUserModel', level: 900);
    return DateTime.now();
  }

  static Map<String, dynamic> _safeMetadata(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data.cast<String, dynamic>());
    }
    if (data is String && data.isNotEmpty) {
      try {
        return Map<String, dynamic>.from(_tryDecodeJson(data));
      } catch (_) {
        return <String, dynamic>{'raw': data};
      }
    }
    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _tryDecodeJson(String data) {
    try {
      return Map<String, dynamic>.from(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }
}
