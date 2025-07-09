import 'package:kontor/utils/constant.dart';

class Endpoints {
  // Auth
  static String login = "${Constant.baseApiUrl}/auth/login";
  static String register = "${Constant.baseApiUrl}/auth/register";
  static String checkLogin = "${Constant.baseApiUrl}/auth/check";
  static String changePass = "${Constant.baseApiUrl}/auth/change_pass";
  static String forgotPass = "${Constant.baseApiUrl}/auth/forgot_pass";
  static String editProfile = "${Constant.baseApiUrl}/auth/edit_profile";
  static String checkUserRegistered(String value) =>
      "${Constant.baseApiUrl}/auth/check_user/$value";

  // Reference
  static String invoiceYearly = "${Constant.baseApiUrl}/ref/invoice_year";
  static String invoiceMonthly(int currentYear) =>
      "${Constant.baseApiUrl}/ref/invoice_month?year=$currentYear";
  static String apartment = "${Constant.baseApiUrl}/ref/apartment";

  // Invoice
  static String invoiceList(String type, int page) =>
      "${Constant.baseApiUrl}/invoice/list?type=$type&page=$page";
  static String invoiceDetails = "${Constant.baseApiUrl}/invoice/details";

  // Counter
  static String counterHistory = "${Constant.baseApiUrl}/counter/history/";
  static String counterList = "${Constant.baseApiUrl}/counter/list";
  static String counterSave = "${Constant.baseApiUrl}/counter/save";

  // Payment
  static String checkUserRegister(String register) =>
      "${Constant.baseApiUrl}/nc/check_register/$register";
  static String qpayInvoice = "${Constant.baseApiUrl}/pay/qpay";
  static String qpayCheck = "${Constant.baseApiUrl}/pay/check";
}
