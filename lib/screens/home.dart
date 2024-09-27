import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../config.dart';
import '../providers/pagination_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();

  bool isLoading = false;

  String _packageAppName = '';
  String _packageVersion = '';
  String _packageName = '';
  bool _showPackageInfo = false;

  @override
  void initState() {
    super.initState();

    initConnectivity();
    getPackageInfo();
    
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    Future.delayed(Duration.zero, () {
      fetchData(ref.read(paginationProvider.notifier).getCurrentPage());
    });
  }

  Future<void> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageAppName = packageInfo.appName;
      _packageVersion = packageInfo.version;
      _packageName = packageInfo.packageName;
    });
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;

    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print('Could not check connectivity status');
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    print('Connectivity changed: $_connectionStatus');
  }

  void fetchData(int page) async {
    // setState(() {
    //   isLoading = true;
    // });

    ref.read(paginationProvider.notifier).setLoading(true);

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

    ref.read(paginationProvider.notifier).setLoading(false);

    // setState(() {
    //   isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(paginationProvider);
    final isLoading = ref.watch(paginationProvider.notifier).getIsLoading();

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Row(
                children: [
                  SvgPicture.asset("assets/dog4.svg", height: 35, width: 35,),
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
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.goNamed("/carousel");
                  },
                  child: Text("Carousel"),
                ),
              ),
            ],
          ),
        )
      ),
      body: Column(
        children: [
          // SizedBox(height: 20),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.789,
              child: Skeletonizer(
                enabled: isLoading,
                child: isLoading
                    ? Table(
                        border: TableBorder(
                          top: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                          bottom: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                          left: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                          right: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                          horizontalInside: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(15),
                          1: FlexColumnWidth(20),
                          2: FlexColumnWidth(10),
                          3: FlexColumnWidth(10),
                          4: FlexColumnWidth(32),
                          5: FlexColumnWidth(13),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Color.fromARGB(255, 240, 245,250)),
                            children: [
                              SizedBox(
                                height: 45,
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
                                height: 45,
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
                                height: 45,
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
                                height: 45,
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
                                height: 45,
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
                                height: 45,
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
                          for(int i=0; i<10; i++)
                            TableRow(
                              children: [
                                Container(
                                  height: 42,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  margin: EdgeInsets.all(4.0),
                                  child: Text(
                                      'Affenpinscher',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                ),
                                Container(
                                  height: 42,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  margin: EdgeInsets.all(4.0),
                                  child: Text(
                                      'Small rodent hunting, lapdog',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                ),
                                Container(
                                  height: 42,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  margin: EdgeInsets.all(4.0),
                                  child: Text(
                                      'Herding',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                ),
                                Container(
                                  height: 42,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  margin: EdgeInsets.all(4.0),
                                  child: Text(
                                      '12 - 16 years',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                ),
                                Container(
                                  height: 42,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  margin: EdgeInsets.all(4.0),
                                  child: Text(
                                      'Tenacious, Keen, Energetic, Responsive, Alert, Intelligent',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                ),
                                Container(
                                  height: 42,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  margin: EdgeInsets.all(4.0),
                                  child: Text(
                                      'Germany, France',
                                      style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700,),
                                    ),
                                ),
                              ]
                            ),
                        ]
                      )
                    : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: 830),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.789,
                            child: Table(
                                border: TableBorder(
                                  top: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                                  bottom: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                                  left: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                                  right: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                                  horizontalInside: BorderSide(width: 1.8, color: Color(0xFFF0F0F0)),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(15),
                                  1: FlexColumnWidth(20),
                                  2: FlexColumnWidth(10),
                                  3: FlexColumnWidth(10),
                                  4: FlexColumnWidth(32),
                                  5: FlexColumnWidth(13),
                                },
                                children: [
                                  TableRow(
                                    decoration: BoxDecoration(color: Color.fromARGB(255, 240, 245, 250)),
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: 45),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Breed Name',
                                                style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: 45),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bred For',
                                                style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: 45),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Breed Group',
                                                style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: 45),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Life Span',
                                                style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: 45),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Temperament',
                                                style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(minHeight: 45),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Origin',
                                                style: TextStyle(color: Color(0xFF232323), fontSize: 12.4, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            
                                  ...data.map((dog) {
                                    return TableRow(
                                      children: [
                                        ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: 50),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dog['breeds'][0]['name'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: 50),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dog['breeds'][0]['bred_for'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: 50),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dog['breeds'][0]['breed_group'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: 50),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dog['breeds'][0]['life_span'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: 50),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dog['breeds'][0]['temperament'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ConstrainedBox(
                                          constraints: BoxConstraints(minHeight: 50),
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dog['breeds'][0]['origin'] ?? 'N/A',
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ],
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
                    ),
              ),
            ),
          ),
          Container(
            height: 90,
            padding: EdgeInsets.only(left: 20),
            child: ResponsiveRowColumn(
              layout: ResponsiveBreakpoints.of(context).largerThan(TABLET)
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
              rowMainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ResponsiveRowColumnItem(
                  child: Container(
                    width: 200,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          iconSize: 24,
                          onPressed: () {
                            setState(() {
                              _showPackageInfo = !_showPackageInfo;
                            });
                          },
                        ),
                        if (_showPackageInfo) 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("App Name: $_packageAppName", style: TextStyle(fontSize: 11)),
                              Text("Package Name: $_packageName", style: TextStyle(fontSize: 11)),
                              Text("Version: $_packageVersion", style: TextStyle(fontSize: 11)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                ResponsiveRowColumnItem(
                  child: Center(
                    child: Container(
                      // color: Colors.red,
                      width: 500,
                      child: Row(
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
                                foregroundColor: page == ref.read(paginationProvider.notifier).getCurrentPage()
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : const Color.fromARGB(255, 122, 122, 122),
                                backgroundColor: page == ref.read(paginationProvider.notifier).getCurrentPage()
                                    ? const Color.fromARGB(255, 218, 218, 218)
                                    : const Color.fromARGB(0, 255, 255, 255),
                                shape: const CircleBorder(),
                              ),
                              child: Text("$page", style: const TextStyle(fontSize: 12),),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: List.generate(
              _connectionStatus.length,
              (index) => Container(
                color: _connectionStatus[index].toString() == "ConnectivityResult.none" ? Color.fromARGB(255, 191, 191, 191) : Color.fromARGB(255, 255, 255, 255),
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    _connectionStatus[index].toString() == "ConnectivityResult.none" ? 'No connection' : '',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
