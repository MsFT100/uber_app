import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerView extends StatefulWidget {
  const BannerView({super.key});

  @override
  State<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  int activeIndex = 0;

  final List<String> bannerImages = [
  'https://firebasestorage.googleapis.com/v0/b/buricode-6e54c.firebasestorage.app/o/Banners%2F1.png?alt=media&token=5326135a-908e-4dd0-8b22-78e2a895e0a8',
  'https://firebasestorage.googleapis.com/v0/b/buricode-6e54c.firebasestorage.app/o/Banners%2F2.png?alt=media&token=e781fc06-64d6-48a0-ad60-bd52ccb68270',
  
];


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 130,
          width: MediaQuery.of(context).size.width,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: false,
              viewportFraction: 1,
              disableCenter: true,
              autoPlayInterval: const Duration(seconds: 7),
              onPageChanged: (index, reason) {
                setState(() {
                  activeIndex = index;
                });
              },
            ),
            itemCount: bannerImages.length,
            itemBuilder: (context, index, _) {
              return InkWell(
                onTap: () {
                  // Handle the banner tap, like opening a link
                  debugPrint("Banner $index clicked");
                  // You can navigate to another screen or show something
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      bannerImages[index],
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/image/placeholder.png', fit: BoxFit.cover);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 5,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: bannerImages.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Container(
                    height: 5,
                    width: index == activeIndex ? 10 : 5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Padding(padding: EdgeInsets.only(right: 8));
              },
            ),
          ),
        ),
      ],
    );
  }
}
