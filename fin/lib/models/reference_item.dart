class ReferenceItem {
  String id;
  String name;
  String info; // додано поле

  ReferenceItem({
    required this.id,
    required this.name,
    this.info = '', // значення за замовчуванням
  });

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: json['id'],
      name: json['name'],
      info: json['info'] ?? '', // якщо немає info у JSON
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'info': info, // додано
  };
}
