import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:api/extension/screen_apis.dart';
import 'package:tgp_flutter2/src/custom_color.dart';
import 'package:tgp_flutter2/base_state.dart';

class CustomPasswordTextFormField extends StatefulWidget {
  final String title;
  final String hintText;
  final ValueChanged<String> onFieldSubmitted;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final double width;
  final bool obscurePassword;
  final Function onShowPassword;

  CustomPasswordTextFormField(
      {Key key,
        this.title,
        this.hintText,
        this.onChanged,
        this.onFieldSubmitted,
        this.controller,
        this.width,
        this.obscurePassword,
        this.onShowPassword})
      : super(key: key);

  @override
  _CustomPasswordTextFormFieldState createState() => _CustomPasswordTextFormFieldState();
}

class _CustomPasswordTextFormFieldState extends BaseState<CustomPasswordTextFormField> {
  Widget build(BuildContext context) {
    return Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 5,
        //margin:EdgeInsets.only(top:15.auto,),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 15.auto, horizontal: 20.auto),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Container(
              width: widget.width,
              alignment: Alignment.topLeft,
              child: Text(
                widget.title,
                style: TextStyle(color: Colors.black, fontSize: 9.auto),
                textAlign: TextAlign.start,
              ),
            ),
            Container(
              width: widget.width, //widget.width,
              height: 40.auto,
              child: TextFormField(
                enabled: true,
                autofocus: false,
                onChanged: (value) => widget.onChanged(value),
                controller: widget.controller,
                onFieldSubmitted: (value) => widget.onChanged(value),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                obscureText: widget.obscurePassword,
                style: TextStyle(color: CustomColor.theme_text_black_color, fontSize: 13.auto),
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: TextStyle(color: CustomColor.very_light_pink_two, fontSize: 13.auto),
                    suffixIcon:IconButton(
                      iconSize: 18.auto,
                      padding: EdgeInsets.zero,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(widget.obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: CustomColor.very_light_pink_two),
                      onPressed: () => widget.onShowPassword(),
                    )
                ),
              ),
            ),
          ]),
        ));
  }
}
