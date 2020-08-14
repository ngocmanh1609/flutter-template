import 'dart:async';

import 'package:boilerplate/data/local/datasources/post/post_datasource.dart';
import 'package:boilerplate/data/network/apis/non_authenticated_post_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/models/post/post.dart';
import 'package:boilerplate/models/post/post_list.dart';
import 'package:sembast/sembast.dart';

import 'local/constants/db_constants.dart';
import 'network/apis/posts/post_api.dart';

abstract class Repository {
  Future<PostList> getPosts();

  Future<PostList> getNonAuthenticatedPosts();

  Future<List<Post>> findPostById(int id);

  Future<void> changeBrightnessToDark(bool value);

  Future<void> changeLanguage(String value);

  Future<String> get currentLanguage;

  Future<bool> get isDarkMode;
}

class RepositoryImpl extends Repository {
  // data source object
  final PostDataSource _postDataSource;

  // api objects
  final PostApi _postApi;
  final NonAuthenticatedPostApi _nonAuthenticatedPostApi;

  // shared pref object
  final SharedPreferenceHelper _sharedPrefsHelper;

  // constructor
  RepositoryImpl(this._postApi, this._nonAuthenticatedPostApi,
      this._sharedPrefsHelper, this._postDataSource);

  // Post: ---------------------------------------------------------------------
  @override
  Future<PostList> getPosts() async {
    // check to see if posts are present in database, then fetch from database
    // else make a network call to get all posts, store them into database for
    // later use
    // return await _postDataSource.count() > 0
    //     ? _postDataSource
    //         .getPostsFromDb()
    //         .then((postsList) => postsList)
    //         .catchError((error) => throw error)
    //     :
    return await _postApi.getPosts().then((postsList) {
      postsList.posts.forEach((post) {
        _postDataSource.insert(post);
      });

      return postsList;
    }).catchError((error) => throw error);
  }

  @override
  Future<PostList> getNonAuthenticatedPosts() async {
    return await _nonAuthenticatedPostApi
        .getPosts()
        .then((postList) => postList)
        .catchError((error) => throw error);
  }

  @override
  Future<List<Post>> findPostById(int id) {
    //creating filter
    List<Filter> filters = List();

    //check to see if dataLogsType is not null
    if (id != null) {
      Filter dataLogTypeFilter = Filter.equals(DBConstants.FIELD_ID, id);
      filters.add(dataLogTypeFilter);
    }

    //making db call
    return _postDataSource
        .getAllSortedByFilter(filters: filters)
        .then((posts) => posts)
        .catchError((error) => throw error);
  }

  Future<int> insert(Post post) => _postDataSource
      .insert(post)
      .then((id) => id)
      .catchError((error) => throw error);

  Future<int> update(Post post) => _postDataSource
      .update(post)
      .then((id) => id)
      .catchError((error) => throw error);

  Future<int> delete(Post post) => _postDataSource
      .update(post)
      .then((id) => id)
      .catchError((error) => throw error);

  // Theme: --------------------------------------------------------------------
  @override
  Future<void> changeBrightnessToDark(bool value) =>
      _sharedPrefsHelper.changeBrightnessToDark(value);

  @override
  Future<bool> get isDarkMode => _sharedPrefsHelper.isDarkMode;

  // Language: -----------------------------------------------------------------
  @override
  Future<void> changeLanguage(String value) =>
      _sharedPrefsHelper.changeLanguage(value);

  @override
  Future<String> get currentLanguage => _sharedPrefsHelper.currentLanguage;
}