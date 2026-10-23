import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isFavorite;
  final bool isJoined;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final VoidCallback? onJoinOrCancel;

  const EventCard({
    super.key,
    required this.event,
    required this.isFavorite,
    required this.isJoined,
    required this.onFavoriteToggle,
    required this.onTap,
    this.onJoinOrCancel,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        '${event.date.day.toString().padLeft(2, '0')}/${event.date.month.toString().padLeft(2, '0')}/${event.date.year} • ${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}';
    final bool isFull = event.availablePlaces == 0;
    final String availabilityText = isFull
        ? 'Full (0 / ${event.capacity} places)'
        : '${event.availablePlaces} / ${event.capacity} places available';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              event.imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        label: Text(event.category),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (isJoined)
                        const Chip(
                          label: Text('Joined'),
                          backgroundColor: Colors.greenAccent,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(formattedDate),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(child: Text(event.venue)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          availabilityText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (isFull && !isJoined)
                                ? Colors.red
                                : Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: 4,
                      children: [
                        if (onJoinOrCancel != null)
                          TextButton(
                            onPressed: (isJoined || !isFull)
                                ? onJoinOrCancel
                                : null,
                            child: Text(
                              isJoined
                                  ? 'Cancel participation'
                                  : (isFull ? 'Full' : 'Join'),
                              style: TextStyle(
                                color: isJoined
                                    ? Colors.red.shade700
                                    : (isFull ? Colors.grey : Colors.deepPurple),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: onTap,
                          child: const Text(
                            'Details →',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
}