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
  final response = await http
      .get('https://covid19-japan-web-api.now.sh/api/v1/prefectures');

  if (response.statusCode != 200) {
    throw Exception('Failed prefecture info fetching.\nstatus code:${response.statusCode}');
  }
  
  return PrefectureResponse.fromJson(json.decode(response.body));
}

/*
 * APIレスポンスクラス. JSONデータの形式に合わせて定義します
 * データ数分のPrefecture配列を保持します
 */
class PrefectureResponse
{
  List<Prefecture> _prefectures;

  PrefectureResponse( List<dynamic> source )
  {
    _prefectures = List();
    for ( Map<String, dynamic> item in source )
    {
      Prefecture prefecture = Prefecture.fromJson(item);
      _prefectures.add(prefecture);
    }
  }

  // Named constructor
  factory PrefectureResponse.fromJson(List<dynamic> json)
  {
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
        body: Center(
          child: FutureBuilder<PrefectureResponse>(
            future: futurePrefecture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                int index = Random.secure().nextInt(snapshot.data._prefectures.length - 1);
                String name = snapshot.data._prefectures[index].name;
                return Text(name);
              }
              else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}