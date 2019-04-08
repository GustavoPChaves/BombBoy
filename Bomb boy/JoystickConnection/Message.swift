//
//  Message.swift
//  Bomb boy
//
//  Created by João Paulo de Oliveira Sabino on 08/04/19.
//  Copyright © 2019 Gustavo Portela Chaves. All rights reserved.
//

import Foundation

enum Direction {
    case up
    case down
    case left
    case right
}

enum Message {
    case move(dx: Float, dy: Float)
    case pressA
    case pressB
    
    //Struct to data
    func archive() -> Data{
        var d = self
        return Data(bytes: &d, count: MemoryLayout.stride(ofValue: d))
    }
    
    //Data to struct
    static func unarchive(_ data: Data) -> Message?{
        guard data.count == MemoryLayout<Message>.stride else {
            fatalError("Error!")
        }
        
        var message: Message?
        
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            message = bytes.load(as: Message.self)
        }
        
        return message
    }
}
