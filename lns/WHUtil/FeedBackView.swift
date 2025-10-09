//
//  FeedBackView.swift
//  lns
//  有触感反馈的UIView
//  Created by Elavatine on 2025/3/18.
//

class FeedBackView: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackViewHeavy: UIView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGeneratorHeavy()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackHeavyButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGeneratorHeavy()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackTapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        TouchGenerator.shared.touchGenerator()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackTapGestureRecognizerSoft: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        TouchGenerator.shared.touchGeneratorSoft()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackTapGestureRecognizerHeavy: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        TouchGenerator.shared.touchGeneratorHeavy()
        super.touchesBegan(touches, with: event)
    }
}
class FeedBackUIImageView: UIImageView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TouchGenerator.shared.touchGenerator()
        super.touchesBegan(touches, with: event)
    }
}

class FeedBackTableViewCell: UITableViewCell {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        TouchGenerator.shared.touchGenerator()
        super.touchesBegan(touches, with: event)
    }
}
