import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'page_two.dart';

// PAGE 3
class PageThree extends StatefulWidget {
  final OptionResult result;

  const PageThree({super.key, required this.result});

  @override
  State<PageThree> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<PageThree> {
  final Set<int> greyedIndexes = {};
  bool _dialogShown = false;

  int get totalCount =>
      widget.result.isPicked ? widget.result.pickedImages!.length : widget.result.assetPaths!.length;

  int get remainingCount => totalCount - greyedIndexes.length;

  Future<void> toggleIndex(int index) async {
    setState(() {
      if (greyedIndexes.contains(index)) {
        greyedIndexes.remove(index);
      } else {
        greyedIndexes.add(index);
      }
    });

    if (remainingCount == 1 && !_dialogShown) {
      _dialogShown = true;

      final bool? guessedCorrectly = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(guessedCorrectly == true ? "You Win!" : "You lost."),
        ),
      );
    }

    if (remainingCount > 1) _dialogShown = false;
  }

  Widget _buildImageTile(int i) {
    final isGreyed = greyedIndexes.contains(i);

    final Widget imageWidget;
    if (widget.result.isPicked) {
      final Uint8List bytes = widget.result.pickedImages![i];
      imageWidget = Image.memory(bytes, fit: BoxFit.cover);
    } else {
      final String path = widget.result.assetPaths![i];
      imageWidget = Image.asset(path, fit: BoxFit.cover);
    }

    return InkWell(
      onTap: () => toggleIndex(i),
      child: Opacity(
        opacity: isGreyed ? 0.5 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildChosen() {
    if (widget.result.isPicked) {
      final chosen = widget.result.selectedPickedImage;
      if (chosen == null) return const Text("No chosen picture.");
      return Image.memory(chosen, height: 120, fit: BoxFit.contain);
    } else {
      final chosen = widget.result.selectedAssetPath;
      if (chosen == null) return const Text("No chosen picture.");
      return Image.asset(chosen, height: 120, fit: BoxFit.contain);
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
            widget.result.optionName,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: totalCount,
              itemBuilder: (context, i) => _buildImageTile(i),
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text("Chosen picture"),
                const SizedBox(height: 8),
                _buildChosen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}