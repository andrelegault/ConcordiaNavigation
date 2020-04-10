import 'package:concordia_navigation/models/calendar/course.dart';
import 'package:concordia_navigation/models/indoor/indoor_location.dart';
import 'package:concordia_navigation/models/reachable.dart';
import 'package:concordia_navigation/providers/calendar_data.dart';
import 'package:concordia_navigation/providers/indoor_data.dart';
import 'package:concordia_navigation/services/search.dart';
import 'package:concordia_navigation/storage/app_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:concordia_navigation/providers/map_data.dart';

/*This class extends Search Delegate class implemented by flutter.
It will be called when the user clicks on the search button in the Appbar.
*/
class LocationSearch extends SearchDelegate {
  ///This method returns suggested locations to the user, in this case Loyola and SGW campus.
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? Search.names.take(10).toList() // 5 first
        : Search.names.where((p) => p.contains(query.toUpperCase())).toList();

    CalendarData calendar = Provider.of<CalendarData>(context, listen: false);
    List<Course> nextClasses = calendar.schedule?.nextClasses(days: 7);
    if (nextClasses != null &&
        nextClasses.isNotEmpty &&
        nextClasses.first.filteredLocation != "N/A") {
      var next = nextClasses.first.filteredLocation + " [NEXT CLASS LOCATION]";
      // Avoid duplicates on widget rebuild
      if (!suggestionList.contains(next)) {
        suggestionList.insert(0, next);
      }
    }

    return Consumer<MapData>(builder: (context, mapData, child) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () async {
            // search for element they tapped
            dynamic result = Search.query(suggestionList[index].toUpperCase());

            if (result != null) {
              if (result is IndoorLocation) {
                Provider.of<IndoorData>(context)
                    .setItinerary("H820", result.name);
              }
              mapData.end = result;
              mapData.controllerStarting = "Current Location";
              mapData.mode = "driving";
              mapData.setItinerary(start: null, end: result as Reachable);
            }

            // pop either way, if results are good or not
            Navigator.of(context).pop();
          },
          leading: Icon(Icons.location_city),
          title: RichText(
              text: TextSpan(
                  text: suggestionList[index].substring(0, query.length),
                  style: TextStyle(
                      color: constants.blackColor, fontWeight: FontWeight.bold),
                  children: [
                TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(
                    color: constants.greyColor,
                  ),
                ),
              ])),
        ),
        itemCount: suggestionList.length,
      );
    });
  }

  ///This method adds a return IconButton to return to the homepage.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  ///This method add the a clear IconButton to clear user's input.
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  ///This method returns results from user input.
  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }
}
