private let imageCache = NSCache<AnyObject, AnyObject>()

public extension UIImageView {
    func setImage(from url: URL) {
        if let imageFromCache = imageCache.object(forKey: url.absoluteString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }

        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }

            DispatchQueue.main.async {
                imageCache.setObject(image, forKey: url.absoluteString as AnyObject)
                self.image = image
            }
        }.resume()
    }
}
