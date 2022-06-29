import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RawPickerTest extends StatefulWidget {
  const RawPickerTest({Key? key}) : super(key: key);

  @override
  State<RawPickerTest> createState() => _RawPickerTestState();
}

class _RawPickerTestState extends State<RawPickerTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Raw Picker')),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 50),
          SizedBox(
            height: 320,
            child: Row(
              children: [
                Expanded(child: _buildCupertinoPicker(context, 0, 20, ValueKey(0))),
                Expanded(child: _buildCupertinoPicker(context, 1, 120, ValueKey(1))),
                Expanded(child: _buildCupertinoPicker(context, 2, 50, ValueKey(2))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCupertinoPicker(BuildContext context,
      int i, int _length, Key? key) {
    return CupertinoPicker.builder(
      key: key,
      scrollController: FixedExtentScrollController(),
      itemExtent: 42,
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
      childCount: _length,
      itemBuilder: (context, index) {
        return Text("$i.$index");
      },
      onSelectedItemChanged: (int _index) {
        if (_length <= 0) return;
        var index = _index % _length;
        print("onSelectedItemChanged. col: $i, row: $index");
      },
    );
  }
}
