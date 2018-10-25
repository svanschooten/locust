import 'package:flutter/material.dart';

typedef FloatingActionButtonCallback = FloatingActionButton Function(BuildContext context);

class Page {
  Tab _tab;
  Tab get tab => _tab;

  Icon _icon;
  Icon get icon => _icon;

  IconData _iconData;
  IconData get iconData => _iconData;

  String _title;
  String get title => _title;

  Widget _content;
  Widget get content => _content;

  FloatingActionButtonCallback _createFloatingActionButtong;
  FloatingActionButtonCallback get createFloatingActionButtong => _createFloatingActionButtong;

  Page(String title, IconData iconData, Widget content, {FloatingActionButtonCallback createFloatingActionButton}) {
    this._title = title;
    this._iconData = iconData;
    this._icon = new Icon(this._iconData);
    this._tab = new Tab(
      icon: _icon,
      text: _title,
    );
    this._content = content;
    this._createFloatingActionButtong = createFloatingActionButton;
  }
}