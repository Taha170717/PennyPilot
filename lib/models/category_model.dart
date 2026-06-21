class CategoryModel {
  final String id;
  final String name;
  final int iconCodePoint; // store IconData codePoint
  final int colorValue; // store color value
  final bool isIncome; // whether category is income type

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.isIncome = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'isIncome': isIncome,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCodePoint: json['iconCodePoint'] as int,
        colorValue: json['colorValue'] as int,
        isIncome: json['isIncome'] as bool? ?? false,
      );
}

