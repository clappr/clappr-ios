public extension UIImageView {
    func download(url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
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
