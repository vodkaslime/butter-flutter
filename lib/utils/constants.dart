import 'package:flutter/material.dart';

const String PROJECT_NAME = "Butter";

// Main page menu names
const String BUTTERS = "butters";
const String SEARCH = "search";
const String NEW = "new";
const String MINE = "mine";
const String PROFILE = "profile";

const String ROOT_API_URL = "http://192.168.0.101:3000/api/";
const String BUTTERS_ALL_URL = "butters/all";
const String BUTTERS_BY_USER_URL = "butters/userId";
const String AVATAR_BY_USER_ID_URL = "avatars/userId";
const String LOGIN_URL = "users/login";
const String COMMENTS_BY_BUTTER_ID_URL = "comments/butterId";
const String IMAGE_URL = "files";
const String USER_URL = "users";
const String AVATAR_URL = "avatars";
const String COMMENT_URL = "comments";

const int CONNECTION_TIMEOUT = 3000;

const String MAIN_FONT_FAMILY = "VarelaRound";

const Color MAIN_THEME_COLOR = const Color.fromARGB(255, 0xFB, 0x8c, 0);
const Color TOAST_BACKGROUND_COLOR = const Color.fromARGB(200, 0xFB, 0x8c, 0);
const Color BUTTON_GREY_COLOR = const Color.fromARGB(255, 210, 210, 210);
const Color BACKGROUND_GREY_COLOR = const Color.fromARGB(255, 230, 230, 230);