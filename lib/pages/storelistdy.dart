import 'dart:convert';

class Music {
  final String session;
  final int drugid;
  final String drugname;
  final int quantity;
  final String drugprice;
  final String gift;
  final String dis;
  final String wareN;

  final int offeId;
  final int wareId;

  Music({
    this.session,
    this.drugid,
    this.gift,this.dis,
    this.drugname,
    this.quantity,
    this.drugprice,
    this.wareId,
this.wareN,
    this.offeId,

  });
factory Music.fromJson(Map<String, dynamic> jsonData) {
return Music(
  session: jsonData['session'],

  drugid: jsonData['drugid'],
  drugname: jsonData['drugname'],
  quantity: jsonData['quantity'],
  drugprice: jsonData['drugprice'],
  wareId: jsonData['wareId'],
  offeId: jsonData['offeId'],
  gift: jsonData['gift'],
  dis: jsonData['dis'],
  wareN: jsonData['wareN'],


);
}

static Map<String, dynamic> toMap(Music music) => {
  'session': music.session,

  'drugid': music.drugid,
  'offeId': music.offeId,
  'wareId': music.wareId,
  'drugprice': music.drugprice,
  'quantity': music.quantity,
  'drugname': music.drugname,
  'dis': music.dis,
  'gift': music.gift,
  'wareN': music.wareN,

};

static String encodeMusics(List<Music> musics) => json.encode(
musics
    .map<Map<String, dynamic>>((music) => Music.toMap(music))
.toList(),
);
  static List<Music> decodeMusics(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Music>((item) => Music.fromJson(item))
          .toList();
}