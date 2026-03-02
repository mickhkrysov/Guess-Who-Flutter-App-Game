import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'page_two.dart';

class PhotoPickerPage extends StatefulWidget {
  const PhotoPickerPage({super.key});

  @override
  State<PhotoPickerPage> createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  final ImagePicker _picker = ImagePicker();
  final List<Uint8List> _imageBytes = [];
  int? _selectedIndex;

  static const int requiredCount = 24;

  Future<void> _pickMultiple() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    final newBytes = <Uint8List>[];
    for (final x in picked) {
      if (_imageBytes.length + newBytes.length >= requiredCount) break;
      newBytes.add(await x.readAsBytes());
    }

    setState(() {
      _imageBytes.addAll(newBytes);
      if (_imageBytes.length > requiredCount) {
        _imageBytes.removeRange(requiredCount, _imageBytes.length);
      }
    });
  }

  void _removeAt(int index) {
    setState(() {
      _imageBytes.removeAt(index);
      if (_selectedIndex != null) {
        if (_selectedIndex == index) _selectedIndex = null;
        if (_selectedIndex != null && _selectedIndex! > index) {
          _selectedIndex = _selectedIndex! - 1;
        }
      }
    });
  }

  void _clear() => setState(() {
        _imageBytes.clear();
        _selectedIndex = null;
      });

  bool get _canFinish =>
      _imageBytes.length == requiredCount && _selectedIndex != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload 24 Photos'),
        actions: [
          IconButton(
            onPressed: _imageBytes.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _imageBytes.length >= requiredCount ? null : _pickMultiple,
                    icon: const Icon(Icons.collections_outlined),
                    label: const Text('Pick Photos'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canFinish
                        ? () {
                            Navigator.pop(
                              context,
                              OptionResult(
                                optionName: 'Your Photos (24)',
                                option: SelectedOption.picker,
                                pickedImages: List<Uint8List>.from(_imageBytes),
                                selectedPickedImage: _imageBytes[_selectedIndex!],
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selected: ${_imageBytes.length}/$requiredCount  |  Pick ONE to be your “chosen”',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _imageBytes.isEmpty
                  ? const Center(child: Text('Pick photos until you reach 24.'))
                  : GridView.builder(
                      itemCount: _imageBytes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedIndex == index;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          onLongPress: () => _removeAt(index),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: isSelected ? 4 : 1,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _imageBytes[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 6),
            const Text('Tip: tap to choose one. Long-press to remove.'),
          ],
        ),
      ),
    );
  }
}