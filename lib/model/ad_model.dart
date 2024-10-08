class AdModel {
  final String id;
  final String title;
  final String description;
  final String img;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? creatorId;
  final DateTime? startDate;
  final String? content;
  final DateTime? endDate;

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.img,
    required this.createdAt,
    this.updatedAt,
    this.creatorId,
    this.startDate,
    this.content,
    this.endDate,
  });

  String get imageUrl => img;

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] != null ? json['id'] as String : '',
      title: json['title'] != null ? json['title'] as String : '',
      description:
          json['description'] != null ? json['description'] as String : '',
      img: json['img'] != null ? json['img'] as String : '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      creatorId: json['creatorId'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      content: json['content'] as String?,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'img': img,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'creatorId': creatorId,
      'startDate': startDate?.toIso8601String(),
      'content': content,
      'endDate': endDate?.toIso8601String(),
    };
  }
}
