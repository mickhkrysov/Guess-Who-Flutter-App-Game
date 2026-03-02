import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

enum SelectedOption { optionTwo, optionThree }

class GuessWhoResult {
  final SelectedOption option;
  final List<String> images;   // ALL images
  final String selectedImage;  // chosen one

  const GuessWhoResult({
    required this.option,
    required this.images,
    required this.selectedImage,
  });
}

class OptionResult {
  final String optionName;

  final List<Uint8List>? pickedImages;
  final List<String>? assetPaths;
  final SelectedOption? option;
  final String? imageAsset;
  final String? selectedImage;

  const OptionResult({
    required this.optionName,
    this.pickedImages,
    this.assetPaths,
    this.option,
    this.imageAsset,
    this.selectedImage,
  });

  List<String> get images => assetPaths ?? [];
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess Who Game',
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

// PAGE 2 
class PageTwo extends StatefulWidget {
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  OptionResult? _result;

  Future<void> goToOption(BuildContext context, Widget page) async {
    final result = await Navigator.push<OptionResult>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PageThree(result: result),
        ),
      );
    }
  }


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
      appBar: AppBar(title: const Text('Choose an option')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            optionCard(
              title: 'Load Your Photos',
              subtitle: 'Pick 24 images',
              onTap: () => _openOption(const PhotoPickerPage()),
            ),
            optionCard(
              title: 'Option 1',
              subtitle: 'guess a cat',
              onTap: () => _openOption(const OptionTwoPage()),
            ),
            optionCard(
              title: 'Option 2',
              subtitle: 'guess a character',
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

// OPTION 1: PHOTO PICKER 
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

// OPTION 2 (Cat mode)
class OptionTwoPage extends StatefulWidget {
  const OptionTwoPage({super.key});

  @override
  State<OptionTwoPage> createState() => _OptionTwoPageState();
}

class _OptionTwoPageState extends State<OptionTwoPage> {
  final List<String> images = List.generate(
      24,
      (i) => 'assets/cats/${i + 1}.jpeg',
    );

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Option Two - Pick one picture to guess")),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text("Tap one picture to select it"),

          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: images.length,
              itemBuilder: (context, i) {
                final isSelected = selectedIndex == i;
                return InkWell(
                  onTap: () => setState(() => selectedIndex = i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: isSelected ? 4 : 1,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(images[i], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: selectedIndex == null
                ? null
                : () {
                    Navigator.pop(
                      context,
                      OptionResult(
                        optionName: 'Option Two (Cat mode)',
                        assetPaths: images,
                        imageAsset: images[selectedIndex!],
                        selectedImage: images[selectedIndex!],
                        option: SelectedOption.optionTwo,
                      ),
                    );
                  },
            child: const Text("Done"),
          ),
        ),
        ],
      ),
    );
  }
}

// OPTION 3
class OptionThreePage extends StatefulWidget {
  const OptionThreePage({super.key});

  @override
  State<OptionThreePage> createState() => _OptionThreePageState();
}

class _OptionThreePageState extends State<OptionThreePage> {
  final List<String> images = List.generate(
      24,
      (i) => 'assets/cats/${i + 1}.jpeg',
    );

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Option Three - Pick ONE pic to guess")),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text("Tap one picture to select it"),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: images.length,
              itemBuilder: (context, i) {
                final isSelected = selectedIndex == i;
                return InkWell(
                  onTap: () => setState(() => selectedIndex = i),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: isSelected ? 4 : 1,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(images[i], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: selectedIndex == null
                  ? null
                  : () {
                      Navigator.pop(
                        context,
                        GuessWhoResult(
                          option: SelectedOption.optionThree,
                          images: images,
                          selectedImage: images[selectedIndex!],
                        ),
                      );
                    },
              child: const Text("Done"),
            ),
          ),
        ],
      ),
    );
  }
}

// PAGE 3
class PageThree extends StatefulWidget {
  final OptionResult result;

  const PageThree({super.key, required this.result});

  @override
  State<PageThree> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<PageThree> {
  final Set<String> greyedImages = {};
  bool _dialogShown = false;

  int get remainingCount => widget.result.images.length - greyedImages.length;

  Future<void> toggleImage(String image) async {
    setState(() {
      if (greyedImages.contains(image)) {
        greyedImages.remove(image); // un-grey
      } else {
        greyedImages.add(image); // grey
      }
    });

    // ✅ If only one image left and dialog not already shown
    if (remainingCount == 1 && !_dialogShown) {
      _dialogShown = true;

      final bool? guessedCorrectly = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must press a button
        builder: (context) {
          return AlertDialog(
            title: const Text("Only one left!"),
            content: const Text("Did you guess correctly?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );

      // Optional: respond to their choice
      if (!mounted) return;

      if (guessedCorrectly == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You Win!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You lost.")),
        );
      }
    }

    // Reset dialog flag if player goes back to more than 1 remaining
    if (remainingCount > 1) {
      _dialogShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("The game")),
      body: Column(
        children: [
          const SizedBox(height: 12),

          Text(
            widget.result.option == SelectedOption.optionTwo
                ? "Option Two Photos"
                : "Option Three Photos",
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 12),

          // all photos with toggle behavior
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.result.images.length,
              itemBuilder: (context, i) {
                final image = widget.result.images[i];
                final isGreyed = greyedImages.contains(image);

                return InkWell(
                  onTap: () => toggleImage(image),
                  child: Opacity(
                    opacity: isGreyed ? 0.5 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Chosen image still shown at bottom (unchanged)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text("Chosen picture"),
                const SizedBox(height: 8),
                Image.asset(
                  widget.result.selectedImage ?? '',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}