import 'dart:convert';

class Alarm {
  final String drugN;
  final String ownerD;
  final String time;


  Alarm({
    this.drugN,
    this.ownerD,this.time,


  });
  factory Alarm.fromJson(Map<String, dynamic> jsonData) {
    return Alarm(
      drugN: jsonData['drugN'],
      ownerD: jsonData['ownerD'],
      time: jsonData['time'],



    );
  }

  static Map<String, dynamic> toMap(Alarm music) => {
    'drugN': music.drugN,
    'ownerD': music.ownerD,
    'time': music.time,


  };

  static String encodeMusics(List<Alarm> musics) => json.encode(
    musics
        .map<Map<String, dynamic>>((music) => Alarm.toMap(music))
        .toList(),
  );
  static List<Alarm> decodeMusics(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Alarm>((item) => Alarm.fromJson(item))
          .toList();
}