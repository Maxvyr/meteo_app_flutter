import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:meteo_koji/controller/color.dart';
import 'package:meteo_koji/view/widget/my_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      body: Center(
        child: MyText(
          data: cityChoice ?? "Ville Actuelle",
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
      });
    }
  }
}
