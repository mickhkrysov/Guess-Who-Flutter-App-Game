import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'page_three.dart';
import 'photo_picker_page.dart';

enum SelectedOption { picker, optionTwo, optionThree }

class OptionResult {
  final String optionName;

  // For uploaded photos
  final List<Uint8List>? pickedImages;
  final Uint8List? selectedPickedImage;

  // For asset photos
  final List<String>? assetPaths;
  final String? selectedAssetPath;

  final SelectedOption option;

  const OptionResult({
    required this.optionName,
    required this.option,
    this.pickedImages,
    this.selectedPickedImage,
    this.assetPaths,
    this.selectedAssetPath,
  });

  bool get isPicked => pickedImages != null && pickedImages!.isNotEmpty;
}

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
      appBar: AppBar(title: const Text('Choose an option')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            optionCard(
              title: 'Load Your Photos',
              subtitle: 'Pick images',
              onTap: () => _openOption(const PhotoPickerPage()),
            ),
            optionCard(
              title: 'Option Two',
              subtitle: 'guess a cat',
              onTap: () => _openOption(const OptionTwoPage()),
            ),
            optionCard(
              title: 'Option Three',
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

// OPTION TWO
class OptionTwoPage extends StatefulWidget {
  const OptionTwoPage({super.key});

  @override
  State<OptionTwoPage> createState() => _OptionTwoPageState();
}

class _OptionTwoPageState extends State<OptionTwoPage> {
  final List<String> images =
      List.generate(24, (i) => 'assets/cats/${i + 1}.jpeg');

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Option Two - Pick one picture")),
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
                          option: SelectedOption.optionTwo,
                          assetPaths: images,
                          selectedAssetPath: images[selectedIndex!],
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

// OPTION THREE (assets)
class OptionThreePage extends StatefulWidget {
  const OptionThreePage({super.key});

  @override
  State<OptionThreePage> createState() => _OptionThreePageState();
}

class _OptionThreePageState extends State<OptionThreePage> {
  final List<String> images =
      List.generate(24, (i) => 'assets/characters/${i + 1}.jpeg');

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Option Three - Pick one picture")),
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
                          optionName: 'Option Three (Character mode)',
                          option: SelectedOption.optionThree,
                          assetPaths: images,
                          selectedAssetPath: images[selectedIndex!],
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