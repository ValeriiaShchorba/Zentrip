import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../db/database_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/language/language_provider.dart';
import 'places_list_screen.dart';

class CityScreen extends StatefulWidget {
  final String countryName;
  const CityScreen({super.key, required this.countryName});
  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.countryName,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: language == 'TR' ? "Şehir ara..." : "Search city...",
                icon: const Icon(Icons.search, color: AppColors.primary),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Place>>(
              future: DatabaseHelper.instance.getCitiesByCountry(
                widget.countryName,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) return const SizedBox();
                final cities = snapshot.data!
                    .where(
                      (place) =>
                          place.city.toLowerCase().contains(_searchQuery),
                    )
                    .toList();
                if (cities.isEmpty) {
                  return Center(
                    child: Text(
                      language == 'TR'
                          ? "Şehir bulunamadı."
                          : "City not found.",
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final place = cities[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlacesListScreen(cityName: place.city),
                        ),
                      ),
                      child: Container(
                        height: 120,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(place.imageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.4),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          place.city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
