import 'package:flutter/material.dart';
import 'dart:io';
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
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return Card(
        child: ListTile(
          leading: Icon(icon, size: 32),
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
              icon: Icons.photo_library_outlined,
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
              icon: Icons.list_alt_outlined,
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
              icon: Icons.settings_outlined,
              title: 'Option 2',
              subtitle: 'another variant of the characters that you can try and guess',
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
  final List<XFile> _images = [];

  Future<void> _pickSingle() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _images.add(image));
    }
  }

  Future<void> _pickMultiple() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _images.addAll(images));
    }
  }

  void _clear() {
    setState(() => _images.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load Photos'),
        actions: [
          IconButton(
            onPressed: _images.isEmpty ? null : _clear,
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
                    onPressed: _pickSingle,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Pick 1 Photo'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickMultiple,
                    icon: const Icon(Icons.collections_outlined),
                    label: const Text('Pick Multiple'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _images.isEmpty
                  ? const Center(
                      child: Text('No photos selected yet.'),
                    )
                  : GridView.builder(
                      itemCount: _images.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final file = File(_images[index].path);
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(file, fit: BoxFit.cover),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

//Option
class OptionTwoPage extends StatelessWidget {
  const OptionTwoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Option 2')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PageThree()),
            );
          },
          child: const Text('Continue to Page 3'),
        ),
      ),
    );
  }
}

// Option
class OptionThreePage extends StatelessWidget {
  const OptionThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Option 3')),
      body: const Center(
        child: Text('Id like to top a big, hairy, and beefy muscular man so he would whimper when i would touch him'),
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