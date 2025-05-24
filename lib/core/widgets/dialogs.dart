import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/document/logic/document_bloc.dart';
import '../../presentation/document/logic/document_event.dart';
import '../../presentation/document/models/document.dart';
import '../constants/app_colors.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

const double _kBorderRadius = 12.0;
const double _kSpacing = 16.0;
const double _kChipSpacing = 8.0;

// Function to show document details dialog
Future<void> showDocumentDetailsDialog(
  BuildContext context,
  Document doc,
) async {
  await showDialog(
    context: context,
    builder: (dialogContext) {
      final tagController = TextEditingController();
      List<String> tags = List<String>.from(doc.tags);
      String? tagError;
      final Map<String, dynamic> tempPermissions = Map.from(doc.permissions);

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kBorderRadius),
            ),
            title: Row(
              children: [
                Icon(
                  doc.type == 'PDF'
                      ? Icons.picture_as_pdf
                      : Icons.insert_drive_file,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: _kSpacing / 2),
                Expanded(
                  child: Text(
                    doc.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(_kSpacing),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(
                            icon: Icons.description,
                            label: 'Type',
                            value: doc.type,
                          ),
                          const SizedBox(height: _kSpacing / 2),
                          _DetailRow(
                            icon: Icons.data_usage,
                            label: 'Size',
                            value: '${(doc.size / 1024).toStringAsFixed(2)} KB',
                          ),
                          if (doc.metadata['fileName'] != null) ...[
                            const SizedBox(height: _kSpacing / 2),
                            _DetailRow(
                              icon: Icons.insert_drive_file,
                              label: 'File',
                              value: doc.metadata['fileName'],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: _kSpacing),
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: _kSpacing / 2),
                  Wrap(
                    spacing: _kChipSpacing,
                    runSpacing: _kChipSpacing,
                    children: tags
                        .map((tag) => _CustomChip(
                              label: tag,
                              onDeleted: () => setState(() => tags.remove(tag)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: _kSpacing / 2),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: InputDecoration(
                            hintText: 'Add tag',
                            filled: true,
                            fillColor: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(_kBorderRadius),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: _kSpacing,
                              vertical: _kSpacing / 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: _kSpacing / 2),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          final newTag = tagController.text.trim();
                          if (newTag.isEmpty) {
                            setState(() => tagError = 'Enter a tag');
                            return;
                          }
                          if (tags.contains(newTag)) {
                            setState(() => tagError = 'Tag already exists');
                            return;
                          }
                          setState(() {
                            tags.add(newTag);
                            tagController.clear();
                            tagError = null;
                          });
                        },
                      ),
                    ],
                  ),
                  if (tagError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        tagError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: _kSpacing),
                  Text(
                    'Permissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: _kSpacing / 2),
                  Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'View',
                            style: TextStyle(
                              color: AppColors.darkHeaderClr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: tempPermissions['owner']?['view'] ?? false,
                            onChanged: (value) => setState(() {
                              if (tempPermissions['owner'] == null) {
                                tempPermissions['owner'] = {};
                              }
                              tempPermissions['owner']?['view'] = value;
                            }),
                            activeColor: AppColors.primaryClr,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.darkHeaderClr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: tempPermissions['owner']?['edit'] ?? false,
                            onChanged: (value) => setState(() {
                              if (tempPermissions['owner'] == null) {
                                tempPermissions['owner'] = {};
                              }
                              tempPermissions['owner']?['edit'] = value;
                            }),
                            activeColor: AppColors.primaryClr,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.darkHeaderClr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: tempPermissions['owner']?['delete'] ?? false,
                            onChanged: (value) => setState(() {
                              if (tempPermissions['owner'] == null) {
                                tempPermissions['owner'] = {};
                              }
                              tempPermissions['owner']?['delete'] = value;
                            }),
                            activeColor: AppColors.primaryClr,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _kSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View File'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(_kSpacing),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kBorderRadius),
                        ),
                      ),
                      onPressed: () async {
                        final filePath = doc.metadata['filePath'];
                        if (filePath == null || filePath.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('File path not available.')),
                          );
                          return;
                        }

                        final hasViewPermission =
                            doc.permissions['owner']?['view'] ?? false;
                        if (!hasViewPermission) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'You do not have permission to view this file.'),
                            ),
                          );
                          return;
                        }

                        if (doc.type == 'PDF') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PDFViewerScreen(filePath: filePath),
                            ),
                          );
                        } else {
                          try {
                            final compatibleFilePath =
                                filePath.replaceAll('\\', '/');
                            await OpenFilex.open(compatibleFilePath);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to open file: ${e.toString()}')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kSpacing,
                    vertical: _kSpacing / 2,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  final updatedDoc = Document(
                    id: doc.id,
                    name: doc.name,
                    type: doc.type,
                    size: doc.size,
                    tags: tags,
                    metadata: doc.metadata,
                    folderId: doc.folderId,
                    permissions: tempPermissions,
                  );
                  context.read<DocumentBloc>().add(UpdateDocument(updatedDoc));
                  Navigator.pop(dialogContext);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kSpacing,
                    vertical: _kSpacing / 2,
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: _kSpacing / 2),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _CustomChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDeleted,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle:
          TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
      deleteIconColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}

class _CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CustomCheckboxListTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: _kSpacing / 2),
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

// Function to show file upload dialog
Future<void> showFileUploadDialog(BuildContext context, String folderId) async {
  final fileNameController = TextEditingController();
  List<String> tags = [];
  String? tagError;
  Map<String, dynamic> permissions = {
    'owner': {'view': true, 'edit': true, 'delete': true, 'download': true},
  };
  XFile? pickedFile;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_kBorderRadius),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: _kSpacing / 2),
                Text(
                  'Upload New File',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: fileNameController,
                    decoration: InputDecoration(
                      hintText: 'File Name',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_kBorderRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: _kSpacing,
                        vertical: _kSpacing / 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: _kSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: Text(
                          pickedFile == null ? 'Pick File' : pickedFile!.name),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(_kSpacing),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_kBorderRadius),
                        ),
                      ),
                      onPressed: () async {
                        final result = await openFile();
                        if (result != null) {
                          final fileSize = await result.length();
                          if (fileSize > 50 * 1024 * 1024) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('File size exceeds 50MB.')),
                            );
                            setState(() => pickedFile = null);
                          } else {
                            setState(() => pickedFile = result);
                          }
                        } else {
                          setState(() => pickedFile = null);
                        }
                      },
                    ),
                  ),
                  if (pickedFile != null)
                    Padding(
                      padding: const EdgeInsets.only(top: _kSpacing / 2),
                      child: Text(
                        'Selected: ${pickedFile!.name}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: _kSpacing),
                  Text(
                    'Tags',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: _kSpacing / 2),
                  Wrap(
                    spacing: _kChipSpacing,
                    runSpacing: _kChipSpacing,
                    children: tags
                        .map((tag) => _CustomChip(
                              label: tag,
                              onDeleted: () => setState(() => tags.remove(tag)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: _kSpacing / 2),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Add tag',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(_kBorderRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: _kSpacing,
                        vertical: _kSpacing / 2,
                      ),
                    ),
                    onSubmitted: (newTag) {
                      if (newTag.trim().isNotEmpty &&
                          !tags.contains(newTag.trim())) {
                        setState(() => tags.add(newTag.trim()));
                      }
                    },
                  ),
                  const SizedBox(height: _kSpacing),
                  Text(
                    'Permissions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: _kSpacing / 2),
                  Card(
                    elevation: 0,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'View',
                            style: TextStyle(
                              color: AppColors.darkHeaderClr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: permissions['owner']?['view'] ?? false,
                            onChanged: (value) => setState(() {
                              if (permissions['owner'] == null)
                                permissions['owner'] = {};
                              permissions['owner']['view'] = value ?? false;
                            }),
                            activeColor: AppColors.primaryClr,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.darkHeaderClr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: permissions['owner']?['edit'] ?? false,
                            onChanged: (value) => setState(() {
                              if (permissions['owner'] == null)
                                permissions['owner'] = {};
                              permissions['owner']['edit'] = value ?? false;
                            }),
                            activeColor: AppColors.primaryClr,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(
                            'Download',
                            style: TextStyle(
                              color: AppColors.darkHeaderClr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: permissions['owner']?['download'] ?? false,
                            onChanged: (value) => setState(() {
                              if (permissions['owner'] == null)
                                permissions['owner'] = {};
                              permissions['owner']['download'] = value ?? false;
                            }),
                            activeColor: AppColors.primaryClr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kSpacing,
                    vertical: _kSpacing / 2,
                  ),
                ),
              ),
              FilledButton(
                onPressed: pickedFile == null
                    ? null
                    : () async {
                        if (fileNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('File name cannot be empty.')),
                          );
                          return;
                        }

                        final newDocument = Document(
                          id: const Uuid().v4(),
                          name: fileNameController.text.trim(),
                          type: pickedFile!.mimeType ?? 'unknown',
                          size: await pickedFile!.length(),
                          folderId: folderId,
                          tags: tags,
                          metadata: {
                            'filePath': pickedFile!.path != null
                                ? pickedFile!.path!
                                : '',
                            'originalName': pickedFile!.name,
                          },
                          permissions: permissions,
                        );

                        context
                            .read<DocumentBloc>()
                            .add(AddDocument(newDocument));
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('File ${newDocument.name} uploaded.')),
                        );
                      },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _kSpacing,
                    vertical: _kSpacing / 2,
                  ),
                ),
                child: const Text('Upload'),
              ),
            ],
          );
        },
      );
    },
  );
}
