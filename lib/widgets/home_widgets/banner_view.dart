import 'package:BucoRide/helpers/screen_navigation.dart';
import 'package:BucoRide/screens/home.dart';
import 'package:BucoRide/utils/images.dart';
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
  'https://firebasestorage.googleapis.com/v0/b/buricode-6e54c.firebasestorage.app/o/Banners%2FTaxi%20Business%20Card%20in%20Black%20Yellow%20Illustrative%20_style.png?alt=media&token=0d854dd3-4924-4ae5-aef2-44a3871e6fae',
  'https://firebasestorage.googleapis.com/v0/b/buricode-6e54c.firebasestorage.app/o/Banners%2FTaxi%20Business%20Card%20in%20Black%20Yellow%20Illustrative%20_style.png?alt=media&token=0d854dd3-4924-4ae5-aef2-44a3871e6fae',

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
                  changeScreen(context, HomePage());
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
                        return Image.asset(Images.placeholder, fit: BoxFit.cover);
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
