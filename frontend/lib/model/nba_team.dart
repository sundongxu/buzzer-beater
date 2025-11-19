class NBATeam {
  final int id;
  final String conference;
  final String division;
  final String city;
  final String name;
  final String fullName;
  final String fullNameZh;
  final String abbreviation;
  final String logoUrl;
  final String bgColor;

  NBATeam({
    required this.id,
    required this.conference,
    required this.division,
    required this.city,
    required this.name,
    required this.fullName,
    required this.fullNameZh,
    required this.abbreviation,
    required this.logoUrl,
    required this.bgColor,
  });

  factory NBATeam.fromJson(Map<String, dynamic> json) {
    return NBATeam(
      id: json['id'] as int,
      conference: json['conference'] as String,
      division: json['division'] as String,
      city: json['city'] as String,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      fullNameZh: json['full_name_zh'] as String? ?? json['full_name'] as String,
      abbreviation: json['abbreviation'] as String,
      logoUrl: json['logo_url'] as String? ?? '',
      bgColor: json['bg_color'] as String? ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conference': conference,
      'division': division,
      'city': city,
      'name': name,
      'full_name': fullName,
      'full_name_zh': fullNameZh,
      'abbreviation': abbreviation,
      'logo_url': logoUrl,
      'bg_color': bgColor,
    };
  }
}

