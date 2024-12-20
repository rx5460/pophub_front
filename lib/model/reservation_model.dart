class ReservationModel {
  String? store,
      date,
      time,
      reservationId,
      userName,
      createTime,
      storeName,
      image;
  final int? max, current, capacity;
  final List<ReservationStatusModel>? status;

  ReservationModel.fromJson(Map<String, dynamic> json)
      : reservationId = json['reservation_id'],
        store = json['store_id'],
        userName = json['user_name'],
        capacity = json['capacity'],
        max = json['max_capacity'],
        createTime = json['created_at'],
        current = json['current_capacity'],
        status = json['status'],
        date = json['reservation_date'],
        time = json['reservation_time'],
        storeName = json['store_name'],
        image = json['image'];
}

class ReservationStatusModel {
  String? date, time;

  final int? current;
  final bool? status;

  ReservationStatusModel.fromJson(Map<String, dynamic> json)
      : current = json['current_capacity'],
        status = json['status'],
        date = json['reservation_date'],
        time = json['reservation_time'];
}
