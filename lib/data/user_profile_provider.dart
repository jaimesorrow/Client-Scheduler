import 'package:flutter/material.dart';
import 'user_profile.dart';
import 'user_repository.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserRepository _repo;

  UserProfileProvider({UserRepository? repo})
      : _repo = repo ?? UserRepository();

  UserProfile? profile;
  bool isLoading = false;

  Future<void> load(String uid) async {
    isLoading = true;
    notifyListeners();
    profile = await _repo.getUserProfile(uid);
    isLoading = false;
    notifyListeners();
  }
}
