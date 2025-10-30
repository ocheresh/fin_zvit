sealed class ReferenceIntent {}

class LoadAll extends ReferenceIntent {}

class CreateCategory extends ReferenceIntent {
  final String name;
  CreateCategory(this.name);
}

class DeleteCategory extends ReferenceIntent {
  final String name;
  DeleteCategory(this.name);
}

class AddItem extends ReferenceIntent {
  final String category;
  final String name;
  final String info;
  AddItem(this.category, {required this.name, this.info = ''});
}

class EditItem extends ReferenceIntent {
  final String category;
  final String id;
  final String? name;
  final String? info;
  EditItem(this.category, this.id, {this.name, this.info});
}

class DeleteItem extends ReferenceIntent {
  final String category;
  final String id;
  DeleteItem(this.category, this.id);
}
