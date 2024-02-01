//
//  Data+.swift
//  APIProject
//
//  Created by 박민서 on 2/1/24.
//

import Foundation
import Alamofire



extension Data {
    /// Data를 특정 Dicodable DataType과 Decoder에 맞춰 decode합니다.
    ///
    /// - Parameters:
    ///   - type: 디코딩할 타입
    ///   - decoder: 사용할 디코더. 기본값은 `JSONDecoder()`입니다.
    /// - Returns: 디코딩된 Decodable Item
    /// - Throws: 디코딩 과정에서 발생한 에러
    func decode<Item: Decodable, Decoder: DataDecoder>(type: Item.Type, decoder: Decoder = JSONDecoder()) throws -> Item {
        try decoder.decode(type, from: self)
    }
}
