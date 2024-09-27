import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../providers/carousel_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:a_dog_breeds/screens/dog_breed.dart';
import 'package:responsive_framework/responsive_framework.dart';

class CarouselPage extends ConsumerStatefulWidget {
  const CarouselPage({super.key});

  @override
  ConsumerState<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends ConsumerState<CarouselPage> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration.zero, () {
      fetchData();
    });
  }

  void fetchData({bool isLoadMore = false}) async {
    if(!isLoadMore) {
      ref.read(carouselProvider.notifier).setLoading(true);
    }

    String apiKey = ConfigureKey.apiKey;
    String url = 'https://api.thedogapi.com/v1/images/search?size=med&mime_types=jpg&format=json&has_breeds=true&order=RANDOM&page=0&limit=10';

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'x-api-key': apiKey,
          },
        ),
      );

      if(response.statusCode == 200) {
        final fetchedData = List<Map<String, dynamic>>.from(response.data);
        ref.read(carouselProvider.notifier).setData(fetchedData);
      }
    } catch(error) {
      print("Error: $error");
    }

    if(!isLoadMore) {
      ref.read(carouselProvider.notifier).setLoading(false);
    }
  }

  void loadMore() {
    fetchData(isLoadMore: true);
  }

  double translateX = 0.0;
  int index = 0;

  void translateNext() {
    final data = ref.read(carouselProvider);
    setState(() {
      if (index < data.length - 2) {
        index++;
        translateX -= 380;
      }
    });
  }

  void translatePrevious() {
    setState(() {
      if (index > 0) {
        index--;
        translateX += 380;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(carouselProvider);
    final isLoading = ref.watch(carouselProvider.notifier).getIsLoading();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat.yMMMMd().format(now);
    String formattedTime = DateFormat.jm().format(now); 

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SvgPicture.asset("assets/dog4.svg", height: 35, width: 35,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Dog Breeds',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading ? Center(child: SizedBox(child: CircularProgressIndicator(), height: 200, width: 200,))
            :
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.789,
                      height: 630,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10, left: 10.0),
                            child: ResponsiveRowColumn(
                              layout: ResponsiveBreakpoints.of(context).largerThan(TABLET)
                                  ? ResponsiveRowColumnType.ROW
                                  : ResponsiveRowColumnType.COLUMN,
                              rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ResponsiveRowColumnItem(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Dog Breeds',
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Color(0xFF464B64),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Everyday is a dog day',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF727277),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ResponsiveRowColumnItem(
                                  child: Text(
                                    'Last Data fetched at: $formattedTime, $formattedDate',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF727277)),
                                  ),
                                ),
                                ResponsiveRowColumnItem(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_ios),
                                        onPressed: index > 0 ? translatePrevious : null,
                                        iconSize: 24,
                                        padding: EdgeInsets.zero,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 20),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_forward_ios),
                                        onPressed: index < data.length - 2 ? translateNext : null,
                                        iconSize: 24,
                                        padding: EdgeInsets.zero,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: AnimatedSlide(
                                offset: Offset(translateX / (data.length * 380), 0),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Row(
                                  children: data.map((dog) {
                                    final breed = dog['breeds'][0];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                                      child: Container(
                                        width: 360,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(255, 255, 255, 255),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(151, 185, 185, 185),
                                              spreadRadius: 0,
                                              blurRadius: 10,
                                              offset: const Offset(5, 5),
                                            ),
                                          ]
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.vertical(
                                                  top: Radius.circular(10),
                                                ),
                                                child: InkWell(
                                                  onTap: () async {
                                                    var url = Uri.parse(dog['url']);
                                                    if(await canLaunchUrl(url)) {
                                                      await launchUrl(url);
                                                    } else {
                                                      throw 'Could not launch $url';
                                                    }
                                                  },
                                                  child: CachedNetworkImage(
                                                    imageUrl: dog['url'],
                                                    placeholder: (context, url) => const Center(child: SizedBox(child: CircularProgressIndicator(), height: 60, width: 60,)),
                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                    imageBuilder: (context, imageProvider) {
                                                      return Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 4.0, right: 8.0, bottom: 8.0, left: 8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            breed['name'] ?? 'Unknown',
                                                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 70, 70, 70)),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.share, size: 20),
                                                          onPressed: () {
                                                            final breedName = breed['name'] ?? 'N/A';
                                                            final bredFor = breed['bred_for'] ?? 'N/A';
                                                            final breedGroup = breed['breed_group'] ?? 'N/A';
                                                            final lifeSpan = breed['life_span'] ?? 'N/A';
                                                            final temperament = breed['temperament'] ?? 'N/A';
                                                            final imageUrl = dog['url'];
                                                              
                                                            final message = '''
                                                                  Breed Name: $breedName\n
                                                                  image: $imageUrl\n
                                                                  Breed For: $bredFor\n
                                                                  Bred Group: $breedGroup\n
                                                                  Breed Span: $lifeSpan\n
                                                                  Life Temperament: $temperament\n
                                                                      ''';
                                                            Share.share(message);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text('${breed['origin'] ?? '-'}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 122, 122, 122))),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 3.0),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text('${breed['life_span'] ?? '-'}', style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 122, 122, 122))),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 3.0),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text('${breed['temperament'] ?? '-'}', style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 122, 122, 122))),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 3.0),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text('${breed['bred_for'] ?? '-'}', style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 122, 122, 122))),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 10.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => DogBreed(dog)),
                                                  );
                                                },
                                                child: const Text("View more"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: (index == data.length - 2) ? loadMore : null,
                            child: const Text('Load more'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
