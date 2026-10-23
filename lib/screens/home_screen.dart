import 'package:flutter/material.dart';
import '../models/event.dart';
import '../data/event_data.dart';
import '../widgets/event_card.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Event> _events = initialEvents;
  final Set<int> _favoriteIds = {};
  final Set<int> _joinedIds = {};

  int _selectedTabIndex = 0; // 0: Explore, 1: Favorites, 2: My Events
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isFavorite(int eventId) => _favoriteIds.contains(eventId);
  bool _isJoined(int eventId) => _joinedIds.contains(eventId);

  void _toggleFavorite(int eventId) {
    setState(() {
      if (_favoriteIds.contains(eventId)) {
        _favoriteIds.remove(eventId);
      } else {
        _favoriteIds.add(eventId);
      }
    });
  }

  void _clearSearchAndFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'All';
    });
  }

  String _formatDateTime(DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} • $hour:$minute';
  }

  // Handles both Join and Cancel participation with confirmation dialogs
  Future<void> _handleJoinOrCancel(BuildContext dialogContext, Event event) async {
    final bool alreadyJoined = _joinedIds.contains(event.id);

    if (!alreadyJoined) {
      // Prevent joining if full
      if (event.availablePlaces <= 0) {
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          const SnackBar(content: Text('This event is already full.')),
        );
        return;
      }

      // Join confirmation dialog showing title, date/time and venue with Yes and No
      final bool? confirmed = await showDialog<bool>(
        context: dialogContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Participation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Would you like to join this event?'),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text('Date & Time: ${_formatDateTime(event.date)}'),
              const SizedBox(height: 4),
              Text('Venue: ${event.venue}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Guard against duplicate join or decreasing capacity twice
        if (!_joinedIds.contains(event.id) && event.availablePlaces > 0) {
          setState(() {
            _joinedIds.add(event.id);
            event.availablePlaces -= 1;
          });
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Successfully joined "${event.title}"!'),
                  backgroundColor: Colors.green.shade700,
                ),
              );
          }
        }
      }
    } else {
      // Cancel participation confirmation dialog
      final bool? confirmedCancel = await showDialog<bool>(
        context: dialogContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Cancel Participation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel your participation?'),
              const SizedBox(height: 12),
              Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text('Date & Time: ${_formatDateTime(event.date)}'),
              const SizedBox(height: 4),
              Text('Venue: ${event.venue}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirmedCancel == true) {
        if (_joinedIds.contains(event.id)) {
          setState(() {
            _joinedIds.remove(event.id);
            if (event.availablePlaces < event.capacity) {
              event.availablePlaces += 1;
            }
          });
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Cancelled participation for "${event.title}".'),
                  backgroundColor: Colors.orange.shade800,
                ),
              );
          }
        }
      }
    }
  }

  List<Event> get _filteredEvents {
    final String normalizedQuery = _searchQuery.trim().toLowerCase();

    return _events.where((event) {
      // 1. View filter (Explore / Favorites / My Events)
      if (_selectedTabIndex == 1 && !_favoriteIds.contains(event.id)) {
        return false;
      }
      if (_selectedTabIndex == 2 && !_joinedIds.contains(event.id)) {
        return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'All' && event.category != _selectedCategory) {
        return false;
      }

      // 3. Title search filter (ignores letter case and surrounding spaces)
      if (normalizedQuery.isNotEmpty &&
          !event.title.toLowerCase().contains(normalizedQuery)) {
        return false;
      }

      return true;
    }).toList();
  }

  String get _currentTitle {
    switch (_selectedTabIndex) {
      case 1:
        return 'Favorite Events';
      case 2:
        return 'My Joined Events';
      default:
        return 'Explore Campus Events';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Event> matchingEvents = _filteredEvents;
    final bool hasActiveSearchOrFilter =
        _searchQuery.trim().isNotEmpty || _selectedCategory != 'All';

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Chip(
                avatar: const Icon(Icons.event_available, size: 16),
                label: Text(
                  'Joined: ${_joinedIds.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Category Filter Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search events by title...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips (All + categories)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: eventCategories.map((category) {
                      final bool isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),

                // Matching Events Count & Total Joined Events Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Matching events: ${matchingEvents.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (hasActiveSearchOrFilter)
                      TextButton.icon(
                        onPressed: _clearSearchAndFilters,
                        icon: const Icon(Icons.filter_alt_off, size: 16),
                        label: const Text('Clear filters'),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Event List or Empty State
          Expanded(
            child: matchingEvents.isEmpty
                ? _buildEmptyState(hasActiveSearchOrFilter)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: matchingEvents.length,
                    itemBuilder: (context, index) {
                      final Event event = matchingEvents[index];
                      return EventCard(
                        event: event,
                        isFavorite: _isFavorite(event.id),
                        isJoined: _isJoined(event.id),
                        onFavoriteToggle: () => _toggleFavorite(event.id),
                        onJoinOrCancel: () => _handleJoinOrCancel(context, event),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(
                                event: event,
                                isFavorite: _isFavorite,
                                isJoined: _isJoined,
                                onToggleFavorite: _toggleFavorite,
                                onJoinOrCancel: _handleJoinOrCancel,
                              ),
                            ),
                          );
                          // Refresh parent screen state when returning from details
                          setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _favoriteIds.isNotEmpty ? Icons.favorite : Icons.favorite_border,
            ),
            label: 'Favorites (${_favoriteIds.length})',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.event_available),
            label: 'My Events (${_joinedIds.length})',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasActiveSearchOrFilter) {
    String message;
    IconData icon;

    if (_selectedTabIndex == 1 && _favoriteIds.isEmpty) {
      icon = Icons.favorite_border;
      message = 'You have no favorite events yet.\nTap the heart icon on any event to save it here.';
    } else if (_selectedTabIndex == 2 && _joinedIds.isEmpty) {
      icon = Icons.event_busy;
      message = 'You have not joined any events yet.\nOpen an event to join and manage your participation.';
    } else {
      icon = Icons.search_off;
      message = 'No events match your current search or category filter.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            if (hasActiveSearchOrFilter) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearSearchAndFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search & Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
