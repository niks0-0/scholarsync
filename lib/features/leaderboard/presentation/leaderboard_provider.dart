import 'package:flutter/material.dart';
import '../domain/models/leaderboard_models.dart';
import '../data/repositories/leaderboard_repository.dart';

class LeaderboardProvider extends ChangeNotifier {
  LeaderboardProvider({LeaderboardRepository? repository})
      : _repository = repository ?? SupabaseLeaderboardRepository() {
    _initDefaults();
  }

  void _initDefaults() {
    _entries = const [
      LeaderboardEntry(
        id: 'u1',
        userId: 'uid_1',
        displayName: 'Aarav Sharma',
        score: 3840,
        rank: 1,
        previousRank: 1,
        badgeTitle: 'Legend',
        badgeTier: BadgeTier.legend,
        collegeName: 'MIT Engineering',
        departmentName: 'Computer Science',
        semester: 6,
        streakDays: 45,
      ),
      LeaderboardEntry(
        id: 'u2',
        userId: 'uid_2',
        displayName: 'Ananya Iyer',
        score: 3410,
        rank: 2,
        previousRank: 3,
        badgeTitle: 'Diamond Scholar',
        badgeTier: BadgeTier.diamond,
        collegeName: 'MIT Engineering',
        departmentName: 'Information Technology',
        semester: 4,
        streakDays: 32,
      ),
      LeaderboardEntry(
        id: 'u3',
        userId: 'uid_3',
        displayName: 'Rohan Verma',
        score: 2980,
        rank: 3,
        previousRank: 2,
        badgeTitle: 'Platinum Scholar',
        badgeTier: BadgeTier.platinum,
        collegeName: 'National Institute',
        departmentName: 'Electronics',
        semester: 4,
        streakDays: 28,
      ),
      LeaderboardEntry(
        id: 'u_curr',
        userId: 'my_uid',
        displayName: 'You (Scholar)',
        score: 1850,
        rank: 4,
        previousRank: 6,
        badgeTitle: 'Gold Scholar',
        badgeTier: BadgeTier.gold,
        collegeName: 'MIT Engineering',
        departmentName: 'Computer Science',
        semester: 4,
        streakDays: 14,
        isCurrentUser: true,
      ),
    ];
    _currentUserEntry = _entries[3];
  }

  final LeaderboardRepository _repository;

  LeaderboardType _selectedType = LeaderboardType.academic;
  TimeframeFilter _selectedTimeframe = TimeframeFilter.weekly;
  LeaderboardScope _selectedScope = LeaderboardScope.global;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardEntry> _entries = [];
  LeaderboardEntry? _currentUserEntry;
  List<BadgeItem> _userBadges = [];

  // Getters
  LeaderboardType get selectedType => _selectedType;
  TimeframeFilter get selectedTimeframe => _selectedTimeframe;
  LeaderboardScope get selectedScope => _selectedScope;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LeaderboardEntry> get entries => _entries;
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  List<BadgeItem> get userBadges => _userBadges;

  List<LeaderboardEntry> get filteredEntries {
    if (_searchQuery.trim().isEmpty) return _entries;
    final q = _searchQuery.toLowerCase();
    return _entries.where((e) {
      return e.displayName.toLowerCase().contains(q) ||
          e.departmentName.toLowerCase().contains(q) ||
          e.collegeName.toLowerCase().contains(q);
    }).toList();
  }

  List<LeaderboardEntry> get podiumEntries {
    final list = filteredEntries;
    if (list.length < 3) return list;
    return list.sublist(0, 3);
  }

  List<LeaderboardEntry> get restOfEntries {
    final list = filteredEntries;
    if (list.length <= 3) return [];
    return list.sublist(3);
  }

  Future<void> loadLeaderboard({
    String? currentUid,
    String? collegeId,
    String? departmentId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.getLeaderboard(
        type: _selectedType,
        timeframe: _selectedTimeframe,
        scope: _selectedScope,
        collegeId: collegeId,
        departmentId: departmentId,
        currentUid: currentUid,
      );
      _entries = results;

      if (currentUid != null) {
        _currentUserEntry = await _repository.getUserRank(
          uid: currentUid,
          type: _selectedType,
        );
        _userBadges = await _repository.getUserBadges(currentUid);
      }
    } catch (e) {
      _errorMessage = 'Failed to load leaderboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setType(LeaderboardType type, {String? currentUid}) {
    if (_selectedType == type) return;
    _selectedType = type;
    loadLeaderboard(currentUid: currentUid);
  }

  void setTimeframe(TimeframeFilter timeframe, {String? currentUid}) {
    if (_selectedTimeframe == timeframe) return;
    _selectedTimeframe = timeframe;
    loadLeaderboard(currentUid: currentUid);
  }

  void setScope(LeaderboardScope scope, {String? currentUid}) {
    if (_selectedScope == scope) return;
    _selectedScope = scope;
    loadLeaderboard(currentUid: currentUid);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
