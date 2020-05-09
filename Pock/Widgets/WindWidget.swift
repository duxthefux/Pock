//
//  WindWidget.swift
//  Pock
//
//  Created by Christopher Fuchs on 09.05.20.
//  Copyright © 2020 Pierluigi Galdi. All rights reserved.
//

import Foundation


class WindWidgetButton: NSButton {
    override open var intrinsicContentSize: NSSize {
        var size = super.intrinsicContentSize
        size.width = min(size.width, 64)
        return size
    }
}

struct WindValue: Codable {
    let date: String
    let direction: String
    let avg: Float
    let gust: Float
}

class WindWidget: PKWidget {

    var identifier: NSTouchBarItem.Identifier = NSTouchBarItem.Identifier.currentWind
    var customizationLabel: String = "Current wind in podersdorf".localized
    var view: NSView!
    var button: NSButton!

    required init() {
        button = WindWidgetButton(title: "", target: self, action: #selector(tap))

        view = button

        refreshValue()

        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
    }
    @objc func refreshValue()
    {

        print("Fetching wind values...");

        // Set loading icon
        button.title = "\u{25CC}";

        let url = URL(string: "http://windcal.com/currentWind.php?limit=1")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            if let data = data {
                print("Fetched wind values!");
                let jsonString = (String(data: data, encoding: .utf8)!)
                let jsonData = jsonString.data(using: .utf8)!
                do {
                    let windValues = try JSONDecoder().decode([WindValue].self, from: jsonData)
                    print(windValues)
                    if(windValues.first != nil){
                        let value = windValues.first!;
                         DispatchQueue.main.async {
                            self.setWindValue(value: value)
                        }
                    }
                } catch let error {
                    print(error)
                }

            }
        }
        task.resume()

    }

    private func setWindValue(value: WindValue) {

        let title = value.direction + " " + Int(value.avg).description + " " + Int(value.gust).description
        print(title)
        self.button.title = title

        if(value.avg < 12){
            // Light blue
            self.button.bezelColor = NSColor.init(red: 156/255, green: 250/255, blue: 246/255, alpha: 1)
        } else if(value.avg < 18){
            // Green
            self.button.bezelColor = NSColor.init(red: 75/255, green: 252/255, blue: 35/255, alpha: 1)
        }else if(value.avg < 25){
            // Orange
            self.button.bezelColor = NSColor.init(red: 247/255, green: 162/255, blue: 34/255, alpha: 1)
        } else if(value.avg < 30){
            // Red
            self.button.bezelColor = NSColor.init(red: 242/255, green: 85/255, blue: 33/255, alpha: 1)
        } else {
            // Purple
            self.button.bezelColor = NSColor.init(red: 244/255, green: 34/255, blue: 160/255, alpha: 1)
        }

    }

    @objc private func tap() {
        refreshValue()

        //let sUrl = "https://www.kiteriders.at/wind/weatherstat_kn.html"

        //NSWorkspace.shared.open(NSURL(string: sUrl)! as URL)
    }
}

