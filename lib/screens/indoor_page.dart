import 'package:concordia_navigation/models/indoor/floor.dart';
import 'package:concordia_navigation/providers/buildings_data.dart';
import 'package:concordia_navigation/services/painters.dart';
import 'package:concordia_navigation/services/search.dart';
import 'package:concordia_navigation/widgets/indoor/indoor_widget.dart';
import 'package:flutter/material.dart';
import 'package:concordia_navigation/storage/app_constants.dart' as constants;
import 'package:google_fonts/google_fonts.dart';

class Arguments {
  final bool showDirections;

  Arguments(this.showDirections);
}

class IndoorPage extends StatelessWidget {
  final PageController controller =
      PageController(initialPage: 0, viewportFraction: 1, keepPage: true);

  @override
  Widget build(BuildContext context) {
    // for each floor in domain, do this
    List<Floor> floors = [];
    BuildingsData.allBuildings.forEach((building) =>
        building.children.forEach((floor) => floors.add((floor))));
    List<Widget> buttons = [];
    for (int i = 0; i < floors.length; i++) {
      Widget button = FloatingActionButton(
        heroTag: "btn$i",
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        backgroundColor: constants.blackColor,
        child: Center(
          child: Text(
            floors[i].name,
            style: GoogleFonts.raleway(
                fontWeight: FontWeight.normal,
                color: constants.whiteColor,
                fontSize: 20.0),
          ),
        ),
        onPressed: () {
          controller.animateToPage(i,
              duration: Duration(milliseconds: 500), curve: Curves.decelerate);
        },
      );
      buttons.add(button);
    }
    return Scaffold(
      backgroundColor: constants.whiteColor,
      appBar: AppBar(
        title: Text("Indoor View"),
        backgroundColor: constants.appColor,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: PageView.builder(
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemCount: Painters.painters.length,
              itemBuilder: (context, index) {
                return IndoorWidget(index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 75.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
            ),
          ),
        ],
      ),
    );
  }
}
