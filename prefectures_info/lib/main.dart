import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

/*
 * COVID-19に関する、都道府県毎のデータをJSONで取得します
 */
Future<PrefectureResponse> fetch() async {
  final response =
      await http.get('https://covid19-japan-web-api.now.sh/api/v1/prefectures');

  if (response.statusCode != 200) {
    throw Exception(
        'Failed prefecture info fetching.\nstatus code:${response.statusCode}');
  }

  return PrefectureResponse.fromJson(json.decode(response.body));
}

/*
 * APIレスポンスクラス. JSONデータの形式に合わせて定義します
 * データ数分のPrefecture配列を保持します
 */
class PrefectureResponse {
  List<Prefecture> _prefectures;

  PrefectureResponse(List<dynamic> source) {
    _prefectures = List();
    for (Map<String, dynamic> item in source) {
      Prefecture prefecture = Prefecture.fromJson(item);
      _prefectures.add(prefecture);
    }
  }

  // Named constructor
  factory PrefectureResponse.fromJson(List<dynamic> json) {
    return PrefectureResponse(json);
  }
}

/*
 * APIレスポンスクラス. JSONデータの形式に合わせて定義します
 * 都道府県単位のデータです
 */
class Prefecture {
  final int id;
  final String name;
  final String englishName;
  final double lattitude; // 緯度
  final double longitude; // 経度
  final int caseNum; // 症例数
  final int deathNum; // 死亡数

  Prefecture(
      {this.id,
      this.name,
      this.englishName,
      this.lattitude,
      this.longitude,
      this.caseNum,
      this.deathNum});

  factory Prefecture.fromJson(Map<String, dynamic> json) {
    return Prefecture(
        id: json['id'],
        name: json['name_ja'],
        englishName: json['name_en'],
        lattitude: json['lat'],
        longitude: json['lng'],
        caseNum: json['cases'],
        deathNum: json['deaths']);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _APIRequestState createState() => _APIRequestState();
}

/*
 * State開始時にAPI実行してデータを取得します.
 * API実行が終了したら  FutureBuilder<PrefectureResponse> の (context, snapshot) がコールバックされます.
 * とりあえず取得したデータ配列からランダムに選出し、県名を表示しています.
 * Hot Reload する度に build() が実行されるので県名表示が切り替わります
 */
class _APIRequestState extends State<MyHomePage> {
  Future<PrefectureResponse> futurePrefecture;
  List<Prefecture> data;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    futurePrefecture = fetch();
  }

  void _handlePressed() {
    setState(() {
      _active = !_active;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'prefecture information',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('COVID-19 Prefecture Info'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              FutureBuilder<PrefectureResponse>(
                future: futurePrefecture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // int index = Random.secure().nextInt(snapshot.data._prefectures.length - 1);
                    // String name = snapshot.data._prefectures[index].name;

                    //取得したデータをほかのウィジェットでも使えるように保存。
                    data = snapshot.data._prefectures;

                    return _viewData(data);
                    //return Text(name);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
              //_refreshButton(), //一覧取得ができるまでは更新ボタンを置いておく。
            ],
          ),
        ),
      ),
    );
  }

  Widget _viewData(List<Prefecture> data) {
    return new Expanded(
      child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: Container(
                decoration: new BoxDecoration(
                  border: new Border(
                      bottom: BorderSide(width: 1.0, color: Colors.grey)),
                ),
                child: ListTile(
                  title: Text(
                    data[index].name,
                    style: TextStyle(color: Colors.black, fontSize: 18.0),
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) {
                      return _modalDisplay(data: data[index]);
                    },
                    fullscreenDialog: true));
              },
              onLongPress: () {},
            );
          }),
    );
  }

  /*
  *一覧取得ができるまでは更新ボタンを置いておく。
  *※リストですべて表示するようになったので使わない。
  */
  Widget _refreshButton() {
    return Container(
      margin: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RaisedButton(
            onPressed: _handlePressed,
            color: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: const Text(
              '更新',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }
}

//選択された県の症例数と死亡数のモーダル表示
class _modalDisplay extends StatelessWidget {
  _modalDisplay({Key key, this.data}) : super(key: key);

  Prefecture data;

  final _textStyle = const TextStyle(fontSize: 25.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
      ),
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '症例数: ' + data.caseNum.toString(),
                  style: _textStyle,
                  textAlign: TextAlign.left),
                Text(
                  '死亡数: ' + data.deathNum.toString(),
                  style: _textStyle,
                  textAlign: TextAlign.left)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
