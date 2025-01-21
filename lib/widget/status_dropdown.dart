import 'package:flutter/material.dart';

class StatusDropdown extends StatefulWidget {
  final TextEditingController controller;
  final List<String> choices;
  final String title;

  const StatusDropdown({Key? key, required this.controller, required this.choices, required this.title}) : super(key: key);

  @override
  _StatusDropdownState createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<StatusDropdown> {
  List<String> statuses=[];
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    statuses=widget.choices;
    selectedStatus = widget.controller.text.isNotEmpty ? widget.controller.text : statuses.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration:  InputDecoration(
              labelText: widget.title,
              labelStyle: const TextStyle(color: Color(0xFF990000)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: const Color(0xFF990000).withOpacity(0.35),
                width: 2.0,),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF990000)),
              ),
            ),
      value: selectedStatus,
      icon: Icon(
              Icons.arrow_drop_down, // Arrow-down icon
              color: Colors.grey[400], // Icon color
            ),
      items: statuses.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status, style: const TextStyle(color: Color(0xFF990000), fontWeight: FontWeight.normal),),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedStatus = value;
          widget.controller.text = value!;
        });
      },
      dropdownColor: Colors.white,
    );
  }
}
