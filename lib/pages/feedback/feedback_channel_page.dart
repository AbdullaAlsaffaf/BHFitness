import 'package:bhfit/main.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackChannelPage extends StatefulWidget {
  const FeedbackChannelPage({super.key, required this.planid});

  final String planid;

  @override
  State<FeedbackChannelPage> createState() => _FeedbackChannelPageState();
}

class _FeedbackChannelPageState extends State<FeedbackChannelPage> {
  bool _isLoading = true;
  bool _trainersLoaded = true;

  late String _userId;
  // late final dynamic _plan;
  late final dynamic _trainers;
  late final dynamic _messageStream;
  dynamic _channel;

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _getPlan();
    _getUserId();
    _getTrainers();
    _getChannel().then((_) {
      _buildMessageStream();
    });
  }

  @override
  void dispose() {
    // _messageStream.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planid),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _messageStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messages = snapshot.data!;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              bool fromUser = true;
                              if (messages[index]['user_id'] != _userId) {
                                fromUser = false;
                              }
                              return BubbleSpecialOne(
                                text: messages[index]['text'],
                                isSender: fromUser,
                                color: fromUser
                                    ? Colors.blue[600]!
                                    : Colors.grey[300]!,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: fromUser ? Colors.white : Colors.black,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                        suffixIcon: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(Icons.send),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<String?> openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(
            child: Text('Choose a Trainer'),
          ),
          content: Container(
            child: !_trainersLoaded
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _trainers.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          context.pop(_trainers[index]['id']);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                            color: Colors.black,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                _trainers[index]['first_name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      );

  Future<void> _getUserId() async {
    _userId = supabase.auth.currentSession!.user.id;
  }

  // Future<void> _getPlan() async {
  //   _plan = await supabase
  //       .from('plans')
  //       .select()
  //       .match({'id': widget.planid}).single();
  // }

  Future<void> _getTrainers() async {
    debugPrint('here trainers');
    _trainers = await supabase.from('users').select().match({'role_id': 3});
    debugPrint('here trainers again');
    debugPrint(_trainers[0]['first_name']);
    setState(() {
      _trainersLoaded = true;
    });
  }

  Future<void> _getChannel() async {
    try {
      _channel = await supabase
          .from('feedback_channels')
          .select()
          .match({'plan_id': widget.planid}).single();
    } on PostgrestException catch (error) {
      debugPrint(error.message);
    }

    if (_channel == null) {
      debugPrint('here 1');
      final trainerId = await openDialog();

      if (trainerId == null) {
        if (mounted) {
          context.pop();
        }
      }

      _channel = await supabase
          .from('feedback_channels')
          .insert({
            'plan_id': widget.planid,
            'member_id': _userId,
            'trainer_id': trainerId
          })
          .select()
          .single();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _buildMessageStream() {
    _messageStream = supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('channel_id', _channel['id'])
        .order('created_at', ascending: true);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text;
    _messageController.clear();
    if (text.trim() != '') {
      await supabase.from('messages').insert(
          {'text': text, 'user_id': _userId, 'channel_id': _channel['id']});
    }
  }
}
