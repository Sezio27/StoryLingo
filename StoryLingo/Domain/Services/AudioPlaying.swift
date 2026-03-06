//
//  AudioPlaying.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation

public protocol AudioPlaying: AnyObject {
    func playAudio(data: Data) throws
    func playPCMStream(_ stream: AsyncThrowingStream<Data, Error>) async throws
    func stop()
}
