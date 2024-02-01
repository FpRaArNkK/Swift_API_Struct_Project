//
//  MainViewModel.swift
//  APIProject
//
//  Created by 박민서 on 2/1/24.
//

import Foundation

final class MainViewModel: ObservableObject {
    @Published var pet: getPetInfoResponseModel?
    @Published var pets: getAllPetsResponseModel?
    
    private var repository: PetRepository
    
    init(repository: PetRepository) {
        self.repository = repository
    }
    
    func fetchPetInfo(id: Int) {
        Task {
            if let petInfo = await repository.fetchPetInfo(id: id) {
                pet = petInfo
            }
        }
    }
    
    func fetchPetsInfo() {
        Task {
            if let petInfos = await repository.fetchAllPetInfo() {
                pets = petInfos
            }
        }
    }
}
