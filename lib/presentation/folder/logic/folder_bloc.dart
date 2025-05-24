import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/folder.dart';
import 'folder_event.dart';

class FolderBloc extends Bloc<FolderEvent, List<Folder>> {
  FolderBloc() : super([]) {
    on<LoadFolders>(_onLoadFolders);
    on<AddFolder>(_onAddFolder);
    on<UpdateFolder>(_onUpdateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<NavigateToFolder>(_onNavigateToFolder);
  }

  void _onLoadFolders(LoadFolders event, Emitter<List<Folder>> emit) {
    // TODO: Implement loading folders from storage/backend
    emit(state);
  }

  void _onAddFolder(AddFolder event, Emitter<List<Folder>> emit) {
    final updatedFolders = List<Folder>.from(state)..add(event.folder);
    emit(updatedFolders);
  }

  void _onUpdateFolder(UpdateFolder event, Emitter<List<Folder>> emit) {
    final updatedFolders = state.map((folder) {
      return folder.id == event.folder.id ? event.folder : folder;
    }).toList();
    emit(updatedFolders);
  }

  void _onDeleteFolder(DeleteFolder event, Emitter<List<Folder>> emit) {
    final updatedFolders =
        state.where((folder) => folder.id != event.folderId).toList();
    emit(updatedFolders);
  }

  void _onNavigateToFolder(NavigateToFolder event, Emitter<List<Folder>> emit) {
    // This event is handled by the UI to navigate to the selected folder
    emit(state);
  }
}
