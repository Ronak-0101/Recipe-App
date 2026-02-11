
import 'package:flutter/foundation.dart';

enum DietFilter { all, veg, nonVeg }

class DietFilterProvider extends ChangeNotifier {
  DietFilter _dietFilter = DietFilter.veg;

  DietFilter get dietFilter => _dietFilter;

  bool get isNonVeg => _dietFilter == DietFilter.nonVeg;

  void toggleDietFilter() {
    _dietFilter = _dietFilter == DietFilter.veg ? DietFilter.nonVeg : DietFilter.veg ;
    notifyListeners();
  }

  void setDietFilter(DietFilter filter) {
    _dietFilter = filter;
    notifyListeners();
  }

  // bool get isFilterEnabled => _dietFilter != DietFilter.all;

  // void setFilter (DietFilter value) {
  //   _dietFilter = value;
  //   notifyListeners();
  // }

  // void setFilterEnabled (bool enabled) {
  //   if (!enabled) {
  //     _dietFilter = DietFilter.all;
  //     notifyListeners();
  //     return;
  //   }

  //   if (_dietFilter == DietFilter.all) {
  //     _dietFilter = DietFilter.veg;
  //     notifyListeners();
  //   }
  // }
}