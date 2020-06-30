import 'package:flutter/material.dart';
import 'Constants.dart';

class modalDisplay extends StatefulWidget {
  modalDisplay({Key key, this.data}) : super(key: key);

  Prefecture data;

  @override
  _modalDisplayState createState() => _modalDisplayState();
}

class _modalDisplayState extends State<modalDisplay> {
  final _textStyle = const TextStyle(fontSize: 25.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data.name),
      ),
      body: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 60.0),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 40.0),
                Container(
                  decoration: new BoxDecoration(
                    border: new Border(
                        bottom: BorderSide(width: 3.0, color: Colors.blue)),
                  ),
                  width: 285.0,
                  child: Text(widget.data.name, style: _textStyle),
                ),
                SizedBox(height: 10.0),
                Container(
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 25.0,),
                      //症例数と死亡数だけだと寂しいので緯度と経度も出しておいてみる。
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              '緯度　: ' +
                                  ((widget.data.lattitude * 100).ceilToDouble() / 100)
                                      .toString(),
                              style: _textStyle),
                          SizedBox(height: 10.0),
                          Text(
                              '経度　: ' +
                                  ((widget.data.longitude * 100).ceilToDouble() / 100)
                                      .toString(),
                              style: _textStyle),
                          SizedBox(height: 10.0),
                          Text('症例数: ' + widget.data.caseNum.toString(),
                              style: _textStyle),
                          SizedBox(height: 10.0),
                          Text('死亡数: ' + widget.data.deathNum.toString(),
                              style: _textStyle),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}