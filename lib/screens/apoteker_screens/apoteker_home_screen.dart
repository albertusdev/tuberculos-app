import "package:flutter/material.dart";

class ApotekerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Apoteker - TuberculosApp")),
      bottomNavigationBar: new BottomNavigationBar(items: [
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
      ]),
    );
  }
}
