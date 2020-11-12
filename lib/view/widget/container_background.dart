import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../controller/color.dart';
import '../../controller/icon_weather_icons.dart';
import '../../models/weather_city.dart';
import '../../view/widget/my_text.dart';

class ContainerCity extends StatelessWidget {
  //imageBackground
  NetworkImage imgNight = NetworkImage("https://imgur.com/8MmKx2M.png");
  NetworkImage imgBadWeather = NetworkImage("https://imgur.com/tyJiWK4.png");
  NetworkImage imgGoodNight = NetworkImage("https://imgur.com/FSrDrJ7.png");

  //var
  WeatherCity weatherCity;
  String cityChoice;

  ContainerCity(WeatherCity weatherCity, String cityChoice) {
    this.weatherCity = weatherCity;
    this.cityChoice = cityChoice;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: getBackground(),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MyText(
            data: cityChoice ?? "",
            fontSize: 40.0,
            fontWeight: FontWeight.w900,
            color: white,
          ),
          MyText(
            data: weatherCity.description,
            fontSize: 30.0,
            color: white,
          ),
          Card(
            color: transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(
                  "http://openweathermap"
                  ".org/img/wn/${weatherCity.icon}@2x"
                  ".png",
                ),
                MyText(
                  data: "${weatherCity.temp.toStringAsFixed(1)} C°",
                  color: white,
                  fontSize: 30.0,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              extraWeather("${weatherCity.max.toStringAsFixed(1)} °C",
                  IconWeather.temperature_high),
              extraWeather("${weatherCity.min.toStringAsFixed(1)} °C",
                  IconWeather.temperature_low),
              extraWeather("${weatherCity.humidity}%", IconWeather.droplet)
            ],
          )
        ],
      ),
    );
  }

  NetworkImage getBackground() {
    /// check this link https://openweathermap.org/weather-conditions
    /// to know the icon name for each weather
    /// if contains n so night
    print("icon weater => ${this.weatherCity.icon}");
    if (this.weatherCity.icon.contains("n")) {
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

  Column extraWeather(String data, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          icon,
          color: white,
        ),
        MyText(
          data: data,
          color: white,
        ),
      ],
    );
  }
}
