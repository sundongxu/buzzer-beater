import 'team.dart';

class User {
  final int id;
  final String nickname;
  final String avatar;
  final Team team;
  final DateTime createdAt;

  User({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.team,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // 处理日期格式：将 SQLite 格式 "2025-11-18 10:00:00" 转换为可解析格式
    String dateStr = json['created_at'] as String;
    if (!dateStr.contains('T')) {
      dateStr = dateStr.replaceFirst(' ', 'T');
    }
    
    return User(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String,
      team: Team.fromJson(json['team'] as Map<String, dynamic>),
      createdAt: DateTime.parse(dateStr),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar': avatar,
      'team': team.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

