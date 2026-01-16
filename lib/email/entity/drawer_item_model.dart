import 'package:flutter/cupertino.dart';

class DrawerItemModel {
  final IconData? icon;
  final String title;
  final String? badge;
  final Color? badgeColor;
  final bool selected;
  final bool isHeader;

  DrawerItemModel({
    this.icon,
    required this.title,
    this.badge,
    this.badgeColor,
    this.selected = false,
    this.isHeader = false,
  });
}

