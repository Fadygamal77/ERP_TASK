import '../models/document.dart';

abstract class DocumentEvent {}

class LoadDocuments extends DocumentEvent {
  final String folderId;
  LoadDocuments(this.folderId);
}

class AddDocument extends DocumentEvent {
  final Document document;
  AddDocument(this.document);
}

class UpdateDocument extends DocumentEvent {
  final Document document;
  UpdateDocument(this.document);
}

class DeleteDocument extends DocumentEvent {
  final String documentId;
  DeleteDocument(this.documentId);
}
