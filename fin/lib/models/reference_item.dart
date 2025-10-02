class ReferenceItem {
  final int id;
  final String name;
  final String info;

  ReferenceItem({required this.id, required this.name, required this.info});

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: json['id'] as int,
      name: json['name'] as String,
      info: json['info']?.toString() ?? '', // щоб уникнути null
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'info': info};
  }
}
