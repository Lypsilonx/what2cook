import 'dart:convert';

import 'package:flutter/services.dart';

class Ingredient {
  String symbol, name;

  Ingredient(this.symbol, this.name);

  Ingredient.fromJson(Map<String, dynamic> json)
      : symbol = json['symbol'],
        name = json['name'];
}

List<Ingredient> allIngredients = [];

class Recepie {
  String symbol, name;
  List<Ingredient> ingredients;

  Recepie(this.symbol, this.name, this.ingredients);

  int cookable(List<Ingredient> available) {
    int s = 0;

    for (Ingredient a in ingredients) {
      if (!available.contains(a)) {
        s++;
      }
    }

    return s;
  }

  double cookableP(List<Ingredient> available) {
    int s = 0;

    for (Ingredient a in ingredients) {
      if (!available.map((e) => e.name).contains(a.name)) {
        s++;
      }
    }

    return (ingredients.length - s) / ingredients.length;
  }

  Recepie.fromJson(Map<String, dynamic> json)
      : symbol = json['symbol'],
        name = json['name'],
        ingredients = json['ingredients']
            .map<Ingredient>((e) => Ingredient('', e))
            .toList() {
    ingredients.sort((a, b) {
      return a.name.compareTo(b.name);
    });
  }
}

Future<List<Recepie>> readRecepies() async {
  final String response =
      await rootBundle.loadString('assets/recepies.json');

  List<Recepie> result = [];

  List pureJson = await json.decode(response);

  for (var r in pureJson) {
    result.add(Recepie.fromJson(r));
  }

  return result;
}

Future<List<Ingredient>> readIngredients() async {
  final String response =
      await rootBundle.loadString('assets/ingredients.json');

  List<Ingredient> result = [];

  List pureJson = await json.decode(response);

  for (var i in pureJson) {
    result.add(Ingredient.fromJson(i));
  }

  return result;
}
