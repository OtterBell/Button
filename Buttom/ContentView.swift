//
//  ContentView.swift
//  Buttom
//
//  Created by Mac11 on 2025/3/21.
//

import SwiftUI
import AVFAudio
import AVFoundation

class AudioDelegate: NSObject, AVAudioPlayerDelegate, ObservableObject{
    @Published var finishPlay = false
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlay = true
    }
}

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlay = false
    @State private var opacity: Double = 1
    @State private var spinning: Double = 0
    @State private var doRotate = false
    @State private var currentTime: TimeInterval = 0
    @StateObject private var audioDelegate = AudioDelegate()
    
    let synthesizer = AVSpeechSynthesizer()
    let rotationTimer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()  //旋轉用計時器(每0.02秒轉一點點)
    
    var body: some View {
        ZStack{
            Rectangle()
                .ignoresSafeArea()
            Image(.romeoXJuliet)
                .resizable()
                .scaledToFit()
                .offset(y:20)
                .opacity(opacity)
                .animation(.default, value: opacity)
            Image(.romeoXJuliet)
                .resizable()
                .scaledToFit()
                .clipShape(.circle)
                .offset(y:20)
                .rotationEffect(.degrees(spinning))
                //.animation(.linear(duration: 0.02), value: spinning)
                .animation(.default, value: spinning)
                .onReceive(rotationTimer) { _ in
                    if doRotate {
                        spinning += 1
                    }
                }
            if let duration = audioPlayer?.duration{
                Slider(value: Binding(get: {
                    currentTime
                }, set: { newValue in
                    currentTime = newValue
                    audioPlayer?.currentTime = newValue
                }), in: 0...duration)
            }
//            if let duration = audioPlayer?.duration {
//                Text("\(formatTime(_time: currentTime)) / \(formatTime(_time: duration))")
//            }
            Button {
                print("Hola!")
                let utterance = AVSpeechUtterance(string: """
    Let's play the music!
    """)
                utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.girl")
                utterance.rate = 0.5
                utterance.pitchMultiplier = 1.0
                synthesizer.speak(utterance)
            } label: {
                Text("Welcome")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
                    .background(.linearGradient(colors:[.purple,.black,.purple], startPoint: .leading, endPoint: .trailing))
                    .clipShape(.rect(cornerRadius: 20))
            }.offset(y:-300)
            
            Button {
                if audioDelegate.finishPlay {
                    restart()
                } else {
                    musicPlayer()
                }
            } label: {
                Text(audioDelegate.finishPlay ? "Replay" : (isPlay ? "Pause" : "Play"))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding()
                    .background(.linearGradient(colors:[.purple,.black,.purple], startPoint: .leading, endPoint: .trailing))
                    .clipShape(.rect(cornerRadius: 20))
            }.offset(y:300)
        }
        
    }
    func musicPlayer(){
        if audioPlayer == nil {
            guard let url = Bundle.main.url(forResource: "You raise me up", withExtension: "mp3")else{
                print("can't find music")
                return
            }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
            }catch{
                print("music player is wrong!")
            }
        }
        if isPlay{
            audioPlayer?.pause()
            doRotate = false
        }else{
            audioPlayer?.play()
            doRotate = true
            opacity = 0.5
        }
        isPlay.toggle()
        audioDelegate.finishPlay = false
    }
//    func formatTime(_time: TimeInterval) -> String{
//        let minutes = Int(time) / 60
//        let seconds = Int(time) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
    func restart(){
        musicPlayer()
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
        isPlay = true
        opacity = 1
        doRotate = true
        spinning = 0
        audioDelegate.finishPlay = false
    }
}


#Preview {
    ContentView()
}
