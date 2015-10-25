//
//  PhoneIdBaseView.swift
//  phoneid_iOS
//
//  Copyright 2015 phone.id - 73 knots, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


import Foundation

public class PhoneIdBaseView: UIView, Customizable, PhoneIdConsumer {

    public var phoneIdModel: NumberInfo!
    public var colorScheme: ColorScheme!
    public var localizationBundle: NSBundle!
    public var localizationTableName: String!

    init(model: NumberInfo, scheme: ColorScheme, bundle: NSBundle, tableName: String) {

        super.init(frame: CGRectZero)

        phoneIdModel = model
        colorScheme = scheme
        localizationBundle = bundle
        localizationTableName = tableName

        doOnInit()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func doOnInit() {
        setupSubviews()
        setupLayout()
        setupWithModel(self.phoneIdModel)
        localizeAndApplyColorScheme()
    }

    func setupSubviews() {

    }

    func setupLayout() {

    }

    func setupWithModel(model: NumberInfo) {
        self.phoneIdModel = model
    }

    func localizeAndApplyColorScheme() {

    }

    func closeButtonTapped() {

    }

}

public class PhoneIdBaseFullscreenView: PhoneIdBaseView {

    private(set) var closeButton: UIButton!
    private(set) var titleLabel: UILabel!
    private(set) var headerBackgroundView: UIView!
    private(set) var backgroundView: UIImageView!

    func backgroundImage() -> UIImage? {
        return phoneIdComponentFactory.defaultBackgroundImage
    }

    var customConstraints: [NSLayoutConstraint] = []

    override init(model: NumberInfo, scheme: ColorScheme, bundle: NSBundle, tableName: String) {
        super.init(model: model, scheme: scheme, bundle: bundle, tableName: tableName)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override func setupSubviews() {
        backgroundView = UIImageView()
        headerBackgroundView = UIView()
        closeButton = UIButton(type: .System)

        closeButton.addTarget(self, action: "closeButtonTapped", forControlEvents: .TouchUpInside)

        titleLabel = UILabel()

        let views = [backgroundView, headerBackgroundView, closeButton, titleLabel]
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }

    }

    override func setupLayout() {
        self.removeConstraints(self.customConstraints)
        self.customConstraints = []

        var c: [NSLayoutConstraint] = []

        c.append(NSLayoutConstraint(item: titleLabel, attribute: .CenterY, relatedBy: .Equal, toItem: headerBackgroundView, attribute: .CenterY, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 0.8, constant: 0))

        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 64))
        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: headerBackgroundView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: backgroundView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        c.append(NSLayoutConstraint(item: backgroundView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))

        c.append(NSLayoutConstraint(item: closeButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 10))
        c.append(NSLayoutConstraint(item: closeButton, attribute: .Baseline, relatedBy: .Equal, toItem: titleLabel, attribute: .Baseline, multiplier: 1, constant: 0))

        self.customConstraints = c
        self.addConstraints(c)
    }

    override func localizeAndApplyColorScheme() {
        super.localizeAndApplyColorScheme()
        closeButton.tintColor = colorScheme.headerButtonText
        closeButton.accessibilityLabel = localizedString("accessibility.button.title.cancel")
        closeButton.setTitle(localizedString("button.title.cancel"), forState: .Normal)
        headerBackgroundView.backgroundColor = colorScheme.headerBackground
        backgroundView.backgroundColor = colorScheme.mainViewBackground
        backgroundView.image = backgroundImage()
    }

}