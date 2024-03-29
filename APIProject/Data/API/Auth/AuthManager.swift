//
//  AuthManager.swift
//  APIProject
//
//  Created by 박민서 on 2/1/24.
//

import Alamofire
import Foundation
//import SwiftKeychainWrapper

/// API Request의 Authentication을 관리합니다.
class AuthManager: RequestInterceptor {
    
    /// 요청 실패 시 재시도 횟수입니다.
    private var retryLimit = 2
    
    /// URLRequest를 보내는 과정을 Intercept하여, Request의 내용을 변경합니다.
    ///
    /// - Parameters:
    ///    - urlRequest: 원래의 URLRequest
    ///    - session : 진행하는 Alamofire Session
    ///    - completion: 변경된 URLRequest를 포함하는 Result를 비동기 처리하는 클로저
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        // baseURL 확인
        guard urlRequest.url?.absoluteString.hasPrefix(Constants.baseURL) == true else { return }
        
        // accessToken 확인
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            completion(.failure(APIError.customError("토큰 조회 실패")))
            return
        }
        //: 조건 확인 끝
        
        // URLRequest 헤더 추가, return
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: accessToken))
        urlRequest.headers.add(.contentType("application/json"))
        completion(.success(urlRequest))
    }
    
    /// Request 요청이 실패했을 때, 재시도 여부를 결정합니다.
    ///
    /// - Parameters:
    ///     - request: 실패한 원래 Request
    ///     - session: 진행하던 Alamofire Session
    ///     - error: 실패 원인의 error
    ///     - completion: RetryResult를 처리하여 재시도 여부를 알려주는 비동기 클로저
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        // HTTP 응답 코드 확인, 재시도 여부 결정
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 || response.statusCode == 403 else {
            // 401 Unauthorized 또는 403 Forbidden 상태 코드가 아니라면, Error 메세지와 함께 재시도하지 않음
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let url = URL(string: Constants.baseURL+"/auth/refreshTokenPlease") else { return }
        
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
        else {
            // 토큰 없는 경우 에러 처리
            completion(.doNotRetryWithError(APIError.customError("토큰 조회 실패")))
            return
        }
        
        let parameters: Parameters = [
            "accessToken": accessToken,
            "refreshToken": refreshToken
        ]
        
        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
        .validate()
        .responseDecodable(of: Auth.self) { response in
            switch response.result {
            case .success(let result):
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                
                UserDefaults.standard.setValue(result.accessToken, forKey: "accessToken")
                UserDefaults.standard.setValue(result.refreshToken, forKey: "refreshToken")
                
                // 재시도 횟수 내일 때만 재시도
                request.retryCount < self.retryLimit ?
                completion(.retry) : completion(.doNotRetryWithError(APIError.customError("재시도 횟수 초과")))
            case .failure(let error):
                completion(.doNotRetryWithError(error))
            }
        }
    }

}

// 예시 Auth Decodable Model
struct Auth: Decodable {
    let accessToken: String
    let refreshToken: String
}
