

import 'Tax_model.dart';

//String apiUrl = 'http://13.201.243.73:9088/F&BPOS/';  //aws ubuntu application server
String apiUrl = 'http://103.205.142.101:8089/dgpos/';      // server
//String apiUrl = 'http://202.179.95.253:8089/dgpos/';      // server

//String apiUrl = 'http://192.168.1.168:8089/F&BPOS/';    //mylocal

//String apiUrl = 'http://192.168.29.142:8089/F&BPOS/';    //singju


String lstatus = 'UNKNOWN';
String brandName = 'Default Hotel';
String brandGst = 'GST0001';
String brandVat = 'GST0001';
String brandFssai = 'GST0001';
String username = '';

String brandcurrencysymball = '₹';

String Addresslineone = 'Hira panna mall,Oshiwara ';
String Addresslinetwo = 'Jogeshwari,Goregaon';
String Addresslinethree = 'Mumbai - 400060';
String brandmobile = '';
String emailid = '';
String brandmobiletwo = '';


List<Tax> globaltaxlist = [];
String GLOBALNSC = 'N';


String CLIENTCODE = 'dgp000001';

////////////////DAY CLOSE DAY START/////////////////////
String posdate = '21-06-2024';
////////////////DAY CLOSE DAY START/////////////////////

////other states//
String Lastclickedmodule = 'Dine';

String DuplicatePrint = 'N';
String DuplicateKotPrint = 'N';
String DayCloseRequested = 'N';
String FisrtOrderFetched = 'N';

String enteredprinterip ='';
String lastMOS = 'Cash';


String selectedwaitername = '';
int selectedPax = 1;

const String weraApiUrl = 'https://api.werafoods.com/';
const String merchantId = "2552";
const String WeraApiKey = "9b0ffbebd-ebc7g-4215-9e51p-obb49c054e276s";