import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
void main() => runApp(const MyApp());

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

//             PAGE 1 == Willkommen,Welcome,Bienvenue, in Cabaret, au Cabaret!!!!!!
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

//              PAGE 2 == Options Page
class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

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
              subtitle: 'Pick images from your gallery',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhotoPickerPage()),
                );
              },
            ),
            optionCard(
              title: 'Option 1',
              subtitle: 'classic hehe',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OptionTwoPage()),
                );
              },
            ),
            optionCard(
              title: 'Option 2: cat variant',
              subtitle: 'guess a cat',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OptionThreePage()),
                );
              },
            ),
            const Spacer(),
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

//          OPTION 1 PAGE: PHOTO PICKER 
class PhotoPickerPage extends StatefulWidget {
  const PhotoPickerPage({super.key});

  @override
  State<PhotoPickerPage> createState() => _PhotoPickerPageState();
}

class _PhotoPickerPageState extends State<PhotoPickerPage> {
  final ImagePicker _picker = ImagePicker();

  final List<Uint8List> _imageBytes = [];

  static const int requiredCount = 24;

  Future<void> _pickMultiple() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    // Read bytes for each picked file
    final newBytes = <Uint8List>[];
    for (final x in picked) {
      if (_imageBytes.length + newBytes.length >= requiredCount) break;
      newBytes.add(await x.readAsBytes());
    }

    setState(() {
      _imageBytes.addAll(newBytes);

      // Safety cap at 24
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
        title: const Text('Option 1: Upload 24 Photos'),
        actions: [
          IconButton(
            onPressed: _imageBytes.isEmpty ? null : _clear,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear',
          )
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
                    onPressed: _imageBytes.length >= requiredCount ? null : _pickMultiple,
                    icon: const Icon(Icons.collections_outlined),
                    label: const Text('Pick Photos'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canFinish ? () => Navigator.pop(context, true) : null,
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () => _removeAt(index),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _imageBytes[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
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

//Option 2: Guess A cat
class OptionTwoPage extends StatelessWidget {
  const OptionTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cat mode')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PageThree()),
            );
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}

// Option 3
class OptionThreePage extends StatelessWidget {
  const OptionThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classic mode')),
      body: const Center(
        child: Text('Just a characters'),
      ),
    );
  }
}

//                  PAGE 3== THE GAME itself
class PageThree extends StatelessWidget {
  const PageThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THE GAME')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This is Page 3'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Goes back to the first page by removing all routes above it
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('EXIT'),
            ),
          ],
        ),
      ),
    );
  }
}