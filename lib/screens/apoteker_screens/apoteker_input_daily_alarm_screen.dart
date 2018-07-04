import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tuberculos/redux/configure_store.dart';
import "package:tuberculos/services/api.dart";
import 'package:tuberculos/widgets/choose_pasien_dialog.dart';
import 'package:tuberculos/widgets/full_width_widget.dart';

class ApotekerInputDailyAlarmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreBuilder(
        builder: (BuildContext build, Store<AppState> store) {
      return new Scaffold(
        appBar: new AppBar(title: new Text("Pengingat")),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Container(
                  child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(
                    child: new Text(
                      "Email Pasien yang dituju",
                      style: new TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    margin: new EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  new FullWidthWidget(
                    child: new OutlineButton(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text("Pilih Email", style: new TextStyle(
                              color: Theme.of(context).disabledColor,
                            ),),
                            new Icon(Icons.menu,
                                color: Theme.of(context).disabledColor),
                          ]),
                      onPressed: () {
                        showDialog<String>(
                            context: context,
                            builder: (context) {
                              return new ChoosePasienDialog(
                                  getPasiensCollectionReference(
                                      store.state.currentUser.email));
                            }).then(
                          (String email) {
                            print(email);
//                            store.dispatch(null);
                          },
                        );
                      },
                    ),
                  ),
                ],
              )),
              new Container(),
              new Container(),
            ],
          ),
          margin: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
      );
    });
  }
}
