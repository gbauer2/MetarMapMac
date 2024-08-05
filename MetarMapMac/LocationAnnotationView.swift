//
//  LocationAnnotationView.swift
//  MetarMapMac
//
//  Created by George Bauer on 2024-08-03.
//

import Foundation
import MapKit

final class LocationAnnotationView: MKAnnotationView, Reusable {

    // MARK: Initialization

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)

        canShowCallout = true
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func setupUI() {
        backgroundColor = .clear

        let view = MapPinView()
        addSubview(view)

        view.frame = bounds
    }
}
