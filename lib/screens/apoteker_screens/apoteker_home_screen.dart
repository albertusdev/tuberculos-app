import 'dart:async';

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:tuberculos/models/apoteker.dart';
import "package:tuberculos/routes.dart";
import 'package:tuberculos/screens/apoteker_screens/apoteker_chat_list_screen.dart';
import 'package:tuberculos/screens/apoteker_screens/apoteker_dashboard_screen.dart';
import 'package:tuberculos/screens/apoteker_screens/input_majalah_screen.dart';
import "package:tuberculos/screens/logout_screen.dart";

class NavigationIconView {
  NavigationIconView({
    Widget icon,
    Widget activeIcon,
    Widget child,
    String title,
    Color color,
    TickerProvider vsync,
  })  : _icon = icon,
        _child = child,
        _color = color,
        _title = title,
        item = new BottomNavigationBarItem(
          icon: icon,
          title: new Text(title),
          backgroundColor: color,
        ),
        controller = new AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = new CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Widget _icon;
  final Widget _child;
  final Color _color;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(
      BottomNavigationBarType type, BuildContext context) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final ThemeData themeData = Theme.of(context);
      iconColor = themeData.brightness == Brightness.light
          ? themeData.primaryColor
          : themeData.accentColor;
    }

    return new FadeTransition(
      opacity: _animation,
      child: new SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.0, 0.02), // Slightly down.
          end: Offset.zero,
        ).animate(_animation),
        child: _child,
      ),
    );
  }
}

class CustomIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    return new Container(
      margin: const EdgeInsets.all(4.0),
      width: iconTheme.size - 8.0,
      height: iconTheme.size - 8.0,
      color: iconTheme.color,
    );
  }
}

class CustomInactiveIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    return new Container(
        margin: const EdgeInsets.all(4.0),
        width: iconTheme.size - 8.0,
        height: iconTheme.size - 8.0,
        decoration: new BoxDecoration(
          border: new Border.all(color: iconTheme.color, width: 2.0),
        ));
  }
}

class ApotekerHomeScreen extends StatefulWidget {
  static final String routeName = Routes.apotekerHomeScreen.toString();
  Apoteker currentUser;

  ApotekerHomeScreen({Key key, this.currentUser}) : super(key: key);

  @override
  _ApotekerHomeScreenState createState() =>
      new _ApotekerHomeScreenState(currentUser);
}

class _ApotekerHomeScreenState extends State<ApotekerHomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;
  List<NavigationIconView> _navigationViews;
  List<int> history = <int>[0];
  Apoteker currentUser;

  _ApotekerHomeScreenState(this.currentUser);

  @override
  void initState() {
    super.initState();

    // To override back button behavior
    WidgetsBinding.instance.addObserver(this);
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: const Icon(Icons.home),
        title: 'Home',
        color: Colors.deepPurple,
        vsync: this,
        child: new ApotekerDashboardScreen(apoteker: currentUser),
      ),
      new NavigationIconView(
        activeIcon: const Icon(Icons.library_books),
        icon: const Icon(Icons.library_books),
        title: 'Majalah',
        color: Colors.teal,
        vsync: this,
        child: new InputMajalahScreen(),
      ),
      new NavigationIconView(
        activeIcon: const Icon(Icons.chat),
        icon: const Icon(Icons.chat_bubble),
        title: 'Chat',
        color: Colors.indigo,
        vsync: this,
        child: new ApotekerChatListScreen(apoteker: currentUser),
      ),
      new NavigationIconView(
        icon: const Icon(Icons.exit_to_app),
        title: 'Logout',
        color: Colors.blue,
        vsync: this,
        child: new LogoutScreen(),
      ),
    ];

    for (NavigationIconView view in _navigationViews)
      view.controller.addListener(_rebuild);

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews) view.controller.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Future<bool> didPopRoute() {
    print(history);
    if (history.length > 1) {
      history.removeLast();
      _changeTab(history.removeLast());
      return new Future<bool>.value(true);
    }
    return new Future<bool>.value(false);
  }

  void _rebuild() {
    setState(() {});
  }

  void _changeTab(int index) async {
    if (index == _navigationViews.length - 1) {
      // If press Logout
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed(Routes.loginScreen.toString());
    } else {
      setState(() {
        _navigationViews[_currentIndex].controller.reverse();
        _currentIndex = index;
        _navigationViews[_currentIndex].controller.forward();
      });
    }
  }

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationIconView view in _navigationViews)
      transitions.add(view.transition(_type, context));

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return new Stack(children: transitions);
  }

  String _getAppBarTitle() {
    if (_currentIndex == 0) return "HOME";
    if (_currentIndex == 1) return "INPUT MAJALAH";
    if (_currentIndex == 2) return "CHAT";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        _changeTab(index);
        history.add(index);
      },
    );

    Widget app = new Scaffold(
      appBar: new AppBar(
        title: new Text(_getAppBarTitle()),
      ),
      body: new Center(child: _buildTransitionsStack()),
      bottomNavigationBar: botNavBar,
    );
    return app;
  }
}
