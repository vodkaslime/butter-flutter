import 'package:butter/models/butter.dart';
import 'package:butter/models/comment.dart';
import 'package:butter/models/media_item.dart';
import 'package:butter/models/user.dart';
import 'package:butter/pages/comment_page/comment_page.dart';
import 'package:butter/pages/components/button_style.dart';
import 'package:butter/utils/constants.dart';
import 'package:butter/utils/network.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleButterPage extends StatefulWidget {

  final Butter butter;
  final User? user;
  SingleButterPage(
    this.butter,
    this.user
  );

  @override
  _SingleButterPageState createState() {
    return _SingleButterPageState(butter, user);
  }
}

class _SingleButterPageState extends State<SingleButterPage> {

  Butter butter;
  // Who is using this app
  User? user;
  // Who is the owner of the current butter
  User? butterOwner;
  List<ButterComment> comments = [];

  _SingleButterPageState(this.butter, this.user);

  void updateComments() {
    // Initiate comments data
    String commentsUrl = ButterHttpUtils.generateCommentsByButterIdUrl(butter.butterId.toString());
    ButterHttpUtils.request(commentsUrl).then((res) {
      List<ButterComment> newComments = [];
      for (var comment in res.data) {
        newComments.add(ButterComment.fromMap(comment));
      }
      setState(() {
        comments = newComments;
      });
    });
  }

  void updateButterOwner() {
    String butterOwnerUrl = ButterHttpUtils.generateUserUrl(butter.userId.toString());
    ButterHttpUtils.request(butterOwnerUrl).then((res) {
      setState(() {
        butterOwner = User.fromMap(res.data);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Initiate owner data
    updateButterOwner();
    updateComments();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery. of(context). size. width;
    double height = 0;

    // Define the height of the large image.
    // It should be decided by the highest pic.
    for (var item in butter.mediaItems) {
      double h = width * item.displayHeight / item.displayWidth;
      if (h > height) {
        height = h;
      }
    }

    // If this butter belongs to myself, then don't display the
    // butter button.
    List<Widget> buttonsList = [SingleButterViewButtonsSet(butter, updateComments)];
    if (user != null && user!.userId == butter.userId) {
      buttonsList.add(Divider());
    } else {
      buttonsList.add(
        Container(
          width: double.infinity,
          child: ElevatedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add),
                SizedBox(width: 10),
                Text("MAKE A BUTTER"),
              ],
            ),
            style: ButterButtonStyle.mainThemeButtonStyle(),
            onPressed: () {},
          ),
        )
      );
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Container(

                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UserNameWithBigAvatar(butterOwner)
                  ],
                )
            ),
            Divider(),
            Container(
              height: height,
              child: Swiper(
                itemBuilder: (BuildContext context, int index) {
                  MediaItem mediaItem = butter.mediaItems[index];
                  return Image.network(
                    ButterHttpUtils.generateMediaItemUrl(mediaItem.url),
                    fit: BoxFit.fitWidth,
                  );
                },
                itemCount: butter.mediaItems.length,
                pagination: SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                      color: BACKGROUND_GREY_COLOR,
                      size: 5,
                      activeSize: 7,
                    )
                ),
              ),
            ),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: buttonsList,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    butter.title,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(butter.contentText),
                ],
              ),
            ),
            Divider(),
            CommentsView(comments),
          ],
        ),
      )
    );
  }
}

class UserNameWithBigAvatar extends StatelessWidget {
  final User? user;
  UserNameWithBigAvatar(this.user);

  @override
  Widget build(BuildContext context) {
    List<Widget> rowContents = [];
    if (user != null) {
      String url = ButterHttpUtils.generateAvatarUrl(user!.avatarUrl);
      rowContents = [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.network(url, height: 50, width: 50),
        ),
        SizedBox(width: 10),
        Text(user!.name),
      ];
    }
    return Row(
      children: rowContents,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

// The small buttons under the large single butter gallery:
// comment and like buttons
class SingleButterViewButtonsSet extends StatelessWidget {

  final Butter butter;
  final updateRender;
  SingleButterViewButtonsSet(
    this.butter,
    this.updateRender,
  );

  IconButton getLittleButton(icon, onPressed) {
    return IconButton(
      icon: icon,
      color: BUTTON_GREY_COLOR,
      onPressed: onPressed,
      constraints: BoxConstraints(
        minWidth: 10
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          SizedBox(width: 10),
          getLittleButton(Icon(Icons.chat), () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CommentPage(butter);
            })).then((value) { updateRender(); });
          }),
          SizedBox(width: 10),
          getLittleButton(Icon(Icons.favorite), (){}),
        ],
      ),
    );
  }
}

class CommentsView extends StatelessWidget {

  final List<ButterComment> comments;
  CommentsView(this.comments);

  @override
  Widget build(BuildContext context) {
    List<Widget> commentsViewList = [];
    for (ButterComment comment in comments) {
      commentsViewList.add(CommentUnitView(comment));
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: commentsViewList,
      )
    );
  }
}

// View of each single comment unit,
// With commenter's avatar, name and comment text.
class CommentUnitView extends StatefulWidget {
  final ButterComment comment;
  CommentUnitView(this.comment);

  @override
  _CommentUnitViewState createState() => _CommentUnitViewState(comment);
}

class _CommentUnitViewState extends State<CommentUnitView> {

  ButterComment comment;
  User? user;
  _CommentUnitViewState(this.comment);

  @override
  void initState() {
    super.initState();
    String userUrl = ButterHttpUtils.generateUserUrl(comment.posterUserId.toString());
    ButterHttpUtils.request(userUrl).then((res) {
      setState(() {
        user = User.fromMap(res.data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dt = DateTime.fromMillisecondsSinceEpoch(comment.creationTimestamp * 1000);
    var commentTime = DateFormat("yyyy-MM-dd - kk:mm").format(dt);
    String avatarUrl = ButterHttpUtils.generateAvatarByUserIdUrl(comment.posterUserId.toString());

    List<Widget> rowChildren = [];
    String commentTitle = commentTime;
    if (user != null) {
      rowChildren.add(
        ClipRRect(
          child: Image.network(
            avatarUrl,
            width: 30,
            height: 30,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      );
      commentTitle = user!.name + ": " + commentTime;
    }
    rowChildren.add(SizedBox(width: 10));
    rowChildren.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          commentTitle,
          style: TextStyle(
              fontSize: 10
            ),
          ),
          Text(comment.contentText),
          SizedBox(height: 10),
        ],
      ),
    );

    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowChildren,
      )
    );
  }
}
