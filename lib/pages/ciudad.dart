import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
// import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:label_storemax/labelconfig.dart';
import 'global.dart' as global;
import 'package:wp_json_api/wp_json_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../labelconfig.dart';

Image appLogo = new Image(
    image: new ExactAssetImage(
        "https://presstofoods.com/wp-content/uploads/2020/05/logomini2.png"),
    height: 28.0,
//width: 20.0,
    alignment: FractionalOffset.center);

class Ciudad extends StatefulWidget {
  Ciudad({Key key}) : super(key: key);

  @override
  _CiudadState createState() => _CiudadState();
}

class _CiudadState extends State<Ciudad> {
  void initState() {
    super.initState();
    _checkLastCity();
  }

  _checkLastCity() {
    _getLastCity().then((value) {
      if (use_wp_login == true) {
        WPJsonAPI.instance.initWith(
            baseUrl: app_base_url,
            shouldDebug: app_debug,
            wpJsonPath: app_wp_api_path);
      }
      switch (value) {
        case 'SAP':
          global.base_url = "https://presstofoods.com/";
          app_key =
              "app_961e365f250f092f7f5769d6c3b9fb027b2b1bac9fb9d65549f823541ab6";
          _navigate('SAP_loggedIn');

          break;

        case 'TGU':
          global.base_url = "https://presstofoods.com/tgu/";
          app_key =
              "app_ac307452d5ab50f5129996fb23563db6b14055521f5e0a2c8bb6b0b8669a";

          _navigate('TGU_loggedIn');

          break;

        default:
          break;
      }
    });
  }

  static Future<String> _getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('lastCity') ?? 'noCity';
    print('city $value');
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(
        //title: appLogo, //Text('Selecciona la Ciudad'),
        //),
        body: Center(
      child: Container(
        padding: new EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/presstofoodsgrande.png'),
            Divider(
              height: 170,
            ),
            Text(
              'Seleccione la ciudad',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'RobotoMono',
              ),
            ),
            Divider(
              height: 30,
            ),
            RaisedButton(
              child: Text(
                'SAN PEDRO SULA',
                style: TextStyle(fontSize: 20),
              ),
              //Icon(Icons.location_on), //Icons.location_on,
              color: Colors.grey[800],
              textColor: Colors.white,
              onPressed: () {
                global.base_url = 'https://presstofoods.com/';
                if (use_wp_login == true) {
                  WPJsonAPI.instance.initWith(
                      baseUrl: app_base_url,
                      shouldDebug: app_debug,
                      wpJsonPath: app_wp_api_path);
                }
                app_key =
                    "app_961e365f250f092f7f5769d6c3b9fb027b2b1bac9fb9d65549f823541ab6";
                _navigate('SAP_loggedIn');
              },
              shape: StadiumBorder(),
            ),
            Divider(
              height: 40,
            ),
            RaisedButton(
              child: Text(
                'TEGUCIGALPA',
                style: TextStyle(fontSize: 20),
              ),
              color: Colors.grey[800],
              textColor: Colors.white,
              onPressed: () {
                global.base_url = 'https://presstofoods.com/tgu/';
                if (use_wp_login == true) {
                  WPJsonAPI.instance.initWith(
                      baseUrl: app_base_url,
                      shouldDebug: app_debug,
                      wpJsonPath: app_wp_api_path);
                }
                app_key =
                    "app_ac307452d5ab50f5129996fb23563db6b14055521f5e0a2c8bb6b0b8669a";

                _navigate('TGU_loggedIn');
              },
              shape: StadiumBorder(),
            ),
          ],
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    ));
  }

  static Future<bool> _getLogInSession(key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(key) ?? false;
    print(value);
    if (value)
      return Future.value(true);
    else
      return Future.value(false);
  }

  _navigate(String key) {
    print(key);
    _getLogInSession(key).then((value) {
      print(value);
      (value)
          ? navigatorPush(context, routeName: '/home')
          : navigatorPush(context, routeName: '/account-landing');
    });
  }
}
