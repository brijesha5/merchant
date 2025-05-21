import 'package:flutter/material.dart';

import 'home/home_page.dart';



class RouteGenerator {
  static const String homeRoute = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case homeRoute:
        return MaterialPageRoute(
            builder: (_) => const HomePage(title: "Mosambee Flutter Plugin Example"));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }

  static RouteSettings _createRouteSettings(String route, {Object? data}) {
    return RouteSettings(name: route, arguments: data);
  }

  static void push(BuildContext context, String route, {Object? data}) {
    Navigator.of(context).push(
      generateRoute(_createRouteSettings(route, data: data)),
    );
  }

  static void pushRemoveStack(BuildContext context, String route,
      {Object? data}) {
    Navigator.of(context).pushNamedAndRemoveUntil(
        _createRouteSettings(route).name!, (Route<dynamic> route) => false,
        arguments: data);
  }

  static void replace(BuildContext context, String route) {
    Navigator.of(context).pushReplacement(
      generateRoute(_createRouteSettings(route)),
    );
  }

  static void makeFirst(BuildContext context, String route) {
    Navigator.of(context).popUntil((predicate) => predicate.isFirst);
    Navigator.of(context).pushReplacement(
      generateRoute(_createRouteSettings(route)),
    );
  }

  static void makeFirstWithData(
      BuildContext context, String route, dynamic data) {
    Navigator.of(context).popUntil((predicate) => predicate.isFirst);
    Navigator.of(context).pushReplacement(
      generateRoute(_createRouteSettings(route, data: data)),
    );
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void popDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop('dialog');
  }
}
