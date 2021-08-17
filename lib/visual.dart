import 'package:flutter/material.dart';
import 'package:what2cook/format.dart';

class UIRecepie extends StatelessWidget {
  Recepie recepie;
  List<Ingredient> available;
  bool selected;

  UIRecepie(this.recepie, this.available, this.selected);

  @override
  Widget build(BuildContext ctx) {
    var screenSize = MediaQuery.of(ctx).size;

    double perc = recepie.cookableP(available);

    int aP = selected ? 255 : (255 * perc).toInt();

    recepie.ingredients.sort((a, b) {
      return (available.map((e) => e.name).contains(a.name) ? 0 : 1)
          .compareTo((available.map((e) => e.name).contains(b.name) ? 0 : 1));
    });

    return Container(
      width: screenSize.width * 0.9,
      margin: EdgeInsets.only(top: screenSize.height * 0.01),
      padding: EdgeInsets.all(screenSize.height * 0.01),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? Theme.of(ctx).hintColor : Colors.transparent,
          width: screenSize.height * 0.005,
        ),
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(ctx).primaryColor.withAlpha(
              aP,
            ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
              Row(
                children: (recepie.symbol != ''
                        ? <Widget>[
                            Text(
                              recepie.symbol,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.05,
                                color: Theme.of(ctx).accentColor.withAlpha(
                                      aP,
                                    ),
                              ),
                            )
                          ]
                        : <Widget>[]) +
                    [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recepie.name,
                            style: TextStyle(
                              fontSize: screenSize.height * 0.03,
                              color: Theme.of(ctx).accentColor.withAlpha(
                                    aP,
                                  ),
                            ),
                          ),
                          Container(
                            width: screenSize.width * 0.5,
                            child: ClipRect(
                              child: RichText(
                                softWrap: true,
                                overflow: TextOverflow.fade,
                                text: TextSpan(
                                  children: recepie.ingredients
                                      .map(
                                        (e) => TextSpan(
                                          text: e.name +
                                              (recepie.ingredients.last == e
                                                  ? ''
                                                  : ', '),
                                          style: TextStyle(
                                            fontSize: screenSize.height * 0.02,
                                            color: available
                                                    .map((e) => e.name)
                                                    .contains(e.name)
                                                ? Theme.of(ctx)
                                                    .accentColor
                                                    .withAlpha(
                                                      aP,
                                                    )
                                                : Theme.of(ctx)
                                                    .errorColor
                                                    .withAlpha(
                                                      aP,
                                                    ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
              ),
            ] +
            (perc == 1
                ? [
                    Container(
                      width: screenSize.width * 0.1,
                      height: screenSize.width * 0.1,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(screenSize.width * 0.05),
                        color: Theme.of(ctx).indicatorColor,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                  ]
                : <Widget>[]),
      ),
    );
  }
}

class UIIngredient extends StatelessWidget {
  Ingredient ingredient;
  bool isAvailable;
  int needed;

  UIIngredient(this.ingredient, this.isAvailable, this.needed);

  @override
  Widget build(BuildContext ctx) {
    var screenSize = MediaQuery.of(ctx).size;

    return Container(
      width: screenSize.width * 0.188,
      height: screenSize.width * 0.188,
      margin: EdgeInsets.only(
        left: screenSize.width * 0.01,
        top: screenSize.width * 0.01,
      ),
      padding: EdgeInsets.all(screenSize.width * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isAvailable
            ? Theme.of(ctx).indicatorColor
            : Theme.of(ctx).primaryColor.withAlpha(70),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: (ingredient.symbol != ''
                      ? <Widget>[
                          Expanded(
                            child: Text(
                              ingredient.symbol,
                              style: TextStyle(
                                fontSize: screenSize.height * 0.03,
                              ),
                            ),
                          ),
                        ]
                      : <Widget>[]) +
                  [
                    Flexible(
                      child: Text(
                        ingredient.name,
                        overflow: TextOverflow.fade,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenSize.height * 0.02),
                  color: (isAvailable ? 0 : needed) > 0
                      ? Theme.of(ctx).hintColor.withAlpha(70)
                      : Colors.transparent,
                ),
                height: screenSize.height * 0.02,
                width: screenSize.height * (0.015 * needed + 0.005),
                padding: EdgeInsets.only(
                  right: screenSize.height * 0.005,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    isAvailable ? 0 : needed,
                    (idx) => Container(
                      width: screenSize.height * 0.01,
                      height: screenSize.height * 0.01,
                      margin: EdgeInsets.only(
                        left: screenSize.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          screenSize.height * 0.005,
                        ),
                        color: Theme.of(ctx).hintColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
