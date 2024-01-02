import 'package:bhfit/main.dart';
import 'package:bhfit/pages/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  Stream? _postsStream;

  bool _poster = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _postsStream = supabase
        .from('posts')
        .select('id, title, banner_url')
        .order('created_at', ascending: false)
        .asStream();
    _searchController.addListener(() {
      setState(() {
        String? query = _searchController.text;
        _postsStream = supabase
            .from('posts')
            .select('id, title, banner_url')
            .ilike('title', '%$query%')
            .order('created_at', ascending: false)
            .asStream();
      });
    });
    super.initState();
    _getUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _poster
          ? FloatingActionButton(
              onPressed: () {
                context.push('/post/new').then((_) {
                  setState(() {
                    _postsStream = supabase
                        .from('posts')
                        .select('id, title, banner_url')
                        .order('created_at', ascending: false)
                        .asStream();
                  });
                });
              },
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverAppBar(
              centerTitle: true,
              title: Text('News Feed'),
            )
          ],
          body: Column(
            children: [
              Material(
                elevation: 1,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: CustomSearchBar(controller: _searchController),
                ),
              ),
              Expanded(
                child: StreamBuilder<dynamic>(
                  stream: _postsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final posts = snapshot.data!;

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            int postid = posts[index]['id'];
                            context.push('/post/details/$postid');
                          },
                          child: Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            margin: const EdgeInsetsDirectional.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(30, 43, 43, 43),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      posts[index]['title'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )),
                                ),
                                SizedBox(
                                  height: 150.0,
                                  width: MediaQuery.of(context).size.width,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                    child: Image(
                                      image: posts[index]['banner_url'] != null
                                          ? Image.network(
                                                  posts[index]['banner_url'])
                                              .image
                                          : const AssetImage(
                                              'assets/images/placeholder.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getUser() async {
    try {
      final userId = supabase.auth.currentSession!.user.id;
      final data =
          await supabase.from('users').select().eq('id', userId).single();
      if (data['role_id'] == 3 || data['role_id'] == 4) {
        setState(() {
          _poster = true;
        });
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Something went wrong"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {}
  }
}
