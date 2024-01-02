import 'dart:io';

import 'package:bhfit/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostNews extends StatefulWidget {
  const PostNews({super.key});

  @override
  State<PostNews> createState() => _PostNewsState();
}

class _PostNewsState extends State<PostNews> {
  bool _isLoading = false;

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _headlineController = TextEditingController();

  XFile? _image;

  @override
  void dispose() {
    _textController.dispose();
    _headlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('New Post'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: _image == null
                          ? Center(
                              child: ElevatedButton(
                                  onPressed: _getImage,
                                  child: const Text('Select Image')),
                            )
                          : GestureDetector(
                              onTap: _getImage,
                              child: Image.file(
                                File(_image!.path),
                              ),
                            ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: _headlineController,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          hintText: 'Headline',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Post Text',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                      ),
                    ),
                    IntrinsicWidth(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _image = null;
                                    });
                                  },
                                  child: const Text('Clear Image')),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: ElevatedButton(
                                  onPressed: _post, child: const Text('Post')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _getImage() async {
    final image = (await ImagePicker().pickImage(source: ImageSource.gallery));
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> _post() async {
    setState(() {
      _isLoading = true;
    });

    if (_textController.text.isEmpty ||
        _textController.text.trim() == '' ||
        _headlineController.text.isEmpty ||
        _headlineController.text.trim() == '') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
              'Please write in the required fields: headline & text'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final headline = _headlineController.text;
    final text = _textController.text;
    final userId = supabase.auth.currentSession!.user.id;

    // storage handling
    if (_image != null) {
      final bytes = await _image!.readAsBytes();
      final fileExt = _image!.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      await supabase.storage.from('banners').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(contentType: _image!.mimeType),
          );

      final imageUrlResponse = await supabase.storage
          .from('banners')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);

      await supabase.from('posts').insert({
        'title': headline,
        'text': text,
        'banner_url': imageUrlResponse,
        'author_id': userId
      });
    } else {
      await supabase
          .from('posts')
          .insert({'title': headline, 'text': text, 'author_id': userId});
    }
    if (mounted) {
      context.pop();
    }
  }
}
