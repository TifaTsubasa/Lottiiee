import Foundation
import ZipArchive

class FileConverter {
    
    // 处理文件夹中的所有JSON文件
    static func processFolder(_ folderPath: String) throws {
        print("Processing folder: \(folderPath)")
        
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: folderPath)
        
        while let filePath = enumerator?.nextObject() as? String {
            let fullPath = (folderPath as NSString).appendingPathComponent(filePath)
            var isDirectory: ObjCBool = false
            
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // 如果是目录，递归处理
                    try processFolder(fullPath)
                } else if filePath.hasSuffix(".json") {
                    // 如果是JSON文件，进行转换
                    try convertToLottie(jsonPath: fullPath)
                }
            }
        }
    }
    
    // 压缩目录
    static func zipDirectory(folderPath: String, zipFilePath: String) throws {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: folderPath)
        
        // 使用新的静态方法创建zip文件
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: folderPath, isDirectory: &isDirectory) && isDirectory.boolValue {
            // 直接使用createZip静态方法压缩整个目录
            if !SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: folderPath) {
                throw NSError(domain: "ZipError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create zip file"])
            }
        }
    }
    
    // 转换JSON文件为Lottie格式
    static func convertToLottie(jsonPath: String) throws {
        print("converting \(jsonPath) to lottie...")
        
        let fileManager = FileManager.default
        let jsonURL = URL(fileURLWithPath: jsonPath)
        
        // 创建同名文件夹
        let folderURL = jsonURL.deletingPathExtension()
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        
        // 创建manifest.json
        let manifestURL = folderURL.appendingPathComponent("manifest.json")
        let manifestContent = """
            {"version":"1","generator":"lottiiee","author":"upmer","animations":[{"id":"data"}]}
            """
        try manifestContent.write(to: manifestURL, atomically: true, encoding: .utf8)
        
        // 创建animations文件夹
        let animationsURL = folderURL.appendingPathComponent("animations")
        try fileManager.createDirectory(at: animationsURL, withIntermediateDirectories: true)
        
        // 复制JSON文件到animations/data.json
        let dataURL = animationsURL.appendingPathComponent("data.json")
        try fileManager.copyItem(at: jsonURL, to: dataURL)
        
        // 创建zip文件
        let lottieURL = jsonURL.deletingPathExtension().appendingPathExtension("lottie")
        try zipDirectory(folderPath: folderURL.path, zipFilePath: lottieURL.path)
        
        // 删除临时文件夹
        try fileManager.removeItem(at: folderURL)
    }
}

