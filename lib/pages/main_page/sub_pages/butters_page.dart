import 'package:butter/common/global.dart';
import 'package:butter/models/butter.dart';
import 'package:butter/models/user.dart';
import 'package:butter/pages/components/butter_tile_view.dart';
import 'package:butter/utils/constants.dart';
import 'package:butter/utils/network.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ButtersPage extends StatefulWidget {

  final ScrollController scrollController;
  ButtersPage(
    this.scrollController,
  );

  @override
  _ButtersPageState createState() {
    return _ButtersPageState(scrollController);
  }
}

class _ButtersPageState extends State<ButtersPage> {
  List<Butter> butters = [];

  final ScrollController scrollController;
  final User? user = Global.user;
  _ButtersPageState(
    this.scrollController,
  );


  @override
  void initState() {
    super.initState();
    String url = ButterHttpUtils.generateButtersByAllUrl("");
    ButterHttpUtils.request(
      url,
      headers: ButterHttpUtils.getJwtHeader(),
    ).then((res) {
      final data = res.data;
      List<Butter> buttersUpdated = [];
      for (var map in data) {
        buttersUpdated.add(Butter.fromMap(map));
      }
      setState(() {
        butters = buttersUpdated;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BACKGROUND_GREY_COLOR,
      child: StaggeredGridView.countBuilder(
        controller: scrollController,
        crossAxisCount: 2,
        itemCount: butters.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: ButterTileView(butters[index], user)
          );
        },
        staggeredTileBuilder: (int index) {
          var currButter = butters[index];
          var mediaItem = currButter.mediaItems[0];
          double height = 1.0 * mediaItem.displayHeight / mediaItem.displayWidth;
          return StaggeredTile.count(1, height + 0.3);
        },
        crossAxisSpacing: 5,
      )
    );
  }
}