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