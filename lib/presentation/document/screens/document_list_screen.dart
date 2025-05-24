import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../logic/document_bloc.dart';
import '../logic/document_event.dart';
import '../logic/document_state.dart';
import '../models/document.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import 'package:file_selector/file_selector.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../../../core/widgets/dialogs.dart';

class DocumentListScreen extends StatelessWidget {
  final String folderId;
  final String? folderName;
  const DocumentListScreen({Key? key, required this.folderId, this.folderName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.primaryClr,
        title: Text(
          folderName ?? 'Documents',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: BlocBuilder<DocumentBloc, List<Document>>(
        builder: (context, documents) {
          final folderDocuments =
              documents.where((doc) => doc.folderId == folderId).toList();

          if (folderDocuments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 80,
                    color: AppColors.primaryClr.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No documents yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreyClr,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your first document',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGreyClr.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: folderDocuments.length,
              itemBuilder: (context, index) {
                final document = folderDocuments[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Dismissible(
                          key: Key(document.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.errorClr,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          onDismissed: (_) {
                            final hasDeletePermission =
                                document.permissions['owner']?['delete'] ??
                                    false;

                            if (!hasDeletePermission) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You do not have permission to delete this file.',
                                  ),
                                  backgroundColor: AppColors.errorClr,
                                ),
                              );
                              return;
                            }

                            context
                                .read<DocumentBloc>()
                                .add(DeleteDocument(document.id));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.darkGreyClr.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => showDocumentDetailsDialog(
                                    context, document),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryClr
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.insert_drive_file_rounded,
                                          color: AppColors.primaryClr,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              document.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: AppColors.darkHeaderClr,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              document.type,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.darkGreyClr
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.primaryClr,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryClr.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          heroTag: 'addDoc',
          onPressed: () => showFileUploadDialog(context, folderId),
          backgroundColor: AppColors.primaryClr,
          icon: const Icon(Icons.upload_rounded),
          label: const Text('Upload'),
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;
  const PDFViewerScreen({required this.filePath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PDFViewerScreen(filePath: filePath),
                ),
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        File(filePath),
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load PDF: ${details.description}'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PDFViewerScreen(filePath: filePath),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
