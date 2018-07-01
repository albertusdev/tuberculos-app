import "package:flutter/material.dart";
import 'package:tuberculos/models/apoteker.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_dashboard_unverified_pasien_tab.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_dashboard_verified_pasien_tab.dart';

class ApotekerDashboardScreen extends StatefulWidget {
  final Apoteker apoteker;

  ApotekerDashboardScreen({Key key, this.apoteker}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      new _ApotekerDashboardScreenState(apoteker);
}

class _ApotekerDashboardScreenState extends State<ApotekerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final Apoteker apoteker;

  _ApotekerDashboardScreenState(this.apoteker);

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Column(
        children: [
          new Row(
            children: [
              new Expanded(
                child: new Container(
                  child: new TabBar(
                    tabs: [
                      new Container(
                        padding: new EdgeInsets.all(16.0),
                        child: new Text(
                          "Terverifikasi",
                        ),
                      ),
                      new Container(
                        child: new Text(
                          "Belum Terverifikasi",
                        ),
                        padding: new EdgeInsets.all(16.0),
                      ),
                    ],
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).highlightColor,
                  ),
                ),
              )
            ],
          ),
          new Expanded(
            child: new TabBarView(
              children: [
                new VerifiedPasiensTab(apoteker: apoteker),
                new UnverifiedPasiensTab(apoteker: apoteker),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
