import '../models/calendar/course.dart';
import '../providers/indoor_data.dart';
import '../providers/map_data.dart';
import '../services/search.dart';
import '../services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../storage/app_constants.dart' as constants;
import 'package:provider/provider.dart';

/// Widget class showing the course schedule
class Weekday extends StatelessWidget {
  final String weekday;
  final List<Course> courseList;

  /// Constructor for course schedule
  Weekday(this.weekday, this.courseList);

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat("Hm");

    List<Widget> courseContainer = [];
    courseContainer.add(Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, bottom: 15.0),
        child: Text(weekday,
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
      ),
    ));

    courseList.forEach((course) => courseContainer.add(ListTile(
        contentPadding: EdgeInsets.only(
            left: SizeConfig.safeBlockHorizontal * 5.0,
            right: SizeConfig.safeBlockHorizontal * 5.0),
        leading: CircleAvatar(
            backgroundImage: AssetImage('assets/png/concordia_logo.png')),
        title: Text(
          course.summary,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${formatter.format(course?.start?.toLocal())} - ${formatter.format(course?.end?.toLocal())}",
              style: TextStyle(color: constants.blueColor),
            ),
            Text(course.filteredLocation),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          RaisedButton(
              onPressed: (course.filteredLocation != 'N/A')
                  ? () {
                      var mapData =
                          Provider.of<MapData>(context, listen: false);
                      dynamic result = Search.query(course.filteredLocation);

                      if (result != null) {
                        String entrance =
                            result.name[0] == 'H' ? 'H1entrance' : 'MBentrance';
                        mapData.start = null;
                        Provider.of<IndoorData>(context, listen: false)
                            .setItinerary(start: entrance, end: result.name);
                        mapData.controllerStarting = "Current Location";
                        mapData.end = result;
                        mapData.mode = "driving";
                        mapData.setItinerary();
                        mapData.panelController.open();
                      }

                      // pop either way, if results are good or not
                      Navigator.of(context).pop();
                    }
                  : null,
              elevation: 1.0,
              color: constants.appColor,
              textColor: constants.whiteColor,
              child: Text("Directions")),
          Icon(Icons.keyboard_arrow_right)
        ]))));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: courseContainer,
    );
  }
}
