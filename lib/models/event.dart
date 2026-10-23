class Event {
  final int id;
  final String title;
  final String category;
  final DateTime date;
  final String venue;
  final String description;
  final int capacity;
  final int initialAvailablePlaces;
  final String imagePath;
  int availablePlaces;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.venue,
    required this.description,
    required this.capacity,
    required this.imagePath,
    required this.availablePlaces,
  })  : initialAvailablePlaces = availablePlaces,
        assert(availablePlaces >= 0 && availablePlaces <= capacity);
}