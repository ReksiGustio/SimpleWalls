//
//  Requests.swift
//  SimpleWalls
//
//  Created by Reksi Gustio on 02/07/24.
//

import Foundation

//base HTTP GET request
func getRequest(API: String) async -> Data {
    guard let url = URL(string: "http://172.20.57.25:3000\(API)") else { return Data() }
    var request = URLRequest(url: url)
    request.timeoutInterval = 5
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
        
    }
}

//base HTTP POST request
func postRequest(body: Data, API: String) async -> Data {
    guard let url = URL(string: "http://172.20.57.25:3000\(API)") else { return Data() }
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: body)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
        
    }
}

//base HTTP PUT request
func putRequest(body: Data, API: String) async -> Data {
    guard let url = URL(string: "http://172.20.57.25:3000\(API)") else { return Data() }
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "PUT"
    request.timeoutInterval = 20
    
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: body)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
        
    }
}

//base HTTP DELETE request
func deleteRequest(API: String) async -> Data {
    guard let url = URL(string: "http://172.20.57.25:3000\(API)") else { return Data() }
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.timeoutInterval = 5
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
        
    }
}

//base download image request
func downloadRequest(imageURL: String?) async -> Data {
    guard let imageURL else { return Data() }
    guard let url = URL(string: imageURL) else { return Data() }
    let request = URLRequest(url: url)
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    } catch {
        print(error.localizedDescription)
        return Data()
    }
}


//upload profile image
func uploadRequest(image: Data, fieldName: String, id: String) async {
    let boundary = generateBoundaryString()
    let body = createBody(boundary: boundary, name: "\(fieldName)_pic", fieldName: "\(fieldName)_pic.jpg", image: image)
    
    let url = URL(string: "http://172.20.57.25:3000/upload/\(fieldName)/\(id)")!
    var request = URLRequest.init(url: url)
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = body as Data
    request.timeoutInterval = 10

    do {
        if let encoded = request.httpBody {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            print(String(data: data, encoding: .utf8) ?? "")
        }
    } catch {
        print(error.localizedDescription)
    }

}

//----------------------------------------------------------------
//create bondary and body for uploading image
func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}

func createBody(boundary: String, name: String, fieldName: String, image: Data) -> NSMutableData {
    let body = NSMutableData()
    
    let mimetype = "image/png"

    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
    body.append("Content-Disposition:form-data; name=\"\(name)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
    body.append("hi\r\n".data(using: String.Encoding.utf8)!)

    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Disposition:form-data; name=\"\(name)\"; filename=\"\(fieldName)\"\r\n".data(using: String.Encoding.utf8)!)
    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
    body.append(image)

    body.append("\r\n".data(using: String.Encoding.utf8)!)
    body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
    
    return body
}

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
         print("data======>>>",data)
      }
   }
}
