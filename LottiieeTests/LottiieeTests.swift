//
//  LottiieeTests.swift
//  LottiieeTests
//
//  Created by Yuri on 2025/2/21.
//

import Testing
import UIKit
@testable import Lottiiee

struct LottiieeTests {

    @Test func example() async throws {
        do {
            // 测试单个文件转换
//            let jsonPath = "/Users/yuri/Downloads/favourite-sunset-Lottie/iOS-中文-DM.json"
//            try FileConverter.convertToLottie(jsonPath: jsonPath)

//            // 验证生成的文件是否存在
//            let lottieURL = URL(fileURLWithPath: jsonPath).deletingPathExtension().appendingPathExtension("lottie")
//            assert(FileManager.default.fileExists(atPath: lottieURL.path))

            // 测试文件夹处理
            let folderPath = "/Users/yuri/Downloads/sunset-V3-lottie"
            try FileConverter.processFolder(folderPath)

        } catch {
            print("Test failed with error: \(error)")
        }
    }

}
