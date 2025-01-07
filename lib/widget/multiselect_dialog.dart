import 'package:flutter/material.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;

  MultiSelectDialog({required this.items, required this.selectedItems});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> tempSelectedItems;

  @override
  void initState() {
    super.initState();
    tempSelectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Grades'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: tempSelectedItems.contains(item),
              title: Text(item),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    tempSelectedItems.add(item);
                  } else {
                    tempSelectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, tempSelectedItems),
          child: const Text('OK'),
        ),
      ],
    );
  }
}