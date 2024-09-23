import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'carousel_provider.g.dart';

@riverpod
class Carousel extends _$Carousel {
  final List<Map<String, dynamic>> data = [];
  bool isLoading = false;

  @override
  List<Map<String, dynamic>> build() => data;

  void setData(List<Map<String, dynamic>> newData) {
    data.addAll(newData);
    state = List.from(data);
  }

  bool getIsLoading() => isLoading;

  void setLoading(bool loading) {
    isLoading = loading;
    state = List.from(data);
  }
}
