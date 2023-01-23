import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'customcard.dart';
import 'package:http/http.dart' as http;
import 'detailpage.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State createState() => MapSampleState();
}

class MapSampleState extends State {
  final Uri _url = Uri.parse('https://nkc-showmap.com/privacy-policy');
  final Completer _controller = Completer();
  final _pcontroller = PageController(viewportFraction: 0.8);
  bool titlevisible = true;
  bool titleanimation = true;
  double lat = 0;
  double lng = 0;
  LatLng selectedPlace = LatLng(0, 0); //現在選択中のmarkerの座標
  int selectedId = 0; //現在選択中のmarkerのID
  List<String> id = []; //データの数で連番
  List<String> name = []; //地点名
  List<String> reslat = []; //緯度
  List<String> reslng = []; //経度
  List<LatLng> cacheMapCenter = []; //表示中のmarkerの座標保存用
  List<int> cacheMarkerId = []; //表示中のmarkerのID保存用
  List<int> cat = []; //markerのカテゴリー
  List<String> body = []; //詳細画面の本文
  List<String> image = []; //画像パス
  List<String> cacheimage = []; //表示中のmarkerと対応した画像保存用
  List<bool> catbutton = List.filled(4, true);
  List<bool> catvisi = []; //カテゴリー絞り込み用
  List<dynamic> iconList = []; //markerのiconの画像パス
  int tmp_array_num = 0;
  bool notify_flag = false;

  int area_banner = 0;

  List<String> catname = ["歴史", "公共", "コラム", "その他"];
  dynamic catbutton_color = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.blue
  ];

  final List<String> area_name = [
    '松栄・御器所',
    '広路・川原・吹上',
    '鶴舞・村雲・白金',
    '滝川・伊勝',
    '八事・興正寺'
  ];

  bool flag = false;
  _click() async {
    setState(() {
      flag = false;
    });
  }

  static final CameraPosition _kNSK = CameraPosition(
    target: LatLng(35.14767682899567, 136.94207536929082),
    zoom: 13.40746,
  );

  static List<LatLng> _MapCenter = [];
  @override
  void initState() {
    super.initState();
    timer();
    rec();
  }

  void rec() async {
    Uri url = Uri.parse("https://nkc-showmap.com/app");
    dynamic res = await http.post(url, body: {
      'Auth1': 'PmB3Vi*SKHMd8bYOjX10+?Xr%',
      'Auth2': 'gx3*H@@.Iq1KdgAF!!wwZLEMZ',
      'Auth3': 'GvI_hJ12n_U117%P485we1x=@',
      'Auth4': 'p.P18I14TzOKM&=J6M=APrF!+'
    });

    dynamic jsondec = json.decode(res.body);
    for (int i = 0; i < jsondec.length; i++) {
      id.add(jsondec[i]['id']);
      name.add(jsondec[i]['name']);
      _MapCenter.add(LatLng(jsondec[i]['lat'], jsondec[i]['lon']));
      cat.add(jsondec[i]['cat']);
      pinasset(cat[i]);
      body.add(jsondec[i]['body']);
      image.add(jsondec[i]['image']);
      setState(() {
        id;
        name;
        reslat;
        reslng;
        cat;
        body;
        image;
      });
    }
    catvisi = List.filled(id.length, true);
    cacheimage = [...image];
    cacheMapCenter = [..._MapCenter];
    for (int j = 0; j < id.length; j++) {
      cacheMarkerId.add(j);
    }
  }

  void timer() async {
    cardvisible();
    await Future.delayed(const Duration(seconds: 4)); //4秒待
    setState(() {
      titleanimation = false;
    });
    await await Future.delayed(const Duration(seconds: 1)); //1秒待
    setState(() {
      titlevisible = false;
    });
  }

  Set<Marker> _createMarker() {
    Set<Marker> sm = {};
    int i = 0;
    _MapCenter.forEach((v) {
      sm.add(Marker(
        markerId: MarkerId(i.toString()),
        position: v,
        infoWindow: InfoWindow(title: name[i]),
        visible: catvisi[i],
        icon: iconList[i],
        onTap: () {
          selectedId = cacheMarkerId[markerIndex(v)]; //TapしたmarkerのID取得
          _click();
          _pcontroller.jumpToPage(
            markerIndex(v),
          );
        },
      ));
      i++;
    });
    return sm;
  }

  void pinasset(i) async {
    String pinColor;
    switch (i) {
      case 0: //歴史
        pinColor = "1.png";
        break;
      case 1: //公共
        pinColor = "2.png";
        break;
      case 2: //コラム
        pinColor = "3.png";
        break;
      case 3: //その他
        pinColor = "4.png";
        break;
      default: //一致なし
        pinColor = "1.png";
        break;
    }
    iconList.add(await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), judge() + pinColor));
  }

  void notify_flag_duration() async {
    setState(() {
      notify_flag = true;
    });
    await Future.delayed(const Duration(seconds: 4)); //4秒待
    setState(() {
      notify_flag = false;
    });
  }

  String judge() {
    if (Platform.isIOS) {
      return 'images/';
    } else {
      return 'images/android/';
    }
  }

  int markerIndex(v) {
    return cacheMapCenter.indexOf(v);
  }

  dynamic cardvisible() {
    setState(() {
      flag = true;
    });
    _hideInfoWindow();
  }

  dynamic dragstart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.center, children: <Widget>[
      Scaffold(
        appBar: AppBar(
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.blue),
            title: Container(
              height: 50,
              //child:Text('https://nkc-showmap.com/privacy-policy'),
              child: Image.asset(
                'images/showmap_title.png',
                fit: BoxFit.contain,
              ),
            ),
            backgroundColor: Colors.blue[100]),
        drawer: Drawer(
            child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: const Text(
                'メニュー',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue[300],
              ),
            ),
            ElevatedButton(
              onPressed: () async{
                final url = Uri.parse(
                  'https://nkc-showmap.com/privacy-policy',
                );
                if (await canLaunchUrl(url)) {
                  launchUrl(url);
                } else {
                  // ignore: avoid_print
                  print("Can't launch $url");
                }
              },
              child: const Text('プライバシーポリシー'),
            ),

            for (int i = 0; i < 4; i++)
              ListTile(
                leading: Image.asset("images/" + (i + 1).toString() + ".png"),
                title: Text(
                  catname[i],
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
                trailing: Switch(
                    value: catbutton[i],
                    activeColor: catbutton_color[i],
                    onChanged: (value) {
                      setState(() {
                        flag = true;
                        _hidePin();
                        cacheimage.clear();
                        cacheMapCenter.clear();
                        cacheMarkerId.clear();
                        catbutton[i] = value;
                        for (int j = 0; j < cat.length; j++) {
                          if (cat[j] == i) {
                            catvisi[j] = !catvisi[j];
                          }
                        }
                        for (int j = 0; j < cat.length; j++) {
                          if (catvisi[j] == true) {
                            cacheimage.add(image[j]);
                            cacheMapCenter.add(_MapCenter[j]);
                            cacheMarkerId.add(j);
                          }
                        }
                      });
                    }),
              ),
            const Divider(
              color: Colors.black,
            ),
            for (int i = 0; i < area_name.length; i++)
              Column(children: [
                ListTile(
                  title: Text(
                    area_name[i],
                    style: const TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      area_banner = i;
                    });

                    cardvisible();
                    _area(i);
                    notify_flag_duration();
                  },
                ),
                const Divider(
                  color: Colors.black,
                )
              ])
          ],
            )),
        body: Stack(alignment: Alignment.center, children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            markers: _createMarker(),
            initialCameraPosition: _kNSK,
            minMaxZoomPreference: MinMaxZoomPreference(
                13.121926040649414, 16.381926040649414), //ズームイン・ズームアウト制限
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              final googleMapstyle = await rootBundle.loadString(
                  'assets/jsons/google_map_style.json'); //カスタムMap読み込み
              _controller.complete(controller);
              controller.setMapStyle(googleMapstyle);
            },
          ),
          GestureDetector(
            onVerticalDragDown: (details) {
              dragstart = details.localPosition.dy;
            },
            onVerticalDragUpdate: (details) {
              if (details.localPosition.dy - dragstart > 50) {
                cardvisible();
              } else if (details.localPosition.dy - dragstart < -50) {
                dynamic citan = cacheimage[tmp_array_num];
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 500),
                        pageBuilder: (_, __, ___) => DetailPage(
                              citan,
                              body[image.indexOf(citan)],
                              name[image.indexOf(citan)],
                            )));
              }
            },
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 230),
              alignment: flag ? const Alignment(0, 5) : Alignment.bottomCenter,
              child: cardPageView(),
            ),
          ),
          AnimatedOpacity(
            opacity: notify_flag ? 1.0 : 0,
            duration: const Duration(seconds: 1),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  area_name[area_banner],
                  style: TextStyle(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ]),
      ),
      AnimatedOpacity(
        opacity: titleanimation ? 1.0 : 0.0,
        duration: Duration(seconds: 1),
        child: Visibility(
            visible: titlevisible,
            child: Scaffold(
                backgroundColor: Colors.blue[100],
                body: Align(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const <Widget>[
                          Image(
                            image: AssetImage('images/showmap_title.png'),
                            width: 350,
                          ),
                          Image(
                            image: AssetImage("images/icon1.png"),
                            width: 350,
                          )
                        ])))),
      ),
    ]));
  }

  Widget cardPageView() {
    return Container(
        height: MediaQuery.of(context).size.height / 2 - 150,
        child: PageView(
          controller: _pcontroller,
          children: <Widget>[
            for (var item in cacheimage)
              Container(
                margin: const EdgeInsets.only(right: 10, bottom: 20),
                //受け取った数だけcard作成
                child: CustomCard(
                    item, body[image.indexOf(item)], name[image.indexOf(item)]),
              )
          ],
          //選択カード変更時
          onPageChanged: (i) {
            tmp_array_num = i;
            selectedPlace = cacheMapCenter[i]; //選択カードと対応したmarkerの座標取得
            selectedId = cacheMarkerId[i]; //選択カードと対応したmarkerのID取得
            _changePosition(); //選択カード変更時カメラ座標移動
          },
        ));
  }

  Future _area(i) async {
    switch (i) {
      case 0:
        lat = 35.147839390317245; //御器所の緯度経度
        lng = 136.9207221517206;
        break;
      case 1:
        lat = 35.15721645407376; //吹上
        lng = 136.93407559983893;
        break;
      case 2:
        lat = 35.153260927616046; //鶴舞
        lng = 136.91927903636793;
        break;
      case 3:
        lat = 35.14458677494105; //滝川
        lng = 136.95693693136522;
        break;
      case 4:
        lat = 35.14230958673936; //八事
        lng = 136.96618022556837;
        break;
      default:
        lat = 1;
        lng = 1;
    }

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 0,
        target: LatLng(lat, lng),
        tilt: 0,
        zoom: 16.121926040649414)));
  }

  //選択カード変更用
  Future<void> _changePosition() async {
    GoogleMapController controller = await _controller.future;
    if (selectedPlace != LatLng(0, 0)) {
      controller.animateCamera(CameraUpdate.newLatLng(selectedPlace));
      if (await controller.isMarkerInfoWindowShown(
              MarkerId(cacheMarkerId[markerIndex(selectedPlace)].toString())) ==
          false) {
        controller.showMarkerInfoWindow(
            MarkerId(cacheMarkerId[markerIndex(selectedPlace)].toString()));
      }
    }
  }

  //選択解除時
  Future<void> _hideInfoWindow() async {
    GoogleMapController controller = await _controller.future;
    if (selectedPlace != LatLng(0, 0)) {
      if (cacheMapCenter != null) {
        if (await controller.isMarkerInfoWindowShown(MarkerId(
                cacheMarkerId[markerIndex(selectedPlace)].toString())) ==
            true) {
          controller.hideMarkerInfoWindow(
              MarkerId(cacheMarkerId[markerIndex(selectedPlace)].toString()));
        }
      }
    }
  }

  //絞り込み実行時
  Future<void> _hidePin() async {
    GoogleMapController controller = await _controller.future;
    if (selectedPlace != LatLng(0, 0)) {
      if (cacheMapCenter != null) {
        if (await controller
                .isMarkerInfoWindowShown(MarkerId(selectedId.toString())) ==
            true) {
          controller.hideMarkerInfoWindow(MarkerId(selectedId.toString()));
        }
      }
    }
  }
}
