import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  final _postsStream =
      supabase.from('posts').select('id, title, banner_url').asStream();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text('News Feed'),
          ),
        ),
        body: StreamBuilder<dynamic>(
          stream: _postsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final posts = snapshot.data!;

            if (posts[5]['banner_url'] != null) {
              debugPrint(posts[5]['banner_url']);
            }

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    int postid = posts[index]['id'];
                    context.push('/details/$postid');
                  },
                  child: Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
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
                                  ? Image.network(posts[index]['banner_url'])
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
    );
  }
}
