import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import '../models/place.dart';
import '../db/database_helper.dart';
import '../core/language/language_provider.dart';
import '../core/theme/app_colors.dart';
import '../widgets/glass_back_button.dart';
import '../widgets/action_button.dart';

class DetailScreen extends StatefulWidget {
  final Place place;
  const DetailScreen({super.key, required this.place});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Place currentPlace;
  int _currentImageIndex = 0;
  late List<String> galleryImages;
  final GoogleTranslator translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    currentPlace = widget.place;
    if (currentPlace.imageUrl.contains(',')) {
      galleryImages = currentPlace.imageUrl.split(',');
    } else {
      galleryImages = [currentPlace.imageUrl];
    }
  }

  Future<String> _getTranslatedDescription(String text, String langCode) async {
    if (langCode == 'TR') return text;
    try {
      String targetLang = langCode == 'UA' ? 'uk' : 'en';
      var translation = await translator.translate(text, to: targetLang);
      return translation.text;
    } catch (e) {
      return text;
    }
  }

  Future<void> _openMap() async {
    final query = "${currentPlace.title}, ${currentPlace.city}";

    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}",
    );

    try {
      if (!await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Harita açılırken hata oluştu: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final updated = currentPlace.copyWith(
      isFavorite: currentPlace.isFavorite == 1 ? 0 : 1,
    );
    await DatabaseHelper.instance.updatePlace(updated);
    setState(() => currentPlace = updated);
  }

  Future<void> _toggleVisited() async {
    final updated = currentPlace.copyWith(
      isVisited: currentPlace.isVisited == 1 ? 0 : 1,
    );
    await DatabaseHelper.instance.updatePlace(updated);
    setState(() => currentPlace = updated);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().currentLanguage;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _openMap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.map_outlined),
          label: Text(
            language == 'TR'
                ? 'Haritada Gör'
                : (language == 'EN' ? 'View on Map' : 'Показати на мапі'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: galleryImages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentImageIndex = index),
                  itemBuilder: (context, index) {
                    return Image.network(
                      galleryImages[index],
                      fit: BoxFit.cover,

                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppColors.primary,
                          ),
                        );
                      },

                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Resim Yüklenemedi",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 90,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      galleryImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GlassBackButton(onTap: () => Navigator.pop(context)),
              ),
            ),
          ),
          Positioned.fill(
            top: size.height * 0.38,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            currentPlace.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.black,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            currentPlace.category,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          currentPlace.city,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: ActionButton(
                            label: language == 'TR' ? "Favori" : "Favorite",
                            icon: currentPlace.isFavorite == 1
                                ? Icons.favorite
                                : Icons.favorite_border,
                            isActive: currentPlace.isFavorite == 1,
                            activeColor: AppColors.red,
                            onTap: _toggleFavorite,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ActionButton(
                            label: language == 'TR' ? "Gidildi" : "Visited",
                            icon: currentPlace.isVisited == 1
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            isActive: currentPlace.isVisited == 1,
                            activeColor: AppColors.primary,
                            onTap: _toggleVisited,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      language == 'TR' ? "Hakkında" : "About",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String>(
                      future: _getTranslatedDescription(
                        currentPlace.description,
                        language,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Text(
                          snapshot.data ?? currentPlace.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey[800],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
