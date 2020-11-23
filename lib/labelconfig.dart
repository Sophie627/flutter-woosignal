//
//  LabelCore
//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:ui';
import 'package:label_storemax/pages/global.dart' as global;

/*
 Developer Notes

 SUPPORT EMAIL - support@woosignal.com
 VERSION - 2.1.1
 https://woosignal.com
 */

/*<! ------ CONFIG ------!>*/

const app_name = "PresstoFoods";

//const app_key = "app_961e365f250f092f7f5769d6c3b9fb027b2b1bac9fb9d65549f823541ab6";
String app_key =
    "app_961e365f250f092f7f5769d6c3b9fb027b2b1bac9fb9d65549f823541ab6";

// Your App key from WooSignal
// link: https://woosignal.com/dashboard/apps

const app_logo_url =
    "https://presstofoods.com/wp-content/uploads/2020/05/logomini2.png";

const app_terms_url = "https://yourdomain.com/terms";
const app_privacy_url = "https://yourdomain.com/privacy";

/*<! ------ APP SETTINGS ------!>*/

const app_currency_symbol = "\L";
const app_currency_iso = "hnl";
const Locale app_locale = Locale('en');
// const Locale app_locale = Locale('es');
const List<Locale> app_locales_supported = [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('hi'),
  Locale('it'),
  Locale('pt'),
];
// If you want to localize the app, add the locale above
// then create a new lang json file using keys from en.json
// e.g. lang/es.json

/*<! ------ PAYMENT GATEWAYS ------!>*/

// Available: "Stripe", "CashOnDelivery", "RazorPay"
// Add the method to the array below e.g. ["Stripe", "CashOnDelivery"]

const app_payment_methods = ["Stripe"];

/*<! ------ STRIPE (OPTIONAL) ------!>*/

// Your StripeAccount key from WooSignal
// link: https://woosignal.com/dashboard

const app_stripe_account = "Your Stripe Key from WooSignal";

const app_stripe_live_mode = false;
// For Live Payments follow the below steps
// #1 SET the above to true for live payments
// #2 Next visit https://woosignal.com/dashboard
// #3 Then change "Environment for Stripe" to Live mode

/*<! ------ WP LOGIN (OPTIONAL) ------!>*/

// Allows customers to login/register, view account, purchase items as a user.
// #1 Install the "WP JSON API" plugin on WordPress via https://woosignal.com/plugins/wordpress/wpapp-json-api
// #2 Next activate the plugin on your WordPress and enable "use_wp_login = true"
// link: https://woosignal.com/dashboard/plugins

//const use_wp_login = false;
//SEGUN LA CIUDAD GUARDAR LA URL EN SQLLITE Y AL CARGAR SI HAY VARIABLE LLENA, LLENAR ESTA,
//DE LO CONTRARIO USAR /DEV O /DEV/TGU SEGUN LA CIUDAD Y ESO QUEDA ALMACENADO
//SI YA ESTÁ CON USUARIO Y CIUDAD, BUSCAR COMO LOGUEARLO SIN Q LO HAGA MANUALMENTE
//QUE EJECUTE LA FUNCIÓN DEL LOGIN Q SE EJECUTA AL TOCAR BOTÓN EN CUANTO ENTRA Y LO LANCE A CATEGORIAS
//LAS TARJETAS NO DEPENDEN DE CIUDAD O USUARIO, Q LAS GUARDE EN LA APP Y LAS MUESTRE PARA SELECCIONAR
//EN EL METODO DE PAGO Q SERA CON REST API HTTP RESPONSE, Q SE PUEDE ESTRUCTURAR CON LO DE RECIBIR JSON Q
//CREA LAS VARIABLES LISTAS. Y EJECUTAR LA ORDEN, COPIANDO LO Q HACE CUANDO RECIBE EL SUCESS DE STRIPE
//FALTARÍA VER SI MANDA PUSH, O ES MANUAL A CADA USUARIO, Y LISTO.
const use_wp_login = true;

String app_base_url = (global.base_url == 'https://presstofoods.com/tgu')
    ? "https://presstofoods.com/tgu"
    : "https://presstofoods.com"; // change to your url
const app_forgot_password_url =
    "https://presstofoods.com/wp-login.php?action=lostpassword"; // change to your forgot password url
const app_wp_api_path = "/wp-json"; // By default "/wp-json" should work

/*<! ------ Razor Pay (OPTIONAL) ------!>*/
// https://razorpay.com/

const app_razor_id = "Your Razor ID from RazorPay";

/*<! ------ DEBUGGER ENABLED ------!>*/

const app_debug = true;
