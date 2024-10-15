class Users {
  String? weather;
  String? clouds;
  String? time;
  List<SportsYouCanDo>? sportsYouCanDo;
  List<AnyMap>? anyMap;
  Users({
    this.weather,
    this.clouds,
    this.time,
    this.sportsYouCanDo,
    this.anyMap,
  });

  Users.fromJson(Map<String, dynamic> json) {
    weather = json["weather"];
    clouds = json["clouds"];
    time = json["time"];
    sportsYouCanDo = json["sportsYouCanDo"] != null ? List<SportsYouCanDo>.from(json["sportsYouCanDo"].map((item) => SportsYouCanDo.fromJson(item))) : null;
    anyMap = json["anyMap"] != null ? List<AnyMap>.from(json["anyMap"].map((item) => AnyMap.fromJson(item))) : null;
  }
  Map<String, dynamic> toJson() => {
    "weather": weather,
    "clouds": clouds,
    "time": time,
    "sportsYouCanDo": sportsYouCanDo?.map((item) => item.toJson()).toList(),
    "anyMap": anyMap?.map((item) => item.toJson()).toList(),
  };
}

class SportsYouCanDo {
  String? sport1;
  String? sport2;
  String? sport3;
  SportsYouCanDo({
    this.sport1,
    this.sport2,
    this.sport3,
  });

  SportsYouCanDo.fromJson(Map<String, dynamic> json) {
    sport1 = json["sport1"];
    sport2 = json["sport2"];
    sport3 = json["sport3"];
  }
  Map<String, dynamic> toJson() => {
    "sport1": sport1,
    "sport2": sport2,
    "sport3": sport3,
  };
}

class AnyMap {
  String? key1;
  String? key2;
  AnyMap({
    this.key1,
    this.key2,
  });

  AnyMap.fromJson(Map<String, dynamic> json) {
    key1 = json["key1"];
    key2 = json["key2"];
  }
  Map<String, dynamic> toJson() => {
    "key1": key1,
    "key2": key2,
  };
}
