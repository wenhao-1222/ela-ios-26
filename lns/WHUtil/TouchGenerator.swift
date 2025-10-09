//
//  TouchGenerator.swift
//  lns
//
//  Created by Elavatine on 2025/3/3.
//


class TouchGenerator {
    
    static let shared = TouchGenerator()
    
//    private var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    private var generator = UIImpactFeedbackGenerator(style: .light)
    private var generatorSoft = UIImpactFeedbackGenerator(style: .soft)
    private var generatorMedium = UIImpactFeedbackGenerator(style: .medium)
    private var generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    private init(){
        generator = UIImpactFeedbackGenerator(style: .light)
        generatorMedium = UIImpactFeedbackGenerator(style: .medium)
        self.generator.prepare()
        self.generatorSoft.prepare()
        self.generatorMedium.prepare()
        self.generatorHeavy.prepare()
    }
    
    func touchGenerator(style:UIImpactFeedbackGenerator.FeedbackStyle? = .light) {
        DispatchQueue.main.async(execute: {
            self.generator.impactOccurred()
        })
        self.generator.prepare()
    }
    func touchGeneratorSoft() {
        DispatchQueue.main.async(execute: {
            self.generatorSoft.impactOccurred()
        })
        self.generatorSoft.prepare()
    }
    func touchGeneratorMedium() {
        DispatchQueue.main.async(execute: {
            self.generatorMedium.impactOccurred()
        })
        self.generatorMedium.prepare()
    }
    func touchGeneratorHeavy() {
        DispatchQueue.main.async(execute: {
            self.generatorHeavy.impactOccurred()
        })
        self.generatorHeavy.prepare()
    }
}
