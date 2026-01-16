import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language/language_provider.dart';
import '../models/place.dart';
import '../db/database_helper.dart';
import '../core/theme/app_colors.dart';
import '../widgets/place_card.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String getTranslatedTitle(String category, String lang) {
    if (category == "Eğlence") {
      return lang == 'TR'
          ? "Eğlence"
          : (lang == 'EN' ? "Entertainment" : "Історія");
    }
    if (category == "Müze") {
      return lang == 'TR' ? "Müze" : (lang == 'EN' ? "Museum" : "Музей");
    }
    if (category == "Doğa") {
      return lang == 'TR' ? "Doğa" : (lang == 'EN' ? "Nature" : "Природа");
    }
    if (category == "Yemek") {
      return lang == 'TR' ? "Yemek" : (lang == 'EN' ? "Food" : "Їжа");
    }
    return category;
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;
    final displayTitle = getTranslatedTitle(widget.categoryName, language);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          displayTitle,
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
      body: FutureBuilder<List<Place>>(
        future: DatabaseHelper.instance.getAllPlaces(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(language == 'TR' ? "Veri yok." : "No data."),
            );
          }

          final categoryPlaces = snapshot.data!
              .where((place) => place.category == widget.categoryName)
              .toList();

          if (categoryPlaces.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text(
                    language == 'TR'
                        ? "Bu kategoride yer bulunamadı."
                        : "No places found.",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: categoryPlaces.length,
            itemBuilder: (context, index) {
              final place = categoryPlaces[index];
              return PlaceCard(
                place: place,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(place: place),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
