import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller/constants.dart';
import 'view/home_page.dart';

import 'controller/color.dart';

void main() {
  //Force Portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(MyApp()),
  );
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   Location location = new Location();  LocationData position;
//   try {
//     position = (await location.getLocation()) ;
//     print(position);  }
//     on PlatformException catch (e) {
//     print("Erreur: $e");
//   }
//   if (position != null) {
//     final latitude = position.latitude;
//     final longitude = position.longitude;
//     final Coordinates coordinates = new Coordinates(latitude, longitude);
//     final ville = await Geocoder.local.findAddressesFromCoordinates(coordinates);
//     if (ville != null) {
//       print(ville.first.locality);
//       runApp(new MyApp(ville.first.locality));
//     }
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: titleApp,
      theme: ThemeData(
        primarySwatch: indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(title: titleApp),
    );
  }
}
