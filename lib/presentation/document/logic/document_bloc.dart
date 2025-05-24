import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/document.dart';
import 'document_event.dart';

class DocumentBloc extends Bloc<DocumentEvent, List<Document>> {
  DocumentBloc() : super([]) {
    on<LoadDocuments>(_onLoadDocuments);
    on<AddDocument>(_onAddDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
  }

  void _onLoadDocuments(LoadDocuments event, Emitter<List<Document>> emit) {
    // TODO: Implement loading documents from storage/backend
    emit(state);
  }

  void _onAddDocument(AddDocument event, Emitter<List<Document>> emit) {
    final updatedDocuments = List<Document>.from(state)..add(event.document);
    emit(updatedDocuments);
  }

  void _onUpdateDocument(UpdateDocument event, Emitter<List<Document>> emit) {
    final updatedDocuments = state.map((doc) {
      return doc.id == event.document.id ? event.document : doc;
    }).toList();
    emit(updatedDocuments);
  }

  void _onDeleteDocument(DeleteDocument event, Emitter<List<Document>> emit) {
    final updatedDocuments =
        state.where((doc) => doc.id != event.documentId).toList();
    emit(updatedDocuments);
  }
}
