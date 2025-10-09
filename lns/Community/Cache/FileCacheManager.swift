//
//  FileCacheManager.swift
//  lns
//
//  Created by Elavatine on 2025/4/1.
//

class FileCacheManager {
    private let fileURL: URL
    private let fileHandle: FileHandle
    private let queue = DispatchQueue(label: "com.filecache.queue")
    
    init() {
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        fileHandle = try! FileHandle(forWritingTo: fileURL)
    }
    
    func write(_ data: Data, offset: Int64) {
        queue.async { [weak self] in
            self?.fileHandle.seek(toFileOffset: UInt64(offset))
            self?.fileHandle.write(data)
        }
    }
    
    func read(offset: Int64, length: Int) -> Data? {
        var result: Data?
        queue.sync {
            fileHandle.seek(toFileOffset: UInt64(offset))
            result = fileHandle.readData(ofLength: length)
        }
        return result
    }
    
    func clear() {
        queue.async { [weak self] in
            self?.fileHandle.closeFile()
            try? FileManager.default.removeItem(at: self?.fileURL ?? URL(fileURLWithPath: ""))
        }
    }
}
