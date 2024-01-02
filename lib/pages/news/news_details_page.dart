import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.id});

  final String id;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isLoading = true;
  late final dynamic _postData;

  @override
  void initState() {
    super.initState();
    _getPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverAppBar(
              centerTitle: true,
              floating: true,
              title: Text('Back'),
            )
          ],
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Image(
                          image: _postData['banner_url'] != null
                              ? Image.network(_postData['banner_url']).image
                              : const AssetImage(
                                  'assets/images/placeholder.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 8.0, right: 8.0, bottom: 10.0),
                        child: Text(
                          _postData['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: Text(
                          _postData['text'],
                          textAlign: TextAlign.justify,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _getPost() async {
    try {
      _postData =
          await supabase.from('posts').select().eq('id', widget.id).single();
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
          content: const Text('Something went wrong'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
