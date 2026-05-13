import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'dart:convert';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth State
  String? get currentUserId => _prefs?.getString('currentUserId');
  Future<void> setCurrentUserId(String? id) async {
    if (id == null) {
      await _prefs?.remove('currentUserId');
    } else {
      await _prefs?.setString('currentUserId', id);
    }
  }

  User? get currentUser {
    final id = currentUserId;
    if (id == null) return null;
    final users = getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // Users
  List<User> getUsers() {
    final strList = _prefs?.getStringList('users') ?? [];
    return strList.map((str) => User.fromJson(str)).toList();
  }

  Future<void> saveUser(User user) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs?.setStringList('users', users.map((u) => u.toJson()).toList());
  }

  // Jobs
  List<Job> getJobs() {
    final strList = _prefs?.getStringList('jobs') ?? [];
    return strList.map((str) => Job.fromJson(str)).toList();
  }

  Future<void> saveJob(Job job) async {
    final jobs = getJobs();
    final index = jobs.indexWhere((j) => j.id == job.id);
    if (index >= 0) {
      jobs[index] = job;
    } else {
      jobs.add(job);
    }
    await _prefs?.setStringList('jobs', jobs.map((j) => j.toJson()).toList());
  }

  // Applications
  List<JobApplication> getApplications() {
    final strList = _prefs?.getStringList('applications') ?? [];
    return strList.map((str) => JobApplication.fromJson(str)).toList();
  }

  Future<void> saveApplication(JobApplication app) async {
    final apps = getApplications();
    final index = apps.indexWhere((a) => a.id == app.id);
    if (index >= 0) {
      apps[index] = app;
    } else {
      apps.add(app);
    }
    await _prefs?.setStringList('applications', apps.map((a) => a.toJson()).toList());
  }

  // Messages
  List<ChatMessage> getMessages(String applicationId) {
    final strList = _prefs?.getStringList('messages') ?? [];
    final all = strList.map((str) => ChatMessage.fromJson(str)).toList();
    final filtered = all.where((m) => m.applicationId == applicationId).toList();
    filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return filtered;
  }

  Future<void> saveMessage(ChatMessage msg) async {
    final strList = _prefs?.getStringList('messages') ?? [];
    final all = strList.map((str) => ChatMessage.fromJson(str)).toList();
    all.add(msg);
    await _prefs?.setStringList('messages', all.map((m) => m.toJson()).toList());
  }

  // Utils
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
