import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/listing.dart';
import '../../../data/providers/api_exception.dart';
import '../../../data/services/geo_service.dart';
import '../../../data/services/search_service.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_bottom_nav.dart';
import '../constants/search_constants.dart';

/// Opens the search screen already showing results, e.g. "View all" or a
/// banner that targets a search.
class SearchArgs {
  const SearchArgs({this.query, this.type, this.sort, this.title});

  final String? query;
  final String? type;
  final String? sort;

  /// Shown in the field instead of the query, e.g. "Fresh up rooms".
  final String? title;
}

/// A location the search field can suggest, e.g. "Alapuzha".
class SearchSuggestion {
  const SearchSuggestion({required this.name, this.stayCount, this.imageUrl});

  final String name;

  /// Shown as "30+ Stays" when known.
  final int? stayCount;
  final String? imageUrl;
}

/// A circle under "Recent Search".
class RecentSearch {
  const RecentSearch({required this.id, required this.label, this.imageUrl});

  final String id;
  final String label;
  final String? imageUrl;
}

/// What the area under the field is showing.
enum SearchMode { picks, suggestions, results }

/// Search sheet (Page 6) — opened from the home search bar.
class AppSearchController extends GetxController {
  final SearchService _searchService = Get.find<SearchService>();
  final WishlistService _wishlistService = Get.find<WishlistService>();
  final GeoService _geoService = Get.find<GeoService>();

  final textController = TextEditingController();
  final focusNode = FocusNode();

  final query = ''.obs;
  final mode = SearchMode.picks.obs;
  final currentTab = AppBottomNav.explore.obs;

  final suggestions = <SearchSuggestion>[].obs;
  final recent = <RecentSearch>[].obs;
  final mostSearched = Rxn<SearchSuggestion>();

  final results = <Listing>[].obs;
  final resultsTitle = ''.obs;
  final isSearching = false.obs;
  final errorMessage = ''.obs;

  /// Optional filters from "Add dates" / "Add number of people".
  final date = Rxn<DateTime>();
  final pax = RxnInt();

  Timer? _debounce;
  int _suggestionRequest = 0;

  bool get isTyping => mode.value == SearchMode.suggestions;

  @override
  void onInit() {
    super.onInit();
    loadPicks();
    final args = Get.arguments;
    if (args is SearchArgs) {
      final text = args.title ?? args.query ?? '';
      textController.text = text;
      query.value = text;
      _runSearch(query: args.query, type: args.type, sort: args.sort, title: text);
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (mode.value == SearchMode.picks) focusNode.requestFocus();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  /// Recent searches and the most-searched location.
  Future<void> loadPicks() async {
    try {
      final data = await Future.wait([
        _searchService.recent(),
        _searchService.popularLocations(limit: 1),
      ]);
      final recentData = data[0];
      if (recentData is List) {
        recent.assignAll(
          recentData.whereType<Map<String, dynamic>>().map(
                (json) => RecentSearch(
                  id: '${json['id'] ?? ''}',
                  label: '${json['query'] ?? ''}',
                ),
              ).where((item) => item.label.isNotEmpty),
        );
      }
      final popular = data[1];
      if (popular is List && popular.isNotEmpty && popular.first is Map) {
        mostSearched.value =
            SearchSuggestion(name: '${(popular.first as Map)['name'] ?? ''}');
      }
    } on ApiException catch (error) {
      Get.log('Search picks load failed: $error');
    }
  }

  void onQueryChanged(String value) {
    query.value = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      mode.value = SearchMode.picks;
      suggestions.clear();
      return;
    }
    mode.value = SearchMode.suggestions;
    _debounce = Timer(SearchDurations.debounce, () => _suggest(value.trim()));
  }

  Future<void> _suggest(String text) async {
    final request = ++_suggestionRequest;
    try {
      final data = await _searchService.suggestions(text);
      // A slower, older request must not overwrite a newer one.
      if (request != _suggestionRequest) return;
      suggestions.assignAll(
        data is List
            ? data
                .map((item) => item is Map ? '${item['name'] ?? ''}' : '$item')
                .where((name) => name.isNotEmpty)
                .map((name) => SearchSuggestion(name: name))
            : const <SearchSuggestion>[],
      );
    } on ApiException catch (error) {
      Get.log('Suggestions failed: $error');
    }
  }

  void clear() {
    textController.clear();
    onQueryChanged('');
    results.clear();
    errorMessage.value = '';
    focusNode.requestFocus();
  }

  /// Keyboard "search" button.
  void submit(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    _runSearch(query: text, title: text);
  }

  void openSuggestion(SearchSuggestion suggestion) {
    _setText(suggestion.name);
    _runSearch(query: suggestion.name, title: suggestion.name);
  }

  void openRecent(RecentSearch item) {
    _setText(item.label);
    _runSearch(query: item.label, title: item.label);
  }

  Future<void> removeRecent(RecentSearch item) async {
    recent.remove(item);
    try {
      await _searchService.removeRecent(item.id);
    } on ApiException catch (error) {
      Get.log('Remove recent failed: $error');
    }
  }

  /// Fills the field with the suggestion without running the search.
  void fillFrom(SearchSuggestion suggestion) {
    _setText(suggestion.name);
    onQueryChanged(suggestion.name);
  }

  void _setText(String text) {
    textController.text = text;
    textController.selection = TextSelection.collapsed(offset: text.length);
    query.value = text;
  }

  Future<void> openNearby() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      final point = await _geoService.currentLocation();
      await _show(
        SearchStrings.nearby,
        () => _searchService.nearby(lat: point.latitude, lng: point.longitude),
      );
    } on LocationUnavailable catch (error) {
      Get.snackbar(
        SearchStrings.nearby,
        error.message,
        duration: SearchDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openAvailable() => _show(
        SearchStrings.available,
        () => _searchService.available(date: _isoDate(date.value)),
      );

  Future<void> addDates() async {
    final context = Get.context;
    if (context == null) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date.value ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    date.value = picked;
    _rerun();
  }

  Future<void> addPeople() async {
    final context = Get.context;
    if (context == null) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final count in const [1, 2, 4, 6, 10, 20, 30])
              ListTile(
                title: Text(SearchStrings.people(count)),
                trailing: pax.value == count ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(count),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    pax.value = picked;
    _rerun();
  }

  /// Applies a newly chosen date or party size to the results on screen.
  void _rerun() {
    if (mode.value == SearchMode.results && query.value.trim().isNotEmpty) {
      _runSearch(query: query.value.trim(), title: resultsTitle.value);
    }
  }

  Future<void> _runSearch({
    String? query,
    String? type,
    String? sort,
    required String title,
  }) =>
      _show(title, () {
        final params = <String, dynamic>{
          'q': ?query,
          'category': ?type,
          'date': ?_isoDate(date.value),
          'pax': ?pax.value,
          'limit': 40,
        };
        return _searchService.search(params);
      }, afterwards: query == null ? null : loadPicks);

  Future<void> _show(
    String title,
    Future<dynamic> Function() load, {
    Future<void> Function()? afterwards,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _debounce?.cancel();
    mode.value = SearchMode.results;
    resultsTitle.value = title;
    isSearching.value = true;
    errorMessage.value = '';
    results.clear();
    try {
      final data = await load();
      final items = data is Map ? data['items'] : data;
      if (items is List) {
        results.assignAll(
          items.whereType<Map<String, dynamic>>().map(Listing.fromJson),
        );
      }
      // The search just ran is now the newest recent search.
      if (afterwards != null) unawaited(afterwards());
    } on ApiException catch (error) {
      Get.log('Search failed: $error');
      errorMessage.value = error.message;
    } finally {
      isSearching.value = false;
    }
  }

  static String? _isoDate(DateTime? date) => date == null
      ? null
      : '${date.year}-${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

  void openListing(Listing listing) =>
      Get.toNamed(Routes.LISTING_DETAIL, arguments: listing);

  Future<void> toggleWishlist(Listing listing) async {
    final index = results.indexWhere((item) => item.id == listing.id);
    final now = !listing.isWishlisted;
    if (index != -1) results[index] = listing.copyWith(isWishlisted: now);
    try {
      now
          ? await _wishlistService.add(listing.id)
          : await _wishlistService.remove(listing.id);
    } on ApiException catch (error) {
      Get.log('Wishlist toggle failed: $error');
      if (index != -1) results[index] = listing;
    }
  }

  void goBack() => Get.back();

  void startVoiceSearch() => Get.snackbar(
        SearchStrings.pendingTitle,
        SearchStrings.pendingMessage('Voice search'),
        duration: SearchDurations.snackbar,
        snackPosition: SnackPosition.BOTTOM,
      );

  void onTabSelected(int index) {
    switch (index) {
      case AppBottomNav.explore:
        Get.back();
      case AppBottomNav.reservations:
        Get.offNamed(Routes.RESERVATIONS);
      case AppBottomNav.wishlist:
        Get.offNamed(Routes.WISHLIST);
      case AppBottomNav.profile:
        Get.offNamed(Routes.PROFILE);
    }
  }
}
