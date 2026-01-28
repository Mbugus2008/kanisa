import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../splash.dart';

class appwidgets {
  BoxDecoration backgroundimage(BuildContext context) => const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/kirigiti.jpg"),
          fit: BoxFit.fitHeight,
          opacity: 0.1,
          filterQuality: FilterQuality.high,
        ),
      );
}

class pictureslider extends StatelessWidget {
  const pictureslider({
    super.key,
    required this.imgList,
  });

  final List<String> imgList;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300, // Adjust height as needed
            autoPlay: true,
            enlargeCenterPage: true,
            // Customize indicator appearance (optional)
            viewportFraction: 0.85,
            //aspectRatio: 2.0,
            autoPlayInterval: Duration(seconds: 5),
            //enlargeStrategy: CenterPageEnlargeStrategy.scale,
            onPageChanged: (index, reason) {
              Get.find<ImageSliderController>().changeImage(index);
            },
          ),
          items: imgList
              .map((item) => Container(
                    child: Center(
                      child: ClipPath(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Card(
                          shadowColor: Colors.blue,
                          elevation: 10,
                          child: Image.asset(
                            item,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        Row(
          children: [
            //Card(color: Colors.transparent,  elevation: 10, child: Text('Events',style: TextStyle(fontSize: 20),)),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return Obx(
                  () => GestureDetector(
                    onTap: () => Get.find<ImageSliderController>()
                        .changeImage(entry.key),
                    child: Container(
                      width: 10.0,
                      height: 10.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Get.find<ImageSliderController>()
                                    .currentImageIndex ==
                                entry.key
                            ? Colors.blueAccent
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
