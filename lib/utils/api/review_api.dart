import 'package:pophub/model/review_model.dart';
import 'package:pophub/utils/http.dart';
import 'package:pophub/utils/log.dart';

class ReviewApi {
  static String domain = "https://pophub-fa05bf3eabc0.herokuapp.com";

// 리뷰 조회 - 팝업별
  static Future<List<ReviewModel>> getReviewListByPopup(String popup) async {
    try {
      final List<dynamic> dataList =
          await getListData('$domain/popup/reviews/store/$popup', {});
      List<ReviewModel> reviewList =
          dataList.map((data) => ReviewModel.fromJson(data)).toList();
      return reviewList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch review list: $e');
      throw Exception('Failed to fetch review list');
    }
  }

  // 리뷰 조회 - 사용자별
  static Future<List<ReviewModel>> getReviewListByUser(String userName) async {
    try {
      final List<dynamic> dataList =
          await getListData('$domain/popup/reviews/user/$userName', {});
      print('$domain/popup/reviews/user/$userName');
      List<ReviewModel> reviewList =
          dataList.map((data) => ReviewModel.fromJson(data)).toList();
      return reviewList;
    } catch (e) {
      // 오류 처리
      Logger.debug('Failed to fetch review list: $e');
      throw Exception('Failed to fetch review list');
    }
  }

  // 리뷰 작성
  static Future<Map<String, dynamic>> postWriteReview(
      String popup, double rating, String content, String userName) async {
    final data = await postData('$domain/popup/review/create/$popup', {
      'user_name': userName,
      'review_rating': rating,
      'review_content': content
    });
    Logger.debug("### 리뷰 작성 $data");
    return data;
  }
}
