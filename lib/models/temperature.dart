class WeatherCity {
  //Variable
  Map coord;
  var coordLon;
  var coordLat;
  List weather;
  var idWeather;
  String main;
  String description;
  String icon;
  var bases;
  Map mainTemp;
  var temp;
  var temperatureFeeling;
  var min;
  var max;
  var pressure;
  var humidity;
  var visibility;
  Map wind;
  var speedWind;
  var degWind;
  Map clouds;
  var allClouds;
  var dt;
  Map sys;
  var typeSys;
  var idSys;
  var countrySys;
  var sunriseSys;
  var sunsetSys;
  var timezone;
  var id;
  var name;
  var cod;

  WeatherCity.fromJson(Map<String, dynamic> json) {
    //coord
    this.coord = json["coord"];
    this.coordLon = coord["lon"];
    this.coordLat = coord["lat"];
    this.weather = json["weather"];
    //weather
    Map weatherMap = weather.first;
    this.idWeather = weatherMap["id"];
    this.main = weatherMap["main"];
    this.description = weatherMap["description"];
    this.icon = weatherMap["icon"];
    //bases
    this.bases = json["bases"];
    //main
    this.mainTemp = json["main"];
    this.temp = mainTemp["temp"];
    this.temperatureFeeling = mainTemp["feels_like"];
    this.min = mainTemp["temp_min"];
    this.max = mainTemp["temp_max"];
    this.pressure = mainTemp["pressure"];
    this.humidity = mainTemp["humidity"];
    //visibility
    this.visibility = json["visibility"];
    //wind
    this.wind = json["wind"];
    this.speedWind = wind["speed"];
    this.degWind = wind["deg"];
    //clouds
    this.clouds = json["clouds"];
    this.allClouds = clouds["all"];
    //dt
    this.dt = json["dt"];
    //sys
    this.sys = json["sys"];
    this.typeSys = sys["type"];
    this.idSys = sys["id"];
    this.countrySys = sys["country"];
    this.sunriseSys = sys["sunrise"];
    this.sunsetSys = sys["sunset"];
    //timezone
    this.timezone = json["timezone"];
    //id
    this.id = json["id"];
    //name
    this.name = json["name"];
    //cod
    this.cod = json["cod"];
  }
}
