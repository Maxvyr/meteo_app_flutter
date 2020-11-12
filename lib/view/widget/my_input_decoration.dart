import 'package:flutter/material.dart';
import '../../controller/color.dart';
import '../../controller/constants.dart' as constants;

class MyInputDecoration extends InputDecoration {
  MyInputDecoration({
    borderRadius: 2.0,
    borderRadiusFocused: 12.0,
    width: 2.0,
    color: indigo,
  }) : super(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2.0),
            borderSide: BorderSide(
              width: 2.0,
              color: indigo,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              width: 2.0,
              color: indigo,
            ),
          ),
          prefixIcon: Icon(Icons.location_city_rounded),
          contentPadding: EdgeInsets.symmetric(horizontal: 6.0),
          labelText: constants.city,
        );
}
