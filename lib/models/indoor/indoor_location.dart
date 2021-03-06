import '../../services/search.dart';
import 'coordinate.dart';
import 'floor.dart';
import '../outdoor/building.dart';
import '../outdoor/reachable.dart';
import '../uni_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// indoor locations are reachable since theyre in buildings and buildings are reachable
abstract class IndoorLocation extends UniLocation implements Reachable {
  Coordinate room;
  Coordinate nearest;

  IndoorLocation(String name, {UniLocation parent, this.room, this.nearest})
      : super(name, parent: parent);

  IndoorLocation.fromJson(Map json, {UniLocation parent})
      : room = Coordinate.fromJson(json['coordinates']['room']),
        nearest = Coordinate.fromJson(json['coordinates']['nearest']),
        super(json['name'], parent: parent) {
    Search.supported.add(this);
  }

  @override
  double get lat {
    Floor floor = parent as Floor;
    Building building = floor.parent as Building;
    return building.lat;
  }

  @override
  double get long {
    Floor floor = parent as Floor;
    Building building = floor.parent as Building;
    return building.long;
  }

  @override
  LatLng toLatLng() => lat == null || long == null ? null : LatLng(lat, long);
}
