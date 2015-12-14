//
//  TestingWebServer.swift
//  Gig Radio
//
//  Created by Michael Forrest on 21/10/2015.
//

import UIKit
import GCDWebServer

class TestingWebServer{
    let webServer = GCDWebServer()
    let fixturesDirectory: String
    var routes: [(NSRegularExpression,String)]!
    var bundle:NSBundle{
         return NSBundle(forClass: TestingWebServer.self)
    }
    init(fixturesDirectory:String){
        self.fixturesDirectory = fixturesDirectory
        routes = parseRoutes(fixturesDirectory)
        for method in ["GET", "POST", "PUT", "DELETE"]{
            webServer.addDefaultHandlerForMethod(method, requestClass: GCDWebServerRequest.self)  { (request)->GCDWebServerDataResponse in
                let fileName = self.convertRequestToFileName(request)
                if let fixturePath = self.findFixturePath(fileName){
                    print("Received request, responding with fixture \(fixturePath)")
                    if let response = try? String(contentsOfFile: fixturePath){
                        return GCDWebServerDataResponse(HTML: response)
                    }else{
                        return GCDWebServerDataResponse(statusCode: 500)
                    }
                }else{
                    print("No fixture found for \(fixturesDirectory)/(\(fileName))")
                    assert(false)
                    return GCDWebServerDataResponse(statusCode: 404)
                }
            }
        }
    }

    func startWithPort(port:UInt)->Void{
        try! webServer.startWithOptions([
            GCDWebServerOption_AutomaticallySuspendInBackground: false,
            GCDWebServerOption_Port: port
        ])
    }
    func stop(){
        print("Stopped web server!")
        webServer.stop()
    }
    func convertRequestToFileName(request:GCDWebServerRequest)->String{
        var result = String(request.path.characters.dropFirst()) // trim the leading '/' in the path
        result = result.stringByReplacingOccurrencesOfString("/", withString: "|")
        result = "\(result)-\(request.method.uppercaseString)"
        return result
    }
    func findFixturePath(path:String)->String?{
        for (regex, fileName) in self.routes.sort({$0.1.characters.count > $01.1.characters.count}){
            print("FileName for regex \(regex) = \(fileName) matches \(path)?")
            let matches = regex.matchesInString(path, options: [], range: NSMakeRange(0, path.characters.count))
            if matches.count > 0{
                print("YES \(matches)")
                return self.bundle.pathForResource(fileName, ofType: "json", inDirectory: fixturesDirectory)
            }else{
                print("NO")
            }
        }
        return nil
    }
    func parseRoutes(dir:String)->[(NSRegularExpression, String)]{ // this can probably just be done with strings but I'd been working on it for ages. Will refactor next time I need to add something.
        let result = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(bundle.pathForResource(dir, ofType: nil)!)
        return result.map { (try! NSRegularExpression(pattern: $0.componentsSeparatedByString(".json").first!.stringByReplacingOccurrencesOfString("|", withString: "\\|").componentsSeparatedByString("-").first!, options: []), $0.componentsSeparatedByString(".json").first! )}
//        return files.map { fileName in
//            /* e.g.
//            - [0] : "app_sessions-POST.json"
//            - [1] : "catalog_search-GET.json"
//            - [2] : "conversations|id-GET.json"
//            */
//            // The following won't work for nested resources.
//            let path = fileName.componentsSeparatedByString("-").first!
//            let hasResourceId = path.hasSuffix("id")
//            let resource = hasResourceId ? path.componentsSeparatedByString("|id").first! : path
//            return [
//                "fileName": fileName,
//                "hasResourceId": hasResourceId,
//                "resource": resource
//            ]
//        }
    }
}
