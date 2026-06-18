import 'package:equatable/equatable.dart';
import '../models/search_suggestion_model.dart';

// --- Events ---
abstract class HomeSearchEvent extends Equatable {
  const HomeSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends HomeSearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// --- States ---
abstract class HomeSearchState extends Equatable {
  const HomeSearchState();

  @override
  List<Object?> get props => [];
}

class HomeSearchInitial extends HomeSearchState {}

class HomeSearchLoading extends HomeSearchState {}

class HomeSearchSuccess extends HomeSearchState {
  final List<SearchSuggestion> suggestions;
  final String query;

  const HomeSearchSuccess({
    required this.suggestions,
    required this.query,
  });

  @override
  List<Object?> get props => [suggestions, query];
}

class HomeSearchFailure extends HomeSearchState {
  final String errorMessage;

  const HomeSearchFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
