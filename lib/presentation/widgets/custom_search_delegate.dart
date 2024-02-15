import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:flutter_maps/data/models/place_suggestion.dart';
import 'package:flutter_maps/presentation/widgets/place_item.dart';
import 'package:uuid/uuid.dart';

class CustomSearchDelegate extends SearchDelegate {
  List<PlaceSuggestion> places = [];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    getPlacesSuggestions(query, context);
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (BuildContext context, MapsState state) {
        if (state is PlacesLoaded) {
          places = state.places;
          if (places.isNotEmpty) {
            return buildPlacesList();
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  Widget buildPlacesList() {
    return ListView.builder(
      itemCount: places.length,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < places.length && index>0) {
          return InkWell(
            onTap: () {
              close(context, null);
            },
            child: PlaceItem(
              suggestion: places[index],
            ),
          );
        } else {
          // Handle the case where the index is out of bounds
          return const SizedBox(); // Or any other widget or message you want to display
        }
      },
    );
  }

  void getPlacesSuggestions(String query, BuildContext context) {
    final sessionToken = const Uuid().v4();
    BlocProvider.of<MapsCubit>(context)
        .emitPlaceSuggestion(query, sessionToken);
  }
}
