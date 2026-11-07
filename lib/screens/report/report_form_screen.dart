import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_colors.dart';
import '../../core/validators.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/reports/report_cubit.dart';
import '../../models/app_user.dart';
import '../../models/enums.dart';
import '../../models/report.dart';
import '../../services/storage_service.dart';
import '../../widgets/category_tile.dart';

/// Screen 3. Category first, because the category is what staff triage by -
/// it is the most important field on the form, so it gets the top of the page.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key, this.storage});

  final StorageService? storage;

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();

  late final StorageService _storage = widget.storage ?? StorageService();

  ReportCategory? _category;
  String? _categoryError;
  final List<XFile> _photos = <XFile>[];
  bool _uploading = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _addPhoto(ImageSource source) async {
    if (_photos.length >= StorageService.maxPhotos) {
      _showMessage('You can attach up to ${StorageService.maxPhotos} photos.');
      return;
    }
    try {
      final XFile? file = await _storage.pick(source);
      if (file == null) return;
      setState(() => _photos.add(file));
    } catch (error) {
      _showMessage('Could not open the picker: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    final bool formOk = _formKey.currentState?.validate() ?? false;
    final bool categoryOk = _category != null;

    setState(() => _categoryError =
        categoryOk ? null : 'Choose a category for this issue');
    if (!formOk || !categoryOk) return;

    final AppUser? user = context.read<AuthCubit>().user;
    if (user == null) return;

    // Captured before the await so we never touch BuildContext afterwards.
    final ReportCubit reports = context.read<ReportCubit>();

    setState(() => _uploading = true);
    try {
      final List<String> urls = <String>[];
      for (final XFile photo in _photos) {
        urls.add(await _storage.upload(uid: user.uid, file: photo));
      }

      final bool created = await reports.submit(
            Report(
              id: '',
              title: _title.text.trim(),
              description: _description.text.trim(),
              category: _category!,
              locationLabel: _location.text.trim(),
              photoUrls: urls,
              submittedByUid: user.uid,
              submittedByName: user.name,
            ),
          );

      if (!mounted) return;
      if (created) {
        Navigator.of(context).pop();
        _showMessage('Report submitted. Thank you!');
      } else {
        _showMessage(
          reports.state.error ??
              'Could not submit the report. Please try again.',
        );
      }
    } catch (error) {
      _showMessage(
        error is StorageException
            ? error.message
            : 'Upload failed. Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool saving = context.watch<ReportCubit>().state.saving;
    final bool busy = saving || _uploading;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: <Widget>[
            const Text(
              'Select a category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
              children: ReportCategory.values.map((ReportCategory c) {
                return CategoryTile(
                  category: c,
                  selected: _category == c,
                  onTap: () => setState(() {
                    _category = c;
                    _categoryError = null;
                  }),
                );
              }).toList(),
            ),
            if (_categoryError != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                _categoryError!,
                style: const TextStyle(fontSize: 12, color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 20),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Briefly describe the issue...',
              ),
              validator: Validators.title,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Provide more details... e.g. what happened, when, impact.',
                alignLabelWithHint: true,
              ),
              validator: Validators.description,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Block B - Room 204',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: Validators.location,
            ),
            const SizedBox(height: 20),
            const Text(
              'Add a photo (optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            _PhotoPicker(
              photos: _photos,
              onAdd: (ImageSource source) => _addPhoto(source),
              onRemove: (int index) => setState(() => _photos.removeAt(index)),
            ),
            if (_photos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_photos.length} photo${_photos.length == 1 ? '' : 's'} '
                  'attached - uploaded when you submit',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: busy ? null : _submit,
            child: busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit Report'),
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final List<XFile> photos;
  final void Function(ImageSource source) onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        ...photos.asMap().entries.map((MapEntry<int, XFile> entry) {
          return Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FutureBuilder<Uint8List>(
                  future: entry.value.readAsBytes(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Uint8List> snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Container(
                        width: 74,
                        height: 74,
                        color: AppColors.border,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 20,
                          color: AppColors.muted,
                        ),
                      );
                    }
                    return Image.memory(
                      snapshot.data!,
                      width: 74,
                      height: 74,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => onRemove(entry.key),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        if (photos.length < StorageService.maxPhotos)
          InkWell(
            onTap: () => _chooseSource(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.camera_alt_outlined,
                      size: 20, color: AppColors.muted),
                  SizedBox(height: 4),
                  Text(
                    'Add',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _chooseSource(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheet);
                onAdd(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheet);
                onAdd(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
