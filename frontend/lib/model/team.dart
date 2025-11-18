import 'package:flutter/material.dart';

class Team {
  final int id;
  final String name;
  final String code;
  final String color;
  final String accent;

  Team({
    required this.id,
    required this.name,
    required this.code,
    required this.color,
    required this.accent,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      color: json['color'] as String,
      accent: json['accent'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'color': color,
      'accent': accent,
    };
  }

  // 获取主色
  Color get primaryColor {
    return Color(int.parse(color.replaceFirst('#', '0xFF')));
  }

  // 获取辅助色
  Color get accentColor {
    return Color(int.parse(accent.replaceFirst('#', '0xFF')));
  }
}

