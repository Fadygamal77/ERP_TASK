class Document {
  final String id;
  final String name;
  final String type;
  final int size;
  final String folderId;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final Map<String, dynamic> permissions;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.folderId,
    required this.tags,
    required this.metadata,
    required this.permissions,
  });

  Document copyWith({
    String? id,
    String? name,
    String? type,
    int? size,
    String? folderId,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? permissions,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      folderId: folderId ?? this.folderId,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      permissions: permissions ?? this.permissions,
    );
  }
}
