//
//  AudioManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 14/04/26.
//

import SwiftUI
import AVFoundation

@MainActor
public class AudioManager: ObservableObject {
    public static let shared = AudioManager()
    init() { }
    
    var audioPlayerNode: AVAudioPlayerNode?
    var audioEngine = AVAudioEngine()
    
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 4000, channels: 2, interleaved: false)!
    var amplificationFactor: Float = 1.5
    
    public func processStethoscopeData(data: Data, amplification: Float) {
        self.amplificationFactor = amplification
        
        let float32Array = convertInt32DataToFloat32Array(data)
        
        self.playFloat32(float32Array)
    }
    
    func convertInt32DataToFloat32Array(_ data: Data) -> [Float32] {
        let int32Count = data.count / MemoryLayout<Int32>.size
        let int32Array = data.withUnsafeBytes { bufferPointer -> [Int32] in
            let buffer = bufferPointer.bindMemory(to: Int32.self)
            return Array(buffer.prefix(int32Count))
        }
        
        let amplifiedArray = amplifyAndClip(leftChannel: int32Array, amplificationFactor: amplificationFactor)
        return amplifiedArray.map { Float32($0) / Float32(Int32.max) }
    }
    
    func playFloat32(_ float32Data: [Float32]) {
        let channels = format.channelCount
        let frameCount = AVAudioFrameCount(float32Data.count / Int(channels))
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            print("Failed to create audio buffer.")
            return
        }
        buffer.frameLength = frameCount
        let channelData = buffer.floatChannelData!
        for channel in 0..<Int(channels) {
            for frame in 0..<Int(frameCount) {
                channelData[channel][frame] = float32Data[frame * Int(channels) + channel]
            }
        }
        audioPlayerNode?.scheduleBuffer(buffer, completionCallbackType: .dataPlayedBack) {_ in
            print("Playing at amplification: \(self.amplificationFactor)")
        }
    }
    
    func amplifyAndClip(leftChannel: [Int32], amplificationFactor: Float) -> [Int] {
        let intMax = 2147483647
        let intMin = -2147483648
        return leftChannel.map { sample in
            let amplifiedSample = Float(sample) * amplificationFactor
            let clippedSample = min(max(Int(amplifiedSample), intMin), intMax)
            return clippedSample
        }
    }
    
    public func startAudioEngine() {
        self.audioEngine = AVAudioEngine()
        self.audioPlayerNode = AVAudioPlayerNode()
        self.audioEngine.attach(audioPlayerNode!)
        self.audioEngine.connect(audioPlayerNode!, to: audioEngine.mainMixerNode, format: format)
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine error: \(error.localizedDescription)")
        }
        self.audioPlayerNode!.play()
    }
    
    public func stopAudioEngine() {
        self.audioPlayerNode?.stop()
        self.audioEngine.stop()
    }
}
