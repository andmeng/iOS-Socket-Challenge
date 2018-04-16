//
//  CommandReceiver.swift
//  FitBitChallenge
//
//  Created by Andrew Meng on 2018-02-02.
//  Copyright © 2018 Andrew Meng. All rights reserved.
//

import UIKit

protocol CommandReceiverDelegate : class {
    func didReceiveCommand(command : RGBCommand)
}

// Class to handle with receiving commands from server.py through a socket
class CommandReceiver : NSObject {
    
    let maximumInputLength : Int = 64
    var inputStream : InputStream!
    var readCommand : String = ""
    
    weak var delegate : CommandReceiverDelegate?
    
    // Assumption: server.py will be run off of the local machine hence localhost
    func setupNetworkConnection() {
        var readStream : Unmanaged<CFReadStream>?
        
        CFStreamCreatePairWithSocketToHost(
            kCFAllocatorDefault,
            "localhost" as CFString,
            1234,
            &readStream,
            nil)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.inputStream.delegate = self
        self.inputStream.schedule(in: .current, forMode: .commonModes)
        self.inputStream.open()
    }
    
    func closeNetworkConnection() {
        self.inputStream.close()
    }
}

// MARK: - StreamDelegate and Stream Handling Methods

extension CommandReceiver : StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            if let inputStream = aStream as? InputStream {
                readAvailableBytes(stream: inputStream)
            }
        case Stream.Event.endEncountered:
            print("Stream has ended")
        case Stream.Event.errorOccurred:
            print("An error with the stream has occurred")
        case Stream.Event.hasSpaceAvailable:
            print("Space available")
        default:
            print("Unidentified Stream Event Occurred")
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maximumInputLength)
        
        while stream.hasBytesAvailable {
            let numBytesRead = inputStream.read(buffer, maxLength: maximumInputLength)
            
            // To exit the loop if we encounter some error while reading bytes
            if numBytesRead < 0 {
                if stream.streamError != nil {
                    break
                }
            }
            
            if let command = parseCommand(buffer: buffer, length: numBytesRead) {
                self.delegate?.didReceiveCommand(command: command)
            }
        }
    }
    
    private func parseCommand(buffer: UnsafeMutablePointer<UInt8>,
                                      length: Int) -> RGBCommand? {
        var rValue : CGFloat = 0
        var gValue : CGFloat = 0
        var bValue : CGFloat = 0
        let commandType = CommandType(rawValue: Int(buffer.pointee))
        
        if let type = commandType {
            if type == .absolute {
                // If command type is absolute we know that the RGB info is in 3 8-bit unsigned ints
                // Assumes that the server never sends negative values for rgb values for absolute command
                rValue = CGFloat(buffer[1])
                gValue = CGFloat(buffer[2])
                bValue = CGFloat(buffer[3])
                
            } else if type == .relative {
                // If command type is relative we know that the RGB info is in 3 16-bit signed ints
                // Because read() in InputStream requires a UInt8 pointer it is reading all values as positive
                // And not reading the leading 1 bit as the sign bit and so when reading negative values it is just
                // taken as a large positive
                
                // I could not mediate this within a reasonable time, but I implemented a workout that works with the
                // assumption that "relative" command offset values do not exceed the limit of signed 8 bit integer
                // The function "convertToSignedEquivalent" in "UInt8+Convert.swift" is implemented based on this assumption
                
                rValue = CGFloat(buffer[2].convertToSignedEquivalent())
                gValue = CGFloat(buffer[4].convertToSignedEquivalent())
                bValue = CGFloat(buffer[6].convertToSignedEquivalent())
            }
        }
        
        // Create RGBCommand Object and then deallocate memory
        let rgbObject = RGB(red: rValue,
                            green: gValue,
                            blue: bValue)
        let parsedCommand = RGBCommand(type: commandType, rgb: rgbObject)
        buffer.deallocate(capacity: maximumInputLength)
        return parsedCommand
    }
}
