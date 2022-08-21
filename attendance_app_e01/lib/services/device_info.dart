import 'package:get_ip_address/get_ip_address.dart';

class DeviceInfo {

  static Future<String> get getIp async {
    try {
      /// Initialize Ip Address
      var ipAddress = IpAddress(type: RequestType.json);

      /// Get the IpAddress based on requestType.
      final String ip = await ipAddress.getIpAddress();
      
      print("device id :" + ip);

      return ip;

    } on IpAddressException catch (e) {
      /// Handle the exception.
      //print(exception.message);
      return e.toString();
    }
  }
}
