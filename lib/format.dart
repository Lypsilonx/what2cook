import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:what2cook/storage.dart';

class Ingredient {
  String symbol, name;

  Ingredient(this.symbol, this.name);

  Ingredient.fromJson(Map<String, dynamic> json)
      : symbol = json['symbol'],
        name = json['name'];
}

List<Ingredient> allIngredients = [];

class Recipe {
  String symbol, name;
  List<Ingredient> ingredients;

  Recipe(this.symbol, this.name, this.ingredients);

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

  Recipe.fromJson(Map<String, dynamic> json)
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

Future<List<Recipe>> readRecipes() async {
  final String response = await rootBundle.loadString('assets/recipes.json');

  List<Recipe> result = [];

  List pureJson = await json.decode(response);

  for (var r in pureJson) {
    result.add(Recipe.fromJson(r));
  }

  String ownRecipes = await read<String>('ownR');

  result.addAll(stringToRecipes(ownRecipes));

  return result;
}

List<Recipe> stringToRecipes(String s) {
  List<Recipe> result = [];

  List<String> or = s.split(';');

  for (String r in or) {
    List<String> ing = r.split(',');

    result.add(
      Recipe(
        '',
        ing[0],
        ing.sublist(1).map((String i) => Ingredient('', i)).toList(),
      ),
    );
  }

  return result;
}

void addRecipe(Recipe r) async {
  String ownRecipes = await read<String>('ownR');

  String n = r.name + ',' + r.ingredients.map((e) => e.name).join(',');

  if (ownRecipes != '') {
    n = ';' + n;
  }

  save('ownR', ownRecipes + n);
}

Future<List<Recipe>> removeRecipe(Recipe r) async {
  String ownRecipes = await read<String>('ownR');

  List<Recipe> n = stringToRecipes(ownRecipes);
  n.remove(r);

  return n;
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
