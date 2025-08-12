
class PathFinder {
  final Map<String, dynamic> nodes;
  final Map<String, dynamic> edges;


  PathFinder({required this.nodes, required this.edges});


  List<String> findShortestPath(String startNodeKey, String endNodeKey) {
    // Basic validation
    if (!nodes.containsKey(startNodeKey) || !nodes.containsKey(endNodeKey)) {
      return []; // Return empty path if nodes don't exist
    }


    // Stores the shortest known distance from the start node
    final Map<String, double> distances = {};
    // Stores the previous node in the shortest path
    final Map<String, String?> previousNodes = {};
    // A priority queue to efficiently access the node with the smallest distance
    final PriorityQueue<String> priorityQueue = PriorityQueue<String>(
      (a, b) => (distances[a] ?? double.infinity)
          .compareTo(distances[b] ?? double.infinity),
    );


    // Initialize distances
    for (var key in nodes.keys) {
      distances[key] = double.infinity;
      previousNodes[key] = null;
    }


    // The distance to the start node is 0
    distances[startNodeKey] = 0;
    priorityQueue.add(startNodeKey);


    while (priorityQueue.isNotEmpty) {
      String currentNodeKey = priorityQueue.removeFirst();


      // If we've reached the destination, we can stop
      if (currentNodeKey == endNodeKey) break;


      final connections = edges[currentNodeKey];
      if (connections == null || connections is! List) continue;


      for (String neighborKey in connections) {
        // In your structure, the distance is implicitly 1 (one edge)
        // If you were to use weighted edges, you would get the weight here.
        const double distance = 1.0;
       
        double newPathDistance = (distances[currentNodeKey] ?? 0) + distance;


        if (newPathDistance < (distances[neighborKey] ?? double.infinity)) {
          distances[neighborKey] = newPathDistance;
          previousNodes[neighborKey] = currentNodeKey;
          priorityQueue.add(neighborKey);
        }
      }
    }


    // Reconstruct the path from end to start
    List<String> path = [];
    String? currentNode = endNodeKey;
    while (currentNode != null) {
      path.add(currentNode);
      currentNode = previousNodes[currentNode];
    }


    // The path is currently from end to start, so we reverse it
    return path.reversed.toList();
  }
}


// A simple priority queue implementation needed for Dijkstra's algorithm
class PriorityQueue<T> {
  final List<T> _elements = [];
  final int Function(T, T) _comparator;


  PriorityQueue(this._comparator);


  bool get isNotEmpty => _elements.isNotEmpty;


  void add(T element) {
    _elements.add(element);
    _elements.sort(_comparator);
  }


  T removeFirst() {
    return _elements.removeAt(0);
  }
}
