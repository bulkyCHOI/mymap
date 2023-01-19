import 'package:dio/dio.dart';
import 'package:flutter_crud/network/model/basic_response.dart';

import 'package:flutter_crud/network/model/emp_info.dart';
import 'package:flutter_crud/network/model/rs_info.dart';
import 'package:flutter_crud/network/model/board_info.dart';

import 'package:flutter_crud/network/model/otp_info.dart';
import 'package:flutter_crud/network/model/user_info.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 로그인 관련
  @POST('/signin')
  Future<BasicResponse> signin(@Body() UserInfo userInfo);

  @POST('/verify')
  Future<BasicResponse> verify(@Body() OtpInfo otpInfo);

  @POST('/signout')
  Future<BasicResponse> signout();

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 사원 관리
  @GET('/employee/getEmployees')
  Future<BasicResponse> getEmployees();

  @POST('/employee/addNewEmployee')
  Future<BasicResponse> addEmployee(@Body() EmpInfo empInfo);

  @POST('/employee/updateEmployeeInfo')
  Future<BasicResponse> updateEmployee(@Body() EmpInfo empInfo);

  @POST('/employee/deleteEmployee')
  Future<BasicResponse> deleteEmployee(@Body() EmpInfo empInfo);

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
  // 기지국 관리
  @GET('/ninja-api/demolitions/getDemolitionList/{div}')
  Future<BasicResponse> getRadioStation(@Path("div") String div);

  @POST('/ninja-api/demolitions/createDemolitionListFlutter')
  Future<BasicResponse> addRadioStation(@Body() RsInfo rsInfo);

  @POST('/ninja-api/demolitions/updateDemolitionListFlutter')
  Future<BasicResponse> updateRadioStation(@Body() RsInfo rsInfo);

  @POST('/ninja-api/demolitions/deleteDemolitionListFlutter')
  Future<BasicResponse> deleteRadioStation(@Body() RsInfo rsInfo);

  /////////////////////////////////////////////////////////////////////////////////////////////////////////
//  게시판 관리
  @POST('/ninja-api/wsbpsapp/getBoardList')
  Future<BasicResponse> getBoardList();

  @POST('/ninja-api/wsbpswsbpsapp/createBoardFlutter')
  Future<BasicResponse> addBoard(@Body() BoardInfo boardInfo);

  @POST('/ninja-api/wsbpswsbpsapp/updateBoardFlutter')
  Future<BasicResponse> updateBoard(@Body() BoardInfo boardInfo);

  @POST('/ninja-api/wsbpswsbpsapp/deleteBoardFlutter')
  Future<BasicResponse> deleteBoard(@Body() BoardInfo boardInfo);


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// memo
// @GET('/memos/getMemo')
// Future<BasicResponse> getMemo();
//
// @POST('/memos/addMemo')
// Future<BasicResponse> addMemo(@Body() MemoInfo memoInfo);
//
// @POST('/memos/editMemo')
// Future<BasicResponse> editMemo(@Body() MemoInfo memoInfo);
//
// @POST('/memos/deleteMemo')
// Future<BasicResponse> deleteMemo(@Body() MemoInfo memoInfo);



}