import 'package:concordia_navigation/models/user_location.dart';
import 'package:concordia_navigation/providers/buildings_data.dart';
import 'package:concordia_navigation/providers/calendar_data.dart';
import 'package:concordia_navigation/providers/map_data.dart';
import 'package:concordia_navigation/screens/course_schedule.dart';
import 'package:concordia_navigation/screens/home_page.dart';
import 'package:concordia_navigation/screens/outdoor_interest.dart';
import 'package:concordia_navigation/screens/profile.dart';
import 'package:concordia_navigation/screens/settings.dart';
import 'package:concordia_navigation/screens/shuttle_schedule.dart';
import 'package:concordia_navigation/services/localization.dart';
import 'package:concordia_navigation/services/location_service.dart';
import 'package:concordia_navigation/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Widget used to test whole App
Widget appWidget({MapData mapData, Widget testWidget}) {
  TestWidgetsFlutterBinding.ensureInitialized();
// Providers
  Widget userLocationProvider = StreamProvider<UserLocation>(
    create: (_) => LocationService.getInstance().stream,
    initialData: UserLocation.sgw(),
  );

  Widget mapDataProvider = ChangeNotifierProvider<MapData>(
    create: (_) => MapData(),
  );

  Widget buildingsDataProvider = ChangeNotifierProvider<BuildingsData>(
    create: (_) => BuildingsData(),
  );

  Widget calendarData = ChangeNotifierProvider<CalendarData>(
    create: (_) => CalendarData(),
  );

// Mock Providers
  if(mapData != null) {
    mapDataProvider = ChangeNotifierProvider<MapData>.value( value: mapData,);
  }

// Testing App
  return MultiProvider(
      providers: [
        userLocationProvider,
        mapDataProvider,
        buildingsDataProvider,
        calendarData
      ],
      child: testWidget != null ? MaterialApp(home:TestWidget(testWidget)) : TestApp(),
  );
}


/// Used to test individual widgets
class TestWidget extends StatelessWidget {
  final Widget widget; 

  TestWidget(this.widget);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return widget;
  }
}


/**
 * Used to test whole app.
 * NOTE: Assets will need to be loaded manually per test as opposed from the SplashScreen widget
 */
class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concordia Navigation',
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        const ConcordiaLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('fr', ''),
      ],
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomePage(),
        '/schedule': (context) => CourseSchedule(),
        '/profile': (context) => Profile(),
        '/o_interest': (context) => OutdoorInterest(),
        '/settings': (context) => Settings(),
        '/shuttle': (context) => ShuttleSchedule(),
      },
      debugShowCheckedModeBanner: false,
      home: null,
    );
  }
}