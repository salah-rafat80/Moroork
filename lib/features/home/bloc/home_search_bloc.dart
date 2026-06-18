import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../services/home_search_service.dart';
import 'home_search_event_state.dart';

@injectable
class HomeSearchBloc extends Bloc<HomeSearchEvent, HomeSearchState> {
  final HomeSearchService _searchService;

  HomeSearchBloc(this._searchService) : super(HomeSearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<HomeSearchState> emit,
  ) {
    emit(HomeSearchLoading());
    try {
      final results = _searchService.search(event.query);
      emit(HomeSearchSuccess(
        suggestions: results,
        query: event.query,
      ));
    } catch (e) {
      emit(const HomeSearchFailure('حدث خطأ أثناء معالجة البحث.'));
    }
  }
}
