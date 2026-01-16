import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../db/database_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/language/language_provider.dart';
import '../widgets/place_card.dart';
import 'detail_screen.dart';

class VisitedScreen extends StatefulWidget {
  const VisitedScreen({super.key});

  @override
  State<VisitedScreen> createState() => _VisitedScreenState();
}

class _VisitedScreenState extends State<VisitedScreen> {
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          language == 'TR' ? "Gittiğim Yerler" : "Visited Places",
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<Place>>(
        future: DatabaseHelper.instance.getVisitedPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    language == 'TR'
                        ? "Henüz bir yere gitmedin."
                        : "No visits yet.",
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final place = snapshot.data![index];
              return PlaceCard(
                place: place,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(place: place),
                    ),
                  );
                  setState(() {});
                },
              );
            },
          );
        },
      ),
    );
  }
}
