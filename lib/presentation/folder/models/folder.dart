class Folder {
  final String id;
  final String name;
  final String? parentId;
  final List<String> childFolderIds;
  final List<String> documentIds;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    List<String>? childFolderIds,
    List<String>? documentIds,
  })  : childFolderIds = childFolderIds ?? [],
        documentIds = documentIds ?? [];

  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    List<String>? childFolderIds,
    List<String>? documentIds,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      childFolderIds: childFolderIds ?? this.childFolderIds,
      documentIds: documentIds ?? this.documentIds,
    );
  }
}
