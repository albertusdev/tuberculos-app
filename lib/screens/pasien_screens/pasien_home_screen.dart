import "package:flutter/material.dart";

import "package:firebase_auth/firebase_auth.dart";

import "package:tuberculos/routes.dart";

class PasienHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Pasien - TuberculosApp")),
      bottomNavigationBar: new BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text("Home"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.book),
            title: new Text("Majalah"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.inbox),
            title: new Text("Chat"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.exit_to_app),
            title: new Text("Logout"),
          ),
        ],
        onTap: (currentIndex) {
          if (currentIndex == 3) {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacementNamed(
                Routes.splashScreen.toString());
          }
        },
      ),
    );
  }
}
