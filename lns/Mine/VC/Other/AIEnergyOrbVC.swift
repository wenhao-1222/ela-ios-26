//
//  AIEnergyOrbVC.swift
//  lns
//
//  Created by Codex on 2026/5/20.
//

import SwiftUI
import UIKit

class AIEnergyOrbVC: WHBaseViewVC {
    private let orbLevel: AICoachLoopLevel = .level7
    private var orbHostController: UIHostingController<AIEnergyOrbRootView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let contentWidth = min(SCREEN_WIDHT, kFitWidth(370))
        let contentHeight = contentWidth * 213.0 / 370.0
        let top = getNavigationBarHeight() + max(kFitWidth(110), (view.bounds.height - getNavigationBarHeight() - contentHeight) * 0.34)
        orbHostController?.view.frame = CGRect(
            x: (view.bounds.width - contentWidth) * 0.5,
            y: top,
            width: contentWidth,
            height: contentHeight
        )
    }
}

private extension AIEnergyOrbVC {
    func initUI() {
        initNavi(titleStr: "课程干货")
        view.backgroundColor = .black
        
        let hostController = UIHostingController(rootView: AIEnergyOrbRootView(level: orbLevel))
        hostController.view.backgroundColor = .clear
        hostController.view.isOpaque = false

        addChild(hostController)
        view.addSubview(hostController.view)
        hostController.didMove(toParent: self)
        orbHostController = hostController
    }
}

private struct AIEnergyOrbRootView: View {
    let level: AICoachLoopLevel

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height) * 0.92
            AICoachLoopOrb(
                level: level,
                size: side,
                showsLevelLabel: false,
                includesBackground: false
            )
            .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.5)
        }
        .background(
            RadialGradient(
                colors: [
                    Color(red: 0.00, green: 0.10, blue: 0.25).opacity(0.95),
                    Color(red: 0.00, green: 0.04, blue: 0.13).opacity(0.98),
                    Color.black
                ],
                center: .center,
                startRadius: 0,
                endRadius: 260
            )
        )
    }
}
