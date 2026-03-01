import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

/// This is what an option returns back to Page 2.
/// Page 2 then passes it to Page 3 to display the images.
class OptionResult {
  final String optionName;

  // For gallery-picked photos (Web + Mobile): store bytes
  final List<Uint8List>? pickedImages;

  // For bundled assets (Image.asset): store asset paths
  final List<String>? assetPaths;

  const OptionResult({
    required this.optionName,
    this.pickedImages,
    this.assetPaths,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Three Pages App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

// PAGE 1
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to a "Guess Who" game!')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PageTwo()),
                );
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

// PAGE 2 (locks Page 3 until an option is completed)
class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  OptionResult? _result;

  Future<void> _openOption(Widget optionPage) async {
    final res = await Navigator.push<OptionResult>(
      context,
      MaterialPageRoute(builder: (_) => optionPage),
    );

    if (res != null) {
      setState(() => _result = res);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget optionCard({
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Card(
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Page 2: Choose an option')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            optionCard(
              title: 'Load Your Photos',
              subtitle: 'Pick EXACTLY 24 images (unlocks Page 3)',
              onTap: () => _openOption(const PhotoPickerPage()),
            ),
            optionCard(
              title: 'Option 1',
              subtitle: 'classic hehe (2 cat images)',
              onTap: () => _openOption(const OptionTwoPage()),
            ),
            optionCard(
              title: 'Option 2: cat variant',
              subtitle: 'guess a cat (placeholder)',
              onTap: () => _openOption(const OptionThreePage()),
            ),

            const SizedBox(height: 12),
            Text(
              _result == null
                  ? 'You must complete ONE option to unlock Page 3.'
                  : 'Completed: ${_result!.optionName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _result == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PageThree(result: _result!),
                        ),
                      );
                    },
              child: const Text('Go to Page 3'),
            ),

            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Page 1'),
            ),
          ],
        ),
      ),
    );
  }
}

// OPTION 1: PHOTO PICKER (must pick 24)
class PhotoPickerPage extends StatefulWidget {
  const PhotoPickerPage({super.key});

  @override
  State<PhotoPickerPage> createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  final ImagePicker _picker = ImagePicker();

  // Store image BYTES so it works on Web + Mobile
  final List<Uint8List> _imageBytes = [];

  static const int requiredCount = 24;

  Future<void> _pickMultiple() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    // Read bytes (cap at 24)
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

  void _removeAt(int index) => setState(() => _imageBytes.removeAt(index));
  void _clear() => setState(() => _imageBytes.clear());

  bool get _canFinish => _imageBytes.length == requiredCount;

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
                            // Return images to Page 2
                            Navigator.pop(
                              context,
                              OptionResult(
                                optionName: 'Your Photos (24)',
                                pickedImages:
                                    List<Uint8List>.from(_imageBytes),
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
                'Selected: ${_imageBytes.length}/$requiredCount',
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
                        return GestureDetector(
                          onLongPress: () => _removeAt(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              _imageBytes[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 6),
            const Text('Tip: long-press an image to remove it.'),
          ],
        ),
      ),
    );
  }
}

// OPTION 2 (Cat mode) - returns asset images
class OptionTwoPage extends StatelessWidget {
  const OptionTwoPage({super.key});

  static const List<String> catAssets = [
    'assets/cats/1.jpeg',
    'assets/cats/2.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cat mode')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cat mode, guess a meme cat'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < catAssets.length; i++) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      catAssets[i],
                      width: 260,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (i != catAssets.length - 1) const SizedBox(width: 20),
                ],
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Return assets to Page 2
                Navigator.pop(
                  context,
                  const OptionResult(
                    optionName: 'Cat mode',
                    assetPaths: catAssets,
                  ),
                );
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

// OPTION 3 (placeholder) - add your own assets if you want
class OptionThreePage extends StatelessWidget {
  const OptionThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classic mode')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Just a characters (add assets if you want)'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Return something (currently no images)
                Navigator.pop(
                  context,
                  const OptionResult(
                    optionName: 'Classic mode',
                    assetPaths: [],
                  ),
                );
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

// PAGE 3 (displays images from the chosen option)
class PageThree extends StatelessWidget {
  final OptionResult result;
  const PageThree({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final picked = result.pickedImages;
    final assets = result.assetPaths;

    Widget content;

    if (picked != null && picked.isNotEmpty) {
      content = GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: picked.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(picked[i], fit: BoxFit.cover),
        ),
      );
    } else if (assets != null && assets.isNotEmpty) {
      content = GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: assets.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(assets[i], fit: BoxFit.cover),
        ),
      );
    } else {
      content = const Center(
        child: Text('No images were provided by this option.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Page 3: ${result.optionName}')),
      body: content,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('EXIT'),
          ),
        ),
      ),
    );
  }
}
