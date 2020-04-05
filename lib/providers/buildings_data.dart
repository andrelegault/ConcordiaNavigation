import 'package:concordia_navigation/models/outdoor/building.dart';
import 'package:concordia_navigation/models/outdoor/campus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/widgets.dart';

///Observer Pattern
///Handles data related to campus buildings, listens to changes and notifies listeners.
class BuildingsData extends ChangeNotifier {
  Set<Building> allBuildings;
  Set<Polygon> _allPolygons = new Set();
  Set<Polygon> _clear = new Set();

  bool _visible = true;

  Set<Polygon> get allPolygons {
    if (_visible) {
      return _allPolygons;
    }
    return _clear;
  }

  BuildingsData() {
    // Make one big set of buildings that has sgw + loy buildings
    allBuildings = Campus.sgw.buildings.union(Campus.loy.buildings);

    // Add the outline of every buildings to one big set of Polygons
    allBuildings.forEach((building) => _allPolygons.add(building.outline));

    //_buildingIcon.add(await getBytesFromAsset(iconSet.elementAt(i), 350));

    // Add the marker for every building that has the necessary data

    _visible = true;
  }

  void toggleOutline() {
    _visible = !_visible;
    notifyListeners();
  }
}
