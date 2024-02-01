//
//  MainView.swift
//  APIProject
//
//  Created by 박민서 on 2/1/24.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel(repository: PetRepositoryTest())

    var body: some View {
        Spacer()
        VStack {
            Text("Pet: \(viewModel.pet?.pet_name ?? "Unknown")")
            Button("Fetch Pet Info") {
                viewModel.fetchPetInfo(id: 1)
            }
        }
        Spacer()
        VStack {
            Text("Pet List:")
            
            if let pets = viewModel.pets {
                List(pets, id: \.pet_id) { pet in
                    Text(pet.pet_name)
                }
            }
            Button("Fetch Pet Info") {
                viewModel.fetchPetsInfo()
            }
        }
        Spacer()
    }
}

#Preview {
    MainView()
}
