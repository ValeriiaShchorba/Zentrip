import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/language/language_provider.dart';
import '../models/place.dart';
import '../db/database_helper.dart';
import '../core/theme/app_colors.dart';
import 'city_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Zentrip",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 26,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              context.read<LanguageProvider>().changeLanguage(
                language == 'TR' ? 'EN' : 'TR',
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                hintText: language == 'TR'
                    ? "Ülke ara..."
                    : "Search country...",
                icon: const Icon(Icons.search, color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              language == 'TR'
                  ? "Hangi ülkeye gidiyoruz?"
                  : "Where are we going?",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Place>>(
              future: DatabaseHelper.instance.getUniqueCountries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) return const SizedBox();
                final countries = snapshot.data!
                    .where(
                      (place) =>
                          place.country.toLowerCase().contains(_searchQuery),
                    )
                    .toList();
                if (countries.isEmpty) {
                  return Center(
                    child: Text(
                      language == 'TR'
                          ? "Ülke bulunamadı."
                          : "Country not found.",
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final place = countries[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CityScreen(countryName: place.country),
                        ),
                      ),
                      child: Container(
                        height: 160,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(place.imageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 0.3),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          place.country.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
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
