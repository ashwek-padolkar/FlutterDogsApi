import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../providers/carousel_provider.dart';

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
    final data = ref.watch(carouselProvider);
    setState(() {
      if (index < data.length - 2) {
        index++;
        translateX -= 420;
      }
    });
  }

  void translatePrevious() {
    setState(() {
      if (index > 0) {
        index--;
        translateX += 420;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(carouselProvider);
    final isLoading = ref.watch(carouselProvider.notifier).getIsLoading();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.account_tree_outlined, 
                size: 38,
              ),
              label: Text(
                "Dog Breeds", 
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ) 
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.789,
                height: 600,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dog breeds',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Every day is a Dog day',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios),
                                onPressed: translatePrevious,
                                iconSize: 24,
                                padding: EdgeInsets.zero,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 20),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: translateNext,
                                iconSize: 24,
                                padding: EdgeInsets.zero,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Transform.translate(
                          offset: Offset(translateX, 0),
                          child: Row(
                            children: data.map((dog) {
                              final breed = dog['breeds'][0];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Container(
                                  width: 400,
                                  color: Colors.grey[300],
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: CachedNetworkImage(
                                            imageUrl: dog['url'],
                                            placeholder: (context, url) => const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) => const Icon(Icons.error),
                                            cacheManager: CachedNetworkImageProvider.defaultCacheManager,
                                            imageBuilder: (context, imageProvider) {
                                              return Image(image: imageProvider);
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                breed['name'] ?? 'N/A',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'Bred for: ${breed['bred_for'] ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'Breed Group: ${breed['breed_group'] ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'Life Span: ${breed['life_span'] ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                'Temperament: ${breed['temperament'] ?? 'N/A'}',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        onPressed: (index == data.length - 2) ? loadMore : null,
                        child: const Text('Load more'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
