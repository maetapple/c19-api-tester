import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Constants.dart';
import 'modal.dart';

class listData extends StatefulWidget {
  listData({Key key, this.prefectures})
      : super(key: key);

  List<Prefecture> prefectures;

  @override
  _viewData createState() => _viewData();
}

class _viewData extends State<listData> {
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: controller,
        itemCount: widget.prefectures.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Container(
              decoration: new BoxDecoration(
                border: new Border(
                    bottom: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              child: ListTile(
                title: Text(
                  widget.prefectures[index].name,
                  style: TextStyle(color: Colors.black, fontSize: 18.0),
                ),
              ),
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return modalDisplay(data: widget.prefectures[index]);
                },
                fullscreenDialog: true)),
            onLongPress: () {},
          );
        }),
    );
  }
}
