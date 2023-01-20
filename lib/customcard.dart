import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'detailpage.dart';

class CustomCard extends StatefulWidget {
  CustomCard(this.heroTag, this.body, this.name);

  String heroTag; //画像パス
  String body; //本文
  String name; //タイトル

  @override
  State<StatefulWidget> createState() {
    return CustomCardState(heroTag, body, name);
  }
}

class CustomCardState extends State<CustomCard> {
  CustomCardState(this.heroTag, this.body, this.name);

  String heroTag;
  String body;
  String name;

  var _hasPadding = false;
  dynamic dragstart;
  @override
  Widget build(
    BuildContext context,
  ) {
    return Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: content(),
        ));
  }

  Widget content() {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 80),
      padding: EdgeInsets.all(_hasPadding ? 10 : 0),
      child: GestureDetector(
        onTapDown: (TapDownDetails downDetails) {
          setState(() {
            _hasPadding = true;
          });
        },
        onTap: () {
          setState(() {
            _hasPadding = false;
          });
          Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => DetailPage(heroTag, body, name),
              ));
        },
        onTapCancel: () {
          setState(() {
            _hasPadding = false;
          });
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Image.network(
              "https://nkc-showmap.com/" + heroTag,
              fit: BoxFit.fill,
            ),
          ),
          elevation: 10,
        ),
      ),
    );
  }
}
