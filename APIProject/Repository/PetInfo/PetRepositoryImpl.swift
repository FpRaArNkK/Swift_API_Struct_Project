//
//  PetInfoRepositoryImpl.swift
//  APIProject
//
//  Created by 박민서 on 2/1/24.
//

import Foundation
import Alamofire

/// `PetRepository의 Implement Class` 입니다.
final class PetRepositoryImpl: PetRepository  {
    func fetchPetInfo(id: Int) async -> getPetInfoResponseModel? {
        return await APIManager.shared.performRequest(endPoint: PetEndPoint.getPetInfo(id: id))
    }
    
    func fetchAllPetInfo() async -> getAllPetsResponseModel? {
        return await APIManager.shared.performRequest(endPoint: PetEndPoint.getAllPets)
    }
    
    func updatePetInfo(id: Int, dto: postPetInfoUpdateRequestModel) async -> postPetInfoUpdateResponseModel? {
        return await APIManager.shared.performRequest(endPoint: PetEndPoint.postPetInfoUpdate(id: id, dto: dto))
    }
    
    func deletePetInfo(id: Int) async -> deletePetResponseModel? {
        return await APIManager.shared.performRequest(endPoint: PetEndPoint.deletePet(id: id))
    }
    
    
}
