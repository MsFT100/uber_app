import 'package:flutter/material.dart';

class AddressSearchDelegate extends SearchDelegate<PlaceSuggestion?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // In a real app, you would make an API call to a geocoding service
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // In a real app, you would show suggestions as the user types
    return ListView();
  }
}

class PlaceSuggestion {
  final String description;
  final double lat;
  final double lng;

  PlaceSuggestion({required this.description, required this.lat, required this.lng});
}
