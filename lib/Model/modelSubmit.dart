import 'dart:convert';

class subList {
  final int drugid;
  final int quantity;
  final int offeId;

  subList({
    this.drugid,
    this.quantity,

    this.offeId,

  });
  factory subList.fromJson(Map<String, dynamic> jsonData) {
    return subList(
      drugid: jsonData['drugid'],
      quantity: jsonData['quantity'],
      offeId: jsonData['offeId'],



    );
  }

  static Map<String, dynamic> toMap(subList music) => {
    'drugid': music.drugid,
    'offeId': music.offeId,
    'quantity': music.quantity,


  };

  static String encodeMusics(List<subList> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => subList.toMap(music))
        .toList(),
  );
  static List<subList> decodeMusics(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<subList>((item) => subList.fromJson(item))
          .toList();
}