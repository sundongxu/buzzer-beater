import 'nba_team.dart';

class NBAPlayer {
  final int id;
  final String firstName;
  final String lastName;
  final String position;
  final String? height;
  final String? weight;
  final String? jerseyNumber;
  final String? college;
  final String? country;
  final int? draftYear;
  final int? draftRound;
  final int? draftNumber;
  final NBATeam team;

  NBAPlayer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.position,
    this.height,
    this.weight,
    this.jerseyNumber,
    this.college,
    this.country,
    this.draftYear,
    this.draftRound,
    this.draftNumber,
    required this.team,
  });

  String get fullName => '$firstName $lastName';

  factory NBAPlayer.fromJson(Map<String, dynamic> json) {
    return NBAPlayer(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      position: json['position'] as String? ?? '',
      height: json['height'] as String?,
      weight: json['weight'] as String?,
      jerseyNumber: json['jersey_number'] as String?,
      college: json['college'] as String?,
      country: json['country'] as String?,
      draftYear: json['draft_year'] as int?,
      draftRound: json['draft_round'] as int?,
      draftNumber: json['draft_number'] as int?,
      team: NBATeam.fromJson(json['team'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'position': position,
      'height': height,
      'weight': weight,
      'jersey_number': jerseyNumber,
      'college': college,
      'country': country,
      'draft_year': draftYear,
      'draft_round': draftRound,
      'draft_number': draftNumber,
      'team': team.toJson(),
    };
  }
}

