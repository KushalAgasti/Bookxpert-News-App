//
//  HomeViewController.swift
//  news app
//
//  Created by Agasti.kushal on 12/09/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var modeSwitch: UISwitch!
    
    @IBOutlet weak var modeLabel: UILabel!
    
    
    override func viewDidLoad() {
            super.viewDidLoad()

            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            modeSwitch.isOn = isDarkMode
            overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            updateImage(isDarkMode: isDarkMode)

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(darkModeChanged(_:)),
                                                   name: .darkModeChanged,
                                                   object: nil)
        }

        @objc func darkModeChanged(_ notification: Notification) {
            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            animateModeChange(isDarkMode: isDarkMode)
        }

        func updateImage(isDarkMode: Bool) {
            if isDarkMode {
                imageview.image = UIImage(named: "moon") // Dark mode image
                modeLabel.text = "Toggle to Light Mode"
            } else {
                imageview.image = UIImage(named: "sun") // Light mode image
                modeLabel.text = "Toggle to Dark Mode"
            }
        }

        func animateModeChange(isDarkMode: Bool) {
            UIView.transition(with: view, duration: 0.4, options: [.transitionCrossDissolve], animations: {
                self.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                }
                self.updateImage(isDarkMode: isDarkMode)
            }, completion: nil)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @IBAction func modeSwitchAction(_ sender: Any) {
            if let switchControl = sender as? UISwitch {
                let isOn = switchControl.isOn
                UserDefaults.standard.set(isOn, forKey: "isDarkMode")

                // Animate the mode change
                animateModeChange(isDarkMode: isOn)

                // Notify other parts of the app if needed
                NotificationCenter.default.post(name: .darkModeChanged, object: nil)
            }
        }
    }

    extension Notification.Name {
        static let darkModeChanged = Notification.Name("darkModeChanged")
    }
