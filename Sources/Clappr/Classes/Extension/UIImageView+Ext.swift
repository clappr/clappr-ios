public extension UIImageView {
    func download(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }

            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }

    func download(string: String) {
        guard let url = URL(string: string) else { return }

        download(url: url)
    }
}
