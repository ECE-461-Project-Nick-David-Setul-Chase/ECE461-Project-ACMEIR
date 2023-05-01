import 'dart:convert';
import 'dart:html' show AnchorElement, FileUploadInputElement, Url, window;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' show get, delete, post, put;
import 'package:path_provider/path_provider.dart';

class APICaller {
  // API Url
  static const String apiBaseUrl =
      "https://rgdoy0o5q0.execute-api.us-east-2.amazonaws.com/submit";
  // Internal vars (for help with variables of endpoints)
  static const String _packageByName = "$apiBaseUrl/package/byName";
  static const String _packageByID = "$apiBaseUrl/package";
  // API Endpoints
  static const String authEndpoint = "$apiBaseUrl/authenticate";
  static const String addEndpoint = "$apiBaseUrl/package";
  static const String packagesEndpoint = "$apiBaseUrl/packages";
  static const String resetEndpoint = "$apiBaseUrl/reset";
  static String packageByNameEndpoint(String name) => '$_packageByName/$name';
  static String packageByIdEndpoint(String id) => '$_packageByID/$id';
  static String packageRateByIdEndpoint(String id) => '$_packageByID/$id/rate';
  static var headers = {"Content-Type": "application/json"};
  // For testing
  static String test = "/";

  static Future<bool> addPackage(
      {required String data, required String code}) async {
    try {
      print('Upload Content:\n$data');
      var requestBody = {"Content": data, "JSProgram": code};

      Uri apiUrl = Uri.parse(addEndpoint);
      var response =
          await post(apiUrl, headers: headers, body: jsonEncode(requestBody));
      if (response.statusCode == 201) {
        // Something
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<bool> deletePackages(
      {required List<Map<String, dynamic>> packages}) async {
    bool isComplete = true;
    for (Map<String, dynamic> package in packages) {
      try {
        Uri apiUrl = Uri.parse(packageByIdEndpoint(package['ID']));
        var response = await delete(
          apiUrl,
          headers: headers,
        );
        if (response.statusCode == 200) {
          // Something
        }
      } catch (e) {
        print(e);
        isComplete = false;
      }
    }
    return isComplete;
  }

  // static Future<bool> updatePackages(
  //     {required List<Map<String, dynamic>> packages}) async {
  //   bool isComplete = true;
  //   for (Map<String, dynamic> package in packages) {
  //     try {
  //       Uri apiUrl = Uri.parse(packageByIdEndpoint(package['ID']));
  //       var response = await put(
  //         apiUrl,
  //         headers: headers,
  //       );
  //       if (response.statusCode == 200) {
  //         // Something
  //       }
  //     } catch (e) {
  //       print(e);
  //       isComplete = false;
  //     }
  //   }
  //   return isComplete;
  // }

  static Future<bool> factoryReset() async {
    try {
      Uri apiUrl = Uri.parse(resetEndpoint);
      var response = await delete(
        apiUrl,
        headers: headers,
      );
      if (response.statusCode == 200) {
        // Something
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  static Future<bool> downloadPackage({required String id}) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('/packages')
          .doc(id)
          .get();
      if (snapshot.data() != null) {
        // var directory = await getDownloadsDirectory();
        // File downloadFile = File(directory!.resolveSymbolicLinksSync());
        // downloadFile
        //     .writeAsBytesSync(base64Decode((snapshot.data()!['Content'])));

        final urlString =
            "data:application/zip;base64,${snapshot.data()!['Content']}";
        AnchorElement anchorElement = AnchorElement(href: urlString);
        anchorElement.download = urlString;
        anchorElement.click();
      }

      // Uri apiUrl = Uri.parse(packageByIdEndpoint(id));
      // var response = await get(
      //   apiUrl,
      //   headers: headers,
      // );
      // if (response.statusCode == 200) {
      //   print(response.body);
      //   var directory = await getDownloadsDirectory();
      //   File downloadFile = File(directory!.resolveSymbolicLinksSync());
      //   downloadFile.writeAsBytesSync(base64Decode((response.body)));
      //   return true;
      // }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
