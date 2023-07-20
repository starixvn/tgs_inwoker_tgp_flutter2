import 'package:api/extension/screen_apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    Key? key,
    this.width = 20.0,
    this.height = 20.0,
    this.color,
    this.borderColor,
    this.iconSize,
    required this.onChanged,
    this.isChecked,
    this.activeIconColor,
    this.inactiveIconColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
  }) : super(key: key);

  final double width;
  final double height;
  final Color? color;
  final Color? borderColor;

  // Now you can set the checkmark size of your own
  final double? iconSize;
  final VoidCallback onChanged;
  final bool? isChecked;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? activeBackgroundColor;
  final Color? inactiveBackgroundColor;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool isChecked = widget.isChecked ?? false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => isChecked = !isChecked);
        widget.onChanged?.call();
      },
      child: Container(
        margin: EdgeInsets.only(left: 10.auto, right: 5.auto),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isChecked ? widget.activeBackgroundColor : widget.inactiveBackgroundColor,
          // color: isChecked ? widget.checkColor : Colors.transparent,
          border: Border.all(
            color: widget.borderColor ?? Colors.grey.shade500,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Icon(
          Icons.check,
          size: widget.iconSize,
          color: isChecked ? widget.activeIconColor : widget.inactiveIconColor,
          //color: isChecked ? Colors.black : widget.checkColor,
        ),
      ),
    );
  }
}
