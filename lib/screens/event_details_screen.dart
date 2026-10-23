import 'package:flutter/material.dart';
import '../models/event.dart';
import 'image_viewer_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  final bool Function(int eventId) isFavorite;
  final bool Function(int eventId) isJoined;
  final void Function(int eventId) onToggleFavorite;
  final Future<void> Function(BuildContext context, Event event) onJoinOrCancel;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.isFavorite,
    required this.isJoined,
    required this.onToggleFavorite,
    required this.onJoinOrCancel,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  String _formatDateTime(DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} at $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final Event event = widget.event;
    final bool fav = widget.isFavorite(event.id);
    final bool joined = widget.isJoined(event.id);
    final bool isFull = event.availablePlaces == 0;

    // An unjoined event with zero available places is Full and cannot be joined.
    // A student who joined the last available place must still be able to cancel.
    final bool canInteractWithParticipation = joined || !isFull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            tooltip: fav ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              fav ? Icons.favorite : Icons.favorite_border,
              color: fav ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                widget.onToggleFavorite(event.id);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Double-tap on the image opens another screen with an enlarged image
            GestureDetector(
              onDoubleTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(
                      imagePath: event.imagePath,
                      title: event.title,
                    ),
                  ),
                );
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.asset(
                    event.imagePath,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Double-tap to enlarge',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Favorite Control
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          fav ? Icons.favorite : Icons.favorite_border,
                          color: fav ? Colors.red : Colors.grey,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.onToggleFavorite(event.id);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category and Status Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(event.category),
                      ),
                      Chip(
                        backgroundColor: isFull
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        label: Text(
                          isFull
                              ? 'Full (0 / ${event.capacity})'
                              : 'Available: ${event.availablePlaces} / ${event.capacity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isFull
                                ? Colors.red.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                      if (joined)
                        Chip(
                          backgroundColor: Colors.deepPurple.shade100,
                          avatar: const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.deepPurple,
                          ),
                          label: const Text(
                            'Joined',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Event ID, Date/Time, Venue, Capacity info
                  _buildInfoRow(
                    Icons.tag,
                    'Event ID',
                    '#${event.id}',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date & Time',
                    _formatDateTime(event.date),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.location_on,
                    'Venue',
                    event.venue,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.people,
                    'Capacity & Availability',
                    '${event.availablePlaces} available / ${event.capacity} total capacity (Initial: ${event.initialAvailablePlaces})',
                  ),
                  const Divider(height: 28),

                  // Description
                  const Text(
                    'About this event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 28),

                  // Participation Button (Join / Cancel / Full)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: joined
                            ? Colors.red.shade600
                            : (isFull ? Colors.grey : Colors.deepPurple),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        joined
                            ? Icons.cancel_outlined
                            : (isFull ? Icons.block : Icons.event_available),
                      ),
                      label: Text(
                        joined
                            ? 'Cancel participation'
                            : (isFull ? 'Event is Full' : 'Join Event'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: canInteractWithParticipation
                          ? () async {
                              await widget.onJoinOrCancel(context, event);
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
