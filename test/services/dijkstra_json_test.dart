import 'package:concordia_navigation/models/indoor/node.dart';
import 'package:concordia_navigation/models/outdoor/university.dart';
import 'package:concordia_navigation/services/indoor/dijkstra.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dijkstra', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    List<dynamic> campusData;
    Map<String, Node> graph;
    Dijkstra dijkstra;
    List<Node> solution;

    setUp(() async {
      campusData = await University.loadJson();
      dijkstra = Dijkstra.fromJson(campusData);
      graph = dijkstra.nodes;
    });
    test('constructor creates a list of edges', () {
      solution = [
        graph['H1entrance'],
        graph['H1escalatorDown'],
        graph['H1exitMR']
      ];
      List<Node> result = dijkstra.pathTo("H1entrance", "H1exitMR");
      expect(solution, result);
    });
    test('testing route with accessibility disabled', () {
      solution = [
        graph['H1entrance'],
        graph['H1checkMM'],
        graph['H1escalatorUp'],
        graph['H8escalatorUp'],
        graph['H862'],
        graph['H859'],
        graph['H857'],
        graph['H855'],
      ];
      List<Node> result =
          dijkstra.pathTo("H1entrance", "H855", accessible: false);
      expect(solution, result);
    });
    test('testing route with accessibility enabled', () {
      solution = [
        graph['H1entrance'],
        graph['H1checkMM'],
        graph['H1women'],
        graph['H1elevator'],
        graph['H8elevator'],
        graph['H859'],
        graph['H857'],
        graph['H855'],
      ];
      List<Node> result =
          dijkstra.pathTo("H1entrance", "H855", accessible: true);
      expect(solution, result);
    });
    test(
        'testing route from entrance of Hall to H967 with accessibility disabled',
        () {
      solution = [
        graph['H1entrance'],
        graph['H1checkMM'],
        graph['H1escalatorUp'],
        graph['H9escalatorUp'],
        graph['H9escalatorDown'],
        graph['H962'],
        graph['H964'],
        graph['H963'],
        graph['H965'],
        graph['H967'],
      ];
      List<Node> result =
          dijkstra.pathTo("H1entrance", "H967", accessible: false);
      expect(solution, result);
    });
    test(
        'testing route from entrance of Hall to H967 with accessibility enabled',
        () {
      solution = [
        graph['H1entrance'],
        graph['H1checkMM'],
        graph['H1women'],
        graph['H1elevator'],
        graph['H9elevator'],
        graph['H962'],
        graph['H964'],
        graph['H963'],
        graph['H965'],
        graph['H967'],
      ];
      List<Node> result =
          dijkstra.pathTo("H1entrance", "H967", accessible: true);
      expect(solution, result);
    });
    test('testing route from H110 to H913 with accessibility enabled', () {
      solution = [
        graph['H110'],
        graph['H1checkMM'],
        graph['H1women'],
        graph['H1elevator'],
        graph['H9elevator'],
        graph['H9accessibility'],
        graph['H909'],
        graph['H911'],
        graph['H913'],
      ];
      List<Node> result = dijkstra.pathTo("H110", "H913", accessible: true);
      expect(solution, result);
    });
    test('testing route from H903 to H803 with accessibility disabled', () {
      solution = [
        graph['H903'],
        graph['H907'],
        graph['H909'],
        graph['H9escalatorDown'],
        graph['H8escalatorDown'],
        graph['H8escalatorUp'],
        graph['H8checkTM'],
        graph['H807'],
        graph['H805'],
        graph['H803'],
      ];
      List<Node> result = dijkstra.pathTo("H903", "H803");
      expect(solution, result);
    });

    test('testing route from H903 to H110 with accessibility disabled', () {
      solution = [
        graph['H903'],
        graph['H907'],
        graph['H909'],
        graph['H9escalatorDown'],
        graph['H1escalatorUp2'],
        graph['H1checkMM'],
        graph['H110'],
      ];
      List<Node> result = dijkstra.pathTo("H903", "H110");
      expect(solution, result);
    });
  });
}
