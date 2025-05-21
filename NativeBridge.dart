import 'package:flutter/services.dart';
import 'FireConstants.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('your_channel_name');

  static Future<String> callNativeMethodKot(String parameter, String orderItems, String currencySymball, String tableNo, String Lastclickedmodule) async {
    try {
      final String result = await _channel.invokeMethod('your_native_method_name_kot', {
        'parameter': parameter,
        'orderItems': orderItems,
        'currencySymball': currencySymball,
        'tableNo': tableNo,
        'type': Lastclickedmodule,
        'brandName': brandName,
      });
      return result;
    } catch (e) {
      print('Error calling native method: $e');
      return 'Error';
    }
  }

  static Future<String> callNativeMethodBill(String parameter, String billItems, String currencySymball, String costcenter, String type, String customermobile, String customername, String customergst, String tableNo, String cgst, String cgstpercent, String sgst, String sgstpercent) async {
    try {
      final String result = await _channel.invokeMethod('your_native_method_name_bill', {
        'parameter': parameter,
        'billItems': billItems,
        'currencySymball': currencySymball,
        'brandName': brandName,
        'costcenter': costcenter,
        'type': type,
        'brandGSTIN': brandGst,
        'barndVATIN': brandVat,
        'brandFSSAI': brandFssai,
        'brandmobile': brandmobile,
        'brandmobiletwo': brandmobiletwo,
        'customermobile': customermobile,
        'customername': customername,
        'customergst': customergst,
        'tableNo': tableNo,
        'mos': lastMOS,
        'cgst': cgst,
        'cgstpercent': cgstpercent,
        'sgst': sgst,
        'sgstpercrnt': sgstpercent,
      });
      return result;
    } catch (e) {
      print('Error calling native method: $e');
      return 'Error';
    }
  }
}