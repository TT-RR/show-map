import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  DetailPage(this.heroTag, this.body, this.name);

  String heroTag;
  String body;
  String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Hero(
          tag: heroTag,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              color: Colors.white,
              child: Column(children: <Widget>[
                //画像
                Expanded(
                  flex: 3,
                  child: Container(
                    child: imageContents(context),
                  ),
                ),
                //タイトル
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      name + "\n",
                      overflow: TextOverflow.visible,
                      style: TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                //本文
                Expanded(
                  flex: 4,
                  child: Container(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        body + "\n\n",
                        overflow: TextOverflow.visible,
                        textScaleFactor: 1.3,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          )),
    );
  }

  Widget imageContents(BuildContext context) {
    dynamic dragstart;
    return Container(
      height: 277,
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onVerticalDragDown: (details) {
              dragstart = details.localPosition.dy;
            },
            onVerticalDragUpdate: (details) {
              if (details.localPosition.dy - dragstart > 50) {
                Navigator.pop(context);
              }
            },
            child: Center(
              child: Image.network(
                "https://nkc-showmap.com/" + heroTag,
                fit: BoxFit.fill,
              ),
            ),
          ),
          //閉じるボタン
          Column(
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
