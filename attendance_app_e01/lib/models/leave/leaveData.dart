class LeaveData {
  late String userid;
  late String startdate;
  late String enddate;
  late String leavetype;
  late String reason;
  late String date;

  LeaveData({
    required this.userid,
    required this.startdate,
    required this.enddate,
    required this.leavetype,
    required this.reason,
    required this.date,
  });


  factory LeaveData.fromJson(Map<String,dynamic> leavedata){
    return LeaveData(
      userid: leavedata['userid'], 
      startdate: leavedata['startdate'], 
      enddate: leavedata['enddate'], 
      leavetype: leavedata['leavetype'], 
      reason: leavedata['reason'], 
      date: leavedata['date'],
    );
  }


  Map<String,dynamic> toJson(){
    final Map<String,dynamic> leaveData = Map <String,dynamic>();
    leaveData['userid'] = userid;
    leaveData['startdate'] = startdate;
    leaveData['enddate'] = enddate;
    leaveData['leavetype'] = leavetype;
    leaveData['reason'] = reason;
    leaveData['date'] = date;
    return leaveData;
  }

}


class LeaveResponse{
  late final String message;
  late final bool success;

  LeaveResponse({
    required this.message,
    required this.success,
  });

  factory LeaveResponse.fromJson(Map<String,dynamic> loginData){
      return LeaveResponse(
        message: loginData['message'], 
        success: loginData['success'],
      );
    }
}
