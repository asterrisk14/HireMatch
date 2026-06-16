import 'package:flutter/material.dart';
import '../services/saved_jobs_service.dart';

class FavouritesProvider extends ChangeNotifier {
  final SavedJobsService _service = SavedJobsService();

  List<FavouriteItem> items = [];
  Map<int, int> _favouriteIdByJobPost = {}; // jobPostId -> favouriteId
  bool loaded = false;

  Future<void> load(int candidateId) async {
    items = await _service.getFavourites(candidateId);
    _favouriteIdByJobPost = {for (final f in items) f.jobPostId: f.favouriteId};
    loaded = true;
    notifyListeners();
  }

  bool isFavourite(int jobPostId) => _favouriteIdByJobPost.containsKey(jobPostId);

  Future<void> toggle(int candidateId, int jobPostId) async {
    if (_favouriteIdByJobPost.containsKey(jobPostId)) {
      await _service.removeFavourite(_favouriteIdByJobPost[jobPostId]!);
    } else {
      await _service.addFavourite(candidateId, jobPostId);
    }
    await load(candidateId);
  }
}