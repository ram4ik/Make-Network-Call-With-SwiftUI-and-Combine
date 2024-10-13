//
//  ContentView.swift
//  Make Network Call With SwiftUI and Combine
//
//  Created by admin on 10/13/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.character.name ?? "-")
            Text(viewModel.character.height ?? "-")
        }
        .padding()
        .onAppear() {
            viewModel.getCharacter()
        }
    }
}

struct Character: Decodable {
    let name: String?
    let height: String?
}

enum NetworkError: Error {
    case unknown
}

class ViewModel: ObservableObject {
    @Published var character = Character(name: nil, height: nil)
    var cancellable: Set<AnyCancellable> = []
    
    func getCharacter() {
        let response: AnyPublisher<Character, NetworkError> = performRequest()
        response.sink { _ in
            
        } receiveValue: { response in
            self.character = response
        }
        .store(in: &cancellable)
        
    }
    
    func performRequest() -> AnyPublisher<Character, NetworkError> {
        let url = URL(string: "https://swapi.dev/api/people/1")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Character.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                NetworkError.unknown
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

#Preview {
    ContentView()
}
