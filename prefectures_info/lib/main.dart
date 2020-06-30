import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'Constants.dart';
import 'PrefectureList.dart';

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

void main() {
  runApp(MyHomePage());
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
 * 取得した都道府県をリスト表示、選択した都道府県のデータをモーダル表示します。
 */
class _APIRequestState extends State<MyHomePage> {
  Future<PrefectureResponse> futurePrefecture;
  List<Prefecture> data;

  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    futurePrefecture = fetch();
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
        //リストトップに戻るボタン
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.keyboard_arrow_up),
          onPressed: () {
            controller.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut);
          },
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              FutureBuilder<PrefectureResponse>(
                future: futurePrefecture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //取得したデータをほかのウィジェットでも使えるように保存。
                    data = snapshot.data._prefectures;
                    //リスト表示
                    return listData(prefectures: data);

                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}