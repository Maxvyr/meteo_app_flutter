import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:meteo_koji/controller/color.dart';
import 'package:meteo_koji/models/weather_city.dart';
import 'package:meteo_koji/view/widget/my_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //variables
  String key = "LISTE_VILLES";
  List<String> cities = [];
  String cityChoice;

  //var location user
  Location location;
  LocationData locationData;
  Stream<LocationData> stream;

  //var coordinates
  Coordinates coordsCityChoice;

  //var WeatherCity
  WeatherCity weatherCity;

  //imageBackground
  NetworkImage imgNight = NetworkImage("https://imgur.com/8MmKx2M.png");
  NetworkImage imgBadWeather = NetworkImage("https://imgur.com/tyJiWK4.png");
  NetworkImage imgGoodNight = NetworkImage("https://imgur.com/FSrDrJ7.png");

  @override
  void initState() {
    super.initState();
    //recover list save
    getListSharedPref();
    //instancie location + get location user
    location = Location.instance;
    listenUserChangeWithStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MyText(data: widget.title),
      ),
      drawer: drawerMeteo(),
      body: weatherCity == null
          ? Center(
              child: MyText(
                data: cityChoice ?? "Ville Actuelle",
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: getBackground(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  Drawer drawerMeteo() {
    return Drawer(
      child: Container(
        color: blue,
        child: ListView.builder(
          itemCount: cities.length + 2,
          itemBuilder: (context, position) {
            switch (position) {
              case 0:
                return DrawerHeader(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MyText(
                      data: "Mes Villes",
                      color: white,
                      fontStyle: FontStyle.normal,
                      fontSize: 25.0,
                      fontWeight: FontWeight.w900,
                    ),
                    RaisedButton(
                      elevation: 10.0,
                      color: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: MyText(
                        data: "Ajouter une ville",
                        fontStyle: FontStyle.normal,
                        color: black,
                      ),
                      onPressed: addCity,
                    ),
                  ],
                ));
                break;
              case 1:
                return ListTile(
                  title: MyText(
                    data: "Ville actuelle",
                    color: white,
                  ),
                  onTap: () {
                    setState(() {
                      cityChoice = null;
                      coordsCityChoice = null;
                      Navigator.pop(context);
                    });
                  },
                );
                break;
              default:
                String ville = cities[position - 2];
                return ListTile(
                  title: MyText(
                    data: ville,
                    color: white,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_forever,
                      color: white,
                    ),
                    onPressed: () => deleteStringListSharedPref(ville),
                  ),
                  onTap: () {
                    //change ville and close drawer
                    setState(() {
                      cityChoice = ville;
                      getLocationWithCity(cityChoice);
                      Navigator.pop(context);
                    });
                  },
                );
            }
          },
        ),
      ),
    );
  }

  Future addCity() async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: MyText(
            data: "Ajoutez une ville",
            fontSize: 25.0,
            color: blue,
          ),
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Ville :"),
              onSubmitted: (String str) {
                addStringListSharedPref(str);
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  NetworkImage getBackground() {
    /// check this link https://openweathermap.org/weather-conditions
    /// to know the icon name for each weather
    /// if contains n so night
    print("icon weater => ${weatherCity.icon}");
    if (weatherCity.icon.contains("n")) {
      return imgNight;
    } else {
      if (weatherCity.icon.contains("01") ||
          weatherCity.icon.contains("02") ||
          weatherCity.icon.contains("03") ||
          weatherCity.icon.contains("04")) {
        return imgGoodNight;
      } else {
        return imgBadWeather;
      }
    }
  }

  /// SHARED PREF --------------------------------------------------

  void getListSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> listeStocker = await sharedPreferences.getStringList(key);
    if (listeStocker != null) {
      setState(() {
        cities = listeStocker;
      });
    }
  }

  void addStringListSharedPref(String city) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.add(city);
    await sharedPreferences.setStringList(key, cities);
    getListSharedPref();
  }

  void deleteStringListSharedPref(String city) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    cities.remove(city);
    await sharedPreferences.setStringList(key, cities);
    getListSharedPref();
  }

  /// LOCATION -----------------------------------------------------

  //recover user location at the start of the application with button update
  // for example
  void getFirstLocation() async {
    try {
      locationData = await location.getLocation();
      print("Nouvelle location : Longitude : ${locationData.longitude} / "
          " Latitude : ${locationData.latitude}");
      getCityWithLocation();
    } catch (e) {
      print("erreur Location revover => $e");
    }
  }

  //Each user deplacement with a stream I think it's better the location
  // update all the time
  void listenUserChangeWithStream() {
    stream = location.onLocationChanged;
    stream.listen((positionUser) {
      if (locationData == null ||
          positionUser.longitude != locationData.longitude &&
              positionUser.latitude != locationData.latitude) {
        print(
            "New longitude => ${positionUser.longitude} and New Latitude ${positionUser.latitude}");
        setState(() {
          locationData = positionUser;
          getCityWithLocation();
        });
      }
    });
  }

  /// GEOCODER -----------------------------------------------------
  getCityWithLocation() async {
    if (locationData != null) {
      Coordinates coordinates =
          Coordinates(locationData.latitude, locationData.longitude);
      final cityFind =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final String cityName = cityFind.first.locality;
      // final String cityCode = cityFind.first.postalCode;
      print("City => $cityName");
      sendCoordsToAPI();
    }
  }

  getLocationWithCity(String city) async {
    if (city != null) {
      final adresses = await Geocoder.local.findAddressesFromQuery(city);
      var coords = adresses.first.coordinates;
      final double longitudeCity = coords.longitude;
      final double latitudeCity = coords.latitude;
      setState(() {
        coordsCityChoice = coords;
        print("city => $city et coordonnées $coords");
        sendCoordsToAPI();
      });
    }
  }

  /// CALL API OPEN WEATHER MAP ----------------------------------

  void sendCoordsToAPI() {
    //init var
    double latitude, longitude;
    if (coordsCityChoice != null) {
      // lors d'un click sur une ville specifique
      latitude = coordsCityChoice.latitude;
      longitude = coordsCityChoice.longitude;
    } else if (locationData != null) {
      // lors que l'on est sur la ville de location du telephone
      latitude = locationData.latitude;
      longitude = locationData.longitude;
    }
    formatUrlApi(latitude, longitude);
  }

  void formatUrlApi(double latitude, double longitude) {
    //recover lang Smartphone
    String lang = Localizations.localeOf(context).languageCode;
    final String key = "a6a18c57fb2e85d26a89f08d32caf0d8";
    //organisation diff string for call
    String urlApiKey = "&appid=$key";
    String urlApiBase = "https://api.openweathermap.org/data/2.5/weather?";
    String urlApiCoords = "lat=$latitude&lon=$longitude";
    String urlApiMetrics = "&units=metric";
    String urlApiLang = "&lang=$lang";
    String urlApiTotal =
        urlApiBase + urlApiCoords + urlApiMetrics + urlApiLang + urlApiKey;
    callApi(urlApiTotal);
  }

  void callApi(String urlApiTotal) async {
    final response = await http.get(urlApiTotal);
    if (response.statusCode == 200) {
      /// converti le body response in json and pass them
      /// in the Obect WeatherCity
      var json = jsonDecode(response.body);
      setState(
        () {
          weatherCity = WeatherCity.fromJson(json);
          print("la ville geoloc fait => ${weatherCity.name}");
        },
      );
    }
  }
}
