import UIKit

class Bridges {
    func convertJsonsToLottie(path: String) {
        do {
            try FileConverter.processFolder(path)
        } catch {
            print("转换失败: \(error)")
        }
    }
}
