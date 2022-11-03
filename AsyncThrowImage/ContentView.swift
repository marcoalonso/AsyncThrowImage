//
//  ContentView.swift
//  AsyncThrowImage
//
//  Created by Marco Alonso Rodriguez on 03/11/22.
//

import SwiftUI

class AsyncThrowImage {
    var image: UIImage? = nil
    let url = URL(string: "https://picsum.photos/200/300")!
    
    //recive a data and response and return a UIImage?
    func responseHandler(data: Data?, response: URLResponse?) -> UIImage? {
        //Unwrap data, and create image
        guard let data = data,
              let image = UIImage(data: data),
              let response = response else { return nil }
        return image
    }
    
    func loadImageWithAsycn() async throws -> UIImage? {
        do{
            //try to create data and response 
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return responseHandler(data: data, response: response)
        } catch {
          throw error
        }
    }
    
    //Here is another way to call API by completion
    func getImageWithCompletion(completionHandler: @escaping(_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  let _ = response else { return }
            completionHandler(image, nil)
        }
        .resume()
    }
}

class ViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    var loader = AsyncThrowImage()
    
    func fetchImage() async {
        let image = try? await loader.loadImageWithAsycn()
        self.image = image
    }
    
    func fetchImageWithCompletion() {
        loader.getImageWithCompletion { [weak self] image, error in
            self?.image = image
        }
    }
}

struct ContentView: View {
    @StateObject var vm = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = vm.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 300)
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 10)
                }
            }
            .onAppear {
                Task {
//                    await vm.fetchImage()
                     vm.fetchImageWithCompletion()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
//                        Task {
//                            await vm.fetchImage()
//                        }
                        vm.fetchImageWithCompletion()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2.bold())
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
