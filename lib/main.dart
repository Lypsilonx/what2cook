import 'package:flutter/material.dart';
import 'package:what2cook/format.dart';
import 'package:what2cook/storage.dart';
import 'package:what2cook/visual.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'What2Cook',
      home: HomePage(),
      theme: ThemeData(
        accentColor: Colors.black, //Text
        backgroundColor: Colors.blue[50],
        primaryColor: Colors.blue,
        errorColor: Colors.redAccent, //Item not available
        hintColor: Colors.red, //Indicator dot for selected recepies
        indicatorColor: Colors.green, //Selected Items
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  List<Ingredient> available = [];
  List<Recepie> selected = [];

  List<Ingredient> needed() {
    List<Ingredient> ing = [];

    for (Recepie r in selected) {
      ing.addAll(r.ingredients);
    }

    return ing;
  }

  double sco = 0;

  String searchWord = '';
  TextEditingController sfc = TextEditingController();
  ScrollController lc = ScrollController();
  bool searching = false;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Recepie> recepies = [];

  @override
  void initState() {
    super.initState();

    readRecepies().then((value) {
      setState(() {
        value.sort(
          (a, b) => (1 -
                  a.cookableP(widget.available) -
                  (widget.selected.map((e) => e.name).contains(a.name) ? 1 : 0))
              .compareTo(1 -
                  b.cookableP(widget.available) -
                  (widget.selected.map((e) => e.name).contains(b.name)
                      ? 1
                      : 0)),
        );
        recepies = value;
      });
    });

    readIngredients().then((value) {
      setState(() {
        allIngredients = value;
        allIngredients.sort((a, b) => a.name.compareTo(b.name));
      });
    });
  }

  @override
  Widget build(BuildContext ctx) {
    var screenSize = MediaQuery.of(ctx).size;

    read<String>('available').then((value) {
      setState(() {
        if (value == '') {
          widget.available = [];
        } else {
          widget.available = value.split(';').map((e) {
            return allIngredients.where((e2) => e2.name == e).first;
          }).toList();
        }
      });
    });

    read<String>('selected').then((value) {
      setState(() {
        if (value == '') {
          widget.selected = [];
        } else {
          widget.selected = value.split(';').map((e) {
            return recepies.where((e2) => e2.name == e).first;
          }).toList();
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('What2Cook'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: screenSize.width,
              padding: EdgeInsets.only(
                left: screenSize.width * 0.01,
                right: screenSize.width * 0.01,
              ),
              color: Theme.of(ctx).backgroundColor,
              child: ListView.builder(
                itemCount: recepies
                    .where((e) =>
                        e.cookableP(widget.available) > 0 ||
                        widget.selected.contains(e))
                    .length,
                itemBuilder: (ctx, idx) {
                  return recepies
                      .where((e) =>
                          e.cookableP(widget.available) > 0 ||
                          widget.selected.contains(e))
                      .map(
                    (r) {
                      return GestureDetector(
                        child: UIRecepie(
                            r, widget.available, widget.selected.contains(r)),
                        onLongPress: () {
                          setState(() {
                            if (widget.selected.contains(r)) {
                              widget.selected.remove(r);
                            } else {
                              widget.selected.add(r);
                            }

                            recepies
                              ..sort(
                                (a, b) => (1 -
                                        a.cookableP(widget.available) -
                                        (widget.selected
                                                .map((e) => e.name)
                                                .contains(a.name)
                                            ? 1
                                            : 0))
                                    .compareTo(1 -
                                        b.cookableP(widget.available) -
                                        (widget.selected
                                                .map((e) => e.name)
                                                .contains(b.name)
                                            ? 1
                                            : 0)),
                              );
                          });
                          save(
                            'selected',
                            widget.selected.map((e) => e.name).join(';'),
                          );
                        },
                      );
                    },
                  ).toList()[idx];
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.02),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Ingredients",
                focusColor: Theme.of(ctx).primaryColor,
                hintStyle: TextStyle(
                  color: Theme.of(ctx).accentColor.withAlpha(100),
                ),
              ),
              controller: widget.sfc,
              onTap: () {
                setState(() {
                  widget.searching = true;
                  widget.lc.jumpTo(0);
                });
              },
              onChanged: (search) {
                setState(() {
                  widget.searchWord = search.toLowerCase();
                });
              },
              onSubmitted: (search) {
                setState(() {
                  widget.searching = false;
                  widget.searchWord = search.toLowerCase();
                });
              },
            ),
          ),
          Container(
            height: widget.searching
                ? screenSize.width * 0.21
                : screenSize.height * 0.4,
            width: screenSize.width,
            child: ListView(
              scrollDirection:
                  widget.searching ? Axis.horizontal : Axis.vertical,
              controller: widget.lc,
              children: splitIn(
                          allIngredients
                              .where((e) =>
                                  e.name
                                      .toLowerCase()
                                      .contains(widget.searchWord) ||
                                  widget.searchWord == '')
                              .map(
                            (i) {
                              return UIIngredient(
                                  i,
                                  widget.available.contains(i),
                                  widget
                                      .needed()
                                      .where((e) => e.name == i.name)
                                      .length);
                            },
                          ).map((uii) {
                            return GestureDetector(
                              child: uii,
                              onTap: () {
                                setState(() {
                                  if (widget.available
                                      .contains(uii.ingredient)) {
                                    widget.available.remove(uii.ingredient);
                                  } else {
                                    widget.available.add(uii.ingredient);
                                  }
                                  widget.searchWord = '';
                                  widget.sfc.clear();
                                  recepies
                                    ..sort(
                                      (a, b) => (1 -
                                              a.cookableP(widget.available) -
                                              (widget.selected
                                                      .map((e) => e.name)
                                                      .contains(a.name)
                                                  ? 1
                                                  : 0))
                                          .compareTo(1 -
                                              b.cookableP(widget.available) -
                                              (widget.selected
                                                      .map((e) => e.name)
                                                      .contains(b.name)
                                                  ? 1
                                                  : 0)),
                                    );
                                });
                                save(
                                  'available',
                                  widget.available.map((e) => e.name).join(';'),
                                );
                              },
                            );
                          }).toList(),
                          5)
                      .map<Widget>((l) {
                    return Row(
                      children: l,
                    );
                  }).toList() +
                  [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(ctx).primaryColor),
                      ),
                      onPressed: () {
                        setState(() {
                          widget.available = [];
                          save(
                            'available',
                            '',
                          );
                        });
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(color: Theme.of(ctx).accentColor),
                      ),
                    )
                  ],
            ),
          ),
        ],
      ),
    );
  }
}

List<List<T>> splitIn<T>(List<T> items, int n) {
  return List.generate(
      (items.length / n).ceil(),
      (i) => items.sublist(
          n * i, (i + 1) * n <= items.length ? (i + 1) * n : null));
}
