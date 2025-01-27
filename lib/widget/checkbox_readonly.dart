import 'package:flutter/material.dart';

class HeardAboutSchoolCheckboxes extends StatefulWidget {
  final String heardAboutSchool;
  final ValueChanged<Set<String>> onSelectionChanged;
  final TextEditingController? othersController;

  const HeardAboutSchoolCheckboxes({
    Key? key,
    required this.heardAboutSchool,
    required this.onSelectionChanged,
    this.othersController,
  }) : super(key: key);

  @override
  _HeardAboutSchoolCheckboxesState createState() =>
      _HeardAboutSchoolCheckboxesState();
}

class _HeardAboutSchoolCheckboxesState extends State<HeardAboutSchoolCheckboxes> {
  final List<Map<String, dynamic>> firstColumnOptions = [
    {'value': 'Online Search', 'title': 'Online Search (Google, School Website, etc)'},
    {'value': 'Social Media', 'title': 'Social Media (Facebook, Instagram, Youtube, Tiktok)'},
    {'value': 'Word of Mouth', 'title': 'Word of Mouth (Friends, Family, Colleagues)'},
    {'value': 'School events', 'title': 'School Events or Open Houses'}
  ];

  final List<Map<String, dynamic>> secondColumnOptions = [
    {'value': 'Brochures', 'title': 'Brochures/Flyers'},
    {'value': 'Education Fairs', 'title': 'Education Fairs/Expos'},
    {'value': 'Ads', 'title': 'Local Advertisements (Newspapers, Billboards, etc)'},
    {'value': 'Others', 'title': 'Others (Please specify)'}
  ];

  Set<String> selectedOptions = {};

  @override
  void initState() {
    super.initState();

    // Delay the setState call to avoid the error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This block will run after the current frame has been built
      List<String> heardAboutList = widget.heardAboutSchool.split(',');
      setState(() {
        selectedOptions.addAll(heardAboutList);
      });
      widget.onSelectionChanged(selectedOptions);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row to hold two columns
        Row(
          children: [
            // First Column
            Expanded(
              child: Column(
                children: [
                  ...firstColumnOptions.map((option) {
                    return Row(
                      children: [
                        // Checkbox aligned to the left side of the text
                        Checkbox(
                          value: selectedOptions.contains(option['value']),
                          onChanged: null, // Disable the checkbox (not clickable)
                        ),
                        Text(option['title']),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            // Second Column
            Expanded(
              child: Column(
                children: [
                  ...secondColumnOptions.map((option) {
                    return Row(
                      children: [
                        // Checkbox aligned to the left side of the text
                        Checkbox(
                          value: selectedOptions.contains(option['value']),
                          onChanged: null, // Disable the checkbox (not clickable)
                        ),
                        Text(option['title']),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
        if (selectedOptions.contains('Others'))
          TextField(
            controller: widget.othersController,
            decoration: const InputDecoration(
              labelText: 'Please specify',
              hintText: 'Enter other sources of information',
              border: OutlineInputBorder(),
            ),
            enabled: false, // Disabled (read-only)
            readOnly: true, // Read-only (not editable)
          ),
      ],
    );
  }
}
