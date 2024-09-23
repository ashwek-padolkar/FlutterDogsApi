import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../providers/pagination_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchData(ref.read(paginationProvider.notifier).getCurrentPage());
  }

  void fetchData(int page) async {
    setState(() {
      isLoading = true;
    });

    String apiKey = ConfigureKey.apiKey;
    String url = 'https://api.thedogapi.com/v1/images/search?size=med&mime_types=jpg&format=json&has_breeds=true&order=RANDOM&page=$page&limit=10';

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'x-api-key': apiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final fetchedData = List<Map<String, dynamic>>.from(response.data);
        ref.read(paginationProvider.notifier).setData(page, fetchedData);
      }
    } catch (error) {
      print("Error: $error");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(paginationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.account_tree_outlined, 
                  size: 38,
                ),
                label: Text(
                  'Dog Breeds',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.goNamed("/carousel");
                },
                child: Text("Carousel"),
              ),
            ],
          ),
        )
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.789,
              height: 200,
              child: Skeletonizer(
                enabled: isLoading,
                child: isLoading
                    ? Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(15),
                          1: FlexColumnWidth(20),
                          2: FlexColumnWidth(10),
                          3: FlexColumnWidth(10),
                          4: FlexColumnWidth(30),
                          5: FlexColumnWidth(15),
                        },
                        children: List.generate(
                          10,
                          (index) => TableRow(
                            children: List.generate(
                              6,
                              (columnIndex) => Container(
                                height: 20,
                                color: Colors.grey[300],
                                margin: EdgeInsets.all(4.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Table(
                        border: TableBorder.all(),
                        columnWidths: const {
                          0: FlexColumnWidth(15),
                          1: FlexColumnWidth(20),
                          2: FlexColumnWidth(10),
                          3: FlexColumnWidth(10),
                          4: FlexColumnWidth(30),
                          5: FlexColumnWidth(15),
                        },
                        children: [
                          const TableRow(
                            children: [
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Breed Name',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Bred For',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Breed Group',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Life Span',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Temperament',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Origin',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          ...data.map((dog) {
                            return TableRow(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      dog['breeds'][0]['name'] ?? 'N/A',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      dog['breeds'][0]['bred_for'] ?? 'N/A',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      dog['breeds'][0]['breed_group'] ?? 'N/A',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      dog['breeds'][0]['life_span'] ?? 'N/A',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      dog['breeds'][0]['temperament'] ?? 'N/A',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      dog['breeds'][0]['origin'] ?? 'N/A',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final currentPage = ref.read(paginationProvider.notifier).getCurrentPage();

                  if(currentPage > 1) {
                    ref.read(paginationProvider.notifier).setCurrentPage(currentPage - 1);
                    final cachedData = ref.read(paginationProvider.notifier).getData(currentPage - 1);
                    
                    if (cachedData.isEmpty) {
                      fetchData(currentPage - 1);
                    } else {
                      ref.read(paginationProvider.notifier).setData(currentPage - 1, cachedData);
                    }
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: ref.read(paginationProvider.notifier).getCurrentPage() > 1 ? Colors.black54 : Colors.grey,
                ),
                iconSize: 18,
              ),
              ...List.generate(4, (index) {
                int startPage = ref.read(paginationProvider.notifier).getCurrentPage() <= 2
                    ? 1
                    : ref.read(paginationProvider.notifier).getCurrentPage() - 2;
                int page = startPage + index;
                return TextButton(
                  onPressed: () {
                    final currentPage = ref.read(paginationProvider.notifier).getCurrentPage();

                    if (currentPage != page) {
                      ref.read(paginationProvider.notifier).setCurrentPage(page);
                      final cachedData = ref.read(paginationProvider.notifier).getData(page);

                      if (cachedData.isEmpty) {
                        fetchData(page);
                      } else {
                        ref.read(paginationProvider.notifier).setData(page, cachedData);
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: page == ref.read(paginationProvider.notifier).getCurrentPage()
                        ? const Color(0xFFE1E1E6)
                        : Colors.transparent,
                  ),
                  child: Text("$page"),
                );
              }),
              IconButton(
                onPressed: () {
                  final currentPage = ref.read(paginationProvider.notifier).getCurrentPage();
                  ref.read(paginationProvider.notifier).setCurrentPage(currentPage + 1);
                  final cachedData = ref.read(paginationProvider.notifier).getData(currentPage + 1);
                  
                  if (cachedData.isEmpty) {
                    fetchData(currentPage + 1);
                  } else {
                    ref.read(paginationProvider.notifier).setData(currentPage + 1, cachedData);
                  }
                },
                icon: Icon(Icons.arrow_forward_ios, color: Colors.black54),
                iconSize: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
