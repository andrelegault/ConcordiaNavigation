import 'package:concordia_navigation/models/indoor/indoor_location.dart';
import 'package:concordia_navigation/models/outdoor/outdoor_location.dart';
import 'package:concordia_navigation/models/uni_location.dart';
import 'package:concordia_navigation/providers/indoor_data.dart';
import 'package:concordia_navigation/screens/indoor_page.dart';
import 'package:concordia_navigation/services/search.dart';
import 'package:concordia_navigation/storage/app_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:concordia_navigation/providers/map_data.dart';

/*This class extends Search Delegate class implemented by flutter.
It will be called when the user clicks on the search button in the Appbar.
*/
class LocationSearch extends SearchDelegate {
  final bool isFirst;

  LocationSearch(this.isFirst);

  ///This method returns suggested locations to the user, in this case Loyola and SGW campus.
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? Search.names.take(10).toList()
        : Search.names.where((p) => p.contains(query.toUpperCase())).toList();

    return Consumer<MapData>(builder: (context, mapData, child) {
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () async {
            // search for element they tapped
            dynamic result = Search.query(suggestionList[index]);
            mapData.itinerary = null;

            if (isFirst) {
              mapData.start = result;
            } else {
              mapData.end = result;
            }

            Navigator.of(context).pop();
            if (mapData.start != null && mapData.end != null) {
              if (mapData.start is OutdoorLocation &&
                  mapData.end is OutdoorLocation) {
                mapData.setItinerary();
              } else if (mapData.start is IndoorLocation &&
                  mapData.end is IndoorLocation) {
                // This will check if buildings are the same, no need to worry
                mapData.setItinerary();
                Provider.of<IndoorData>(context, listen: false).setItinerary(
                    start: (mapData.start as IndoorLocation).name,
                    end: (mapData.end as IndoorLocation).name);
                Navigator.pushNamed(context, '/indoor',
                    arguments: Arguments(true));
              } else {
                OutdoorLocation selected = mapData.start is IndoorLocation
                    ? mapData.end
                    : mapData.start;
                String letter =
                    (selected.parent as OutdoorLocation).parent.name[0];
                String indoor = letter == 'H' ? 'H1entrance' : 'MBentrance';
                Provider.of<IndoorData>(context, listen: false).setItinerary(
                    start: selected == mapData.start
                        ? indoor
                        : (mapData.start as UniLocation).name,
                    end: selected == mapData.end
                        ? indoor
                        : (mapData.end as UniLocation).name);
                mapData.setItinerary();
              }
            }
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
