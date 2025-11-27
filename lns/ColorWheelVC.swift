//
//  ColorWheelVC.swift
//  lns
//
//  Created by LNS2 on 2025/11/27.
//

import UIKit

class ColorWheelVC: UIViewController, ColorWheelViewDelegate {

    private var colorWheel: ColorWheelView!
    private var rSlider: UISlider!
    private var gSlider: UISlider!
    private var bSlider: UISlider!

    private var rLabel: UILabel!
    private var gLabel: UILabel!
    private var bLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupColorWheel()
        setupRGBSliders()
    }

    func setupColorWheel() {
        colorWheel = ColorWheelView()
        colorWheel.delegate = self
        colorWheel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorWheel)
        
        NSLayoutConstraint.activate([
            colorWheel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorWheel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            colorWheel.widthAnchor.constraint(equalToConstant: 280),
            colorWheel.heightAnchor.constraint(equalTo: colorWheel.widthAnchor)
        ])
    }

    func setupRGBSliders() {
        let labels = ["R", "G", "B"]
        var sliders: [UISlider] = []
        var valueLabels: [UILabel] = []

        for i in 0..<3 {
            let label = UILabel()
            label.text = labels[i]
            label.textColor = [.red, .green, .blue][i]
            label.translatesAutoresizingMaskIntoConstraints = false

            let slider = UISlider()
            slider.minimumValue = 0
            slider.maximumValue = 255
            slider.value = 255
            slider.tag = i
            slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
            slider.translatesAutoresizingMaskIntoConstraints = false

            let valLabel = UILabel()
            valLabel.text = "255"
            valLabel.textColor = .white
            valLabel.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(label)
            view.addSubview(slider)
            view.addSubview(valLabel)

            sliders.append(slider)
            valueLabels.append(valLabel)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                label.topAnchor.constraint(equalTo: colorWheel.bottomAnchor, constant: CGFloat(40 + i * 50)),

                slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20),
                slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
                slider.centerYAnchor.constraint(equalTo: label.centerYAnchor),

                valLabel.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 10),
                valLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor)
            ])
        }

        rSlider = sliders[0]
        gSlider = sliders[1]
        bSlider = sliders[2]
        
        rLabel = valueLabels[0]
        gLabel = valueLabels[1]
        bLabel = valueLabels[2]
    }

    
    // MARK: - Slider Changed
    @objc func sliderChanged(_ slider: UISlider) {
        let r = CGFloat(rSlider.value) / 255
        let g = CGFloat(gSlider.value) / 255
        let b = CGFloat(bSlider.value) / 255
        
        rLabel.text = "\(Int(rSlider.value))"
        gLabel.text = "\(Int(gSlider.value))"
        bLabel.text = "\(Int(bSlider.value))"
        
        view.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    // MARK: - Color Wheel Delegate
    func colorWheelDidChangeColor(_ color: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        rSlider.value = Float(r * 255)
        gSlider.value = Float(g * 255)
        bSlider.value = Float(b * 255)
        
        rLabel.text = "\(Int(r * 255))"
        gLabel.text = "\(Int(g * 255))"
        bLabel.text = "\(Int(b * 255))"
        
        view.backgroundColor = color
    }
}
