import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../db/database_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/language/language_provider.dart';
import '../widgets/place_card.dart';
import 'detail_screen.dart';

class PlacesListScreen extends StatefulWidget {
  final String cityName;

  const PlacesListScreen({super.key, required this.cityName});

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  int selectedCategoryIndex = 0;
  String _searchQuery = "";
  final List<String> categories = ["Tümü", "Eğlence", "Yemek", "Müze", "Doğa"];

  String getCategoryName(String key, String lang) {
    if (key == "Tümü") {
      return lang == 'TR' ? "Tümü" : (lang == 'EN' ? "All" : "Всі");
    }
    if (key == "Tarih") {
      return lang == 'TR'
          ? "Eğlence"
          : (lang == 'EN' ? "Entertainment" : "Розваги");
    }
    if (key == "Yemek") {
      return lang == 'TR' ? "Yemek" : (lang == 'EN' ? "Food" : "Їжа");
    }
    if (key == "Müze") {
      return lang == 'TR' ? "Müze" : (lang == 'EN' ? "Museum" : "Музей");
    }
    if (key == "Doğa") {
      return lang == 'TR' ? "Doğa" : (lang == 'EN' ? "Nature" : "Природа");
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.cityName,
          style: const TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppColors.black),
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
                hintText: language == 'TR' ? "Mekan ara..." : "Search place...",
                icon: const Icon(Icons.search, color: AppColors.primary),
              ),
            ),
          ),

          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = selectedCategoryIndex == index;
                final displayName = getCategoryName(
                  categories[index],
                  language,
                );

                return GestureDetector(
                  onTap: () => setState(() => selectedCategoryIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      displayName,
                      style: TextStyle(
                        color: isSelected ? AppColors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Place>>(
              future: DatabaseHelper.instance.getPlacesByCity(widget.cityName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(language == 'TR' ? "Veri yok." : "No data."),
                  );
                }

                final currentCategory = categories[selectedCategoryIndex];

                final filteredPlaces = snapshot.data!.where((place) {
                  bool categoryMatch =
                      (currentCategory == "Tümü") ||
                      (place.category == currentCategory);
                  bool searchMatch = place.title.toLowerCase().contains(
                    _searchQuery,
                  );
                  return categoryMatch && searchMatch;
                }).toList();

                if (filteredPlaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          language == 'TR'
                              ? "Sonuç bulunamadı."
                              : "No results found.",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    return PlaceCard(
                      place: filteredPlaces[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailScreen(place: filteredPlaces[index]),
                          ),
                        );
                      },
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
