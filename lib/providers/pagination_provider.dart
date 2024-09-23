import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pagination_provider.g.dart';

@riverpod
class Pagination extends _$Pagination {
  final Map<int, List<Map<String, dynamic>>> pageData = {};
  int currentPage = 1;

  @override
  List<Map<String, dynamic>> build() => [];

  void setData(int page, List<Map<String, dynamic>> newData) {
    pageData[page] = newData;
    state = newData;
  }

  List<Map<String, dynamic>> getData(int page) {
    return pageData[page] ?? [];
  }

  void setCurrentPage(int page) {
    currentPage = page;
  }

  int getCurrentPage() => currentPage;
}
