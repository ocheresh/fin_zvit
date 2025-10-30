class ReferenceItem {
  final String id;
  final String name;
  final String info;
  const ReferenceItem({required this.id, required this.name, this.info = ''});

  factory ReferenceItem.fromJson(Map<String, dynamic> j) =>
      ReferenceItem(id: j['id'], name: j['name'], info: j['info'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'info': info};
}
