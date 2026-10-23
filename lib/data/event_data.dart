import '../models/event.dart';

const List<String> eventCategories = [
  'All',
  'Technology',
  'Arts',
  'Sports',
];

final List<Event> initialEvents = [
  Event(
    id: 1,
    title: 'Campus Art Festival',
    category: 'Arts',
    date: DateTime(2026, 11, 15, 18, 30),
    venue: 'Main Auditorium',
    description:
        'Join us for an unforgettable night of live art exhibitions and performances by talented artists from around the world.',
    capacity: 50,
    imagePath: 'assets/images/art.jpeg',
    availablePlaces: 0,
  ),
  Event(
    id: 2,
    title: 'Sports Day 2026',
    category: 'Sports',
    date: DateTime(2026, 11, 10, 10, 0),
    venue: 'Conference Hall A',
    description:
        'Join us for an exciting day of sports competitions and activities.',
    capacity: 30,
    imagePath: 'assets/images/spor.jpeg',
    availablePlaces: 1,
  ),
  Event(
    id: 3,
    title: 'Tech Conference 26',
    category: 'Technology',
    date: DateTime(2026, 12, 9, 14, 0),
    venue: 'Conference Hall C',
    description:
        'Join us for an exciting day of technology trends and innovations.',
    capacity: 30,
    imagePath: 'assets/images/tech.jpeg',
    availablePlaces: 12,
  ),
  Event(
    id: 4,
    title: 'Music Concert',
    category: 'Arts',
    date: DateTime(2026, 12, 20, 20, 0),
    venue: 'Outdoor Stage',
    description:
        'Experience an unforgettable night of live music performances by renowned artists.',
    capacity: 100,
    imagePath: 'assets/images/art.jpeg',
    availablePlaces: 50,
  ),
  Event(
    id: 5,
    title: 'Science Fair',
    category: 'Technology',
    date: DateTime(2026, 12, 5, 11, 30),
    venue: 'Science Building',
    description:
        'Explore the wonders of science and technology at our annual science fair.',
    capacity: 80,
    imagePath: 'assets/images/tech.jpeg',
    availablePlaces: 20,
  ),
  Event(
    id: 6,
    title: 'Cultural Festival',
    category: 'Sports',
    date: DateTime(2026, 12, 15, 16, 0),
    venue: 'Cultural Center',
    description:
        'Celebrate diversity and cultural heritage at our vibrant cultural festival.',
    capacity: 150,
    imagePath: 'assets/images/spor.jpeg',
    availablePlaces: 75,
  ),
];