import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../controller/color.dart';
import '../models/weather_city.dart';
import '../view/widget/container_background.dart';
import '../view/widget/loading_indicator.dart';
import '../view/widget/my_appbar.dart';
import '../view/widget/my_text.dart';
import '../view/widget/my_divider.dart';
import '../controller/constants.dart' as constants;
import '../controller/utils/time_format.dart';
import '../view/widget/my_input_decoration.dart';

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
  String cityLiving = "Ville Actuelle";

  //var location user
  Location location;
  LocationData locationData;
  Stream<LocationData> stream;

  //var coordinates
  Coordinates coordsCityChoice;

  //var WeatherCity
  WeatherCity weatherCity;

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
      appBar: MyAppBar(
        title: widget.title,
      ),
      drawer: drawerMeteo(),
      body: weatherCity == null
          ? LoadingIndicator()
          : ContainerCity(weatherCity, cityChoice),
    );
  }

  Drawer drawerMeteo() {
    return Drawer(
      child: Container(
        color: indigo,
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
                        data: constants.myCities,
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
                          data: constants.addACity,
                          fontSize: 20.0,
                          fontStyle: FontStyle.normal,
                          color: black,
                          colorShadow: transparent,
                        ),
                        onPressed: addCity,
                      ),
                      Row(
                        children: [
                          Spacer(),
                          MyText(
                            data: timeNowFormat(),
                            color: white,
                            fontSize: 10.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                break;
              case 1:
                return Column(
                  children: [
                    MyDivider(),
                    ListTile(
                      title: MyText(
                        data: cityLiving,
                        color: white,
                      ),
                      onTap: () {
                        setState(() {
                          cityChoice = null;
                          coordsCityChoice = null;
                          sendCoordsToAPI();
                          Navigator.pop(context);
                        });
                      },
                    ),
                    MyDivider(),
                  ],
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
      useSafeArea: false,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(20.0),
          title: MyText(
            data: constants.addACity,
            fontSize: 25.0,
            fontWeight: FontWeight.w900,
            color: indigo,
            colorShadow: transparent,
          ),
          children: [
            TextField(
              decoration: MyInputDecoration(),
              onSubmitted: (String str) {
                addStringListSharedPref(str);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
      setState(() {
        cityLiving = cityFind.first.locality;
        sendCoordsToAPI();
      });
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
      // print(response.body);
      setState(
        () {
          weatherCity = WeatherCity.fromJson(json);
          print("la ville geoloc fait => ${weatherCity.name}");
        },
      );
    }
  }
}
