import '../models/college.dart';

/// Contract for fetching colleges dataset from Supabase.
abstract class CollegeRepository {
  /// Fetches the list of all controlled colleges.
  Future<List<College>> getColleges();

  /// Search colleges by name or code query.
  Future<List<College>> searchColleges(String query);
}
