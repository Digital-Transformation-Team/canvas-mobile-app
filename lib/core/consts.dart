import 'package:dio/dio.dart';

const CSRF_TOKEN = '_csrf_token';
const LEGACY_SESSION = '_legacy_normandy_session';
const NORMANDY_SESSION = '_normandy_session';
const SESSIONID = 'log_session_id';

const AUTH_TIME = 24;

const CURRENT_USER = 'currentUser';

const SERVER_URL = 'http://185.47.167.43';

final dio = Dio();

