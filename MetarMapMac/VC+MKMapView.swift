//
//  VC+MKMapView.swift
//  Garmitrk
//
//  Created by George Bauer on 8/22/21.
//  Copyright © 2021 GeorgeBauer. All rights reserved.
//

import Cocoa
import MapKit


protocol MapVCdelegate: AnyObject {
    func mapVCreturn(_ controller: ViewController, returnType: Int, waypointID: String, lat: Double, lon: Double)//delegate
    // mapReturnType=WP      waypointIDFromMap = ""  latFromMap = 0.0    lonFromMap = 0.0
    // mapReturnType=TrkPt      TrkPtIDFromMap = ""  latFromMap = 0.0    lonFromMap = 0.0   Alt  Date/Time Kts
}

//MARK: - MKMapViewDelegate Ext'n
extension ViewController: MKMapViewDelegate {

    struct LineParam {
        static var color = NSColor.blue
    }

    //MARK: - findNearestTrkPt
    //---------------------------------- StackOverflow - Find Clicked PolyLine ---------------------------------
    //https://stackoverflow.com/questions/11713788/how-to-detect-taps-on-mkpolylines-overlays-like-maps-app
    //This code detects click on polyLines with a max distance of 22 pixels in every zoom level.
    // Just point your UITapGestureRecognizer to handleTap
    

    

    // ---- Calc Max Meters from Max Pixels. Called by findNearestTrkPt
    func getMeters(fromPixels px: CGFloat, at pt: CGPoint) -> Double {
        guard let map = mapView else { return 0 }
        let ptDisplaced = CGPoint(x: pt.x + px, y: pt.y)
        let coordA: CLLocationCoordinate2D = map.convert(pt, toCoordinateFrom: map)
        let coordB: CLLocationCoordinate2D = map.convert(ptDisplaced, toCoordinateFrom: map)
        return MKMapPoint.init(coordA).distance(to: MKMapPoint.init(coordB))
    }//end func getMeters

    //MARK: - setupMap
    // ---- Called from viewDidLoad ----
    func setupMap() {

        // DUSTIN EDIT: added view controller as map view delegate
        mapView.delegate = self

        mapReturnType = 0       // ????? .none        // we have not yet picked anything

        mapView.showsUserLocation = false

        btnsegMapType.selectedSegment = 1        // Flyover
        mapView.mapType = .hybridFlyover

        resetExtents()
        displayLatLon(lat: mapCenterLat, lon: mapCenterLon)

        mapView.addAnnotations(userWaypoints.waypointAnnotations)
        drawMap(lat: mapCenterLat, lon: mapCenterLon, latDelt: mapDeltaLat, lonDelt: mapDeltaLon)

        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .activeAlways, .inVisibleRect]
        let tracker = NSTrackingArea(rect: mapView.frame, options: options, owner: mapView, userInfo: nil)
        mapView.addTrackingArea(tracker)
    }//end func setupMap

    // ---- Reset Map Extents to North America
    func resetExtents() {
        trkLog.latBotTrk = 20.0
        trkLog.latTopTrk = 70.0
        trkLog.lonRgtTrk = -50.0
        trkLog.lonLftTrk = -140.0
        scaleMapToTrk()
    }

    //MARK: ---- @IBActions ----

    @IBAction func btnZoomExtentsClick(_ sender: Any) {
        scaleMapToTrk()
    }

    @IBAction func chkAutoZoomClick(_ sender: Any) {
        if chkAutoZoom.state == .on {
            scaleMapToTrk()
        }
    }

    @IBAction func segmentedMapTypeChange(_ sender: Any) {
        if btnsegMapType.selectedSegment == 0 { mapView.mapType = .standard}
        if btnsegMapType.selectedSegment == 1 { mapView.mapType = .hybridFlyover}
    }



    @IBAction func popupCopyChange(_ sender: NSPopUpButton) {
        let item = sender.selectedItem?.title ?? "Unknown"
        print("🍎 VC+MKMapView#\(#line) popupCopyChange #\(sender.indexOfSelectedItem) \(item)")

        if item.contains(":") {
            // Place Lat/Lon in Clipboard (Pasteboard) for use in Google Earth, etc.
            let halves = item.components(separatedBy: ":")
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            let pasteStr = halves[1].trim
            pasteBoard.writeObjects([pasteStr as NSString])
            popupCopy.isHidden = true
            statusBarMap.stringValue = "Saved to Clipboard: " + halves[1]
        }
    }//end func

    // Toggle lblMapLatLon between Degs+Mins & digital Degs
    @IBAction func lblMapLatLonClick(_ sender: Any) {
        isDegMin.toggle()
        displayLatLon(lat: mapView.centerCoordinate.latitude, lon: mapView.centerCoordinate.longitude)
    }//end func

    // If statusBarMap contains "Click to Copy:", copy value to Clipboard
    //popupButton formats = same as.. 1 display, 2 userwaypoint, 3 trkfile, 4 GoogleMap
    @IBAction func statusBarMapClick(_ sender: Any) {
//        if statusBarMap.stringValue.starts(with: "Click to Copy:") {
//            // Place Lat/Lon in Clipboard (Pasteboard) for use in Google Earth, etc.
//            let half = statusBarMap.stringValue.components(separatedBy: ":")
//            let pasteBoard = NSPasteboard.general
//            pasteBoard.clearContents()
//            let pasteStr = half[1].trim
//            pasteBoard.writeObjects([pasteStr as NSString])
//            statusBarMap.stringValue = "Saved to Clipboard: " + half[1]
//        }
    }//end func


    //MARK: ---- General Map funcs ----

//    // called from aa1ListTrk (btnMakeFile), btnFileInfo
//    func updateGraphicsFromListTrk() {
//        if chkAutoZoom.state == .on { scaleMapToTrk() }
//        drawTrkLine(mapView: mapView)
//    }

    //---- Set the Map Scale & Center to display the entire Track ----
    public func scaleMapToTrk() {
        // Uses: trkLog.latTopTrk, trkLog.latBotTrk, trkLog.lonRgtTrk, trkLog.lonLftTrk
        mapCenterLat  = (trkLog.latTopTrk + trkLog.latBotTrk) / 2.0
        mapCenterLon  = (trkLog.lonRgtTrk + trkLog.lonLftTrk) / 2.0
        mapDeltaLat   = (trkLog.latTopTrk - trkLog.latBotTrk) * 1.1
        mapDeltaLon   = (trkLog.lonRgtTrk - trkLog.lonLftTrk) * 1.1
        drawMap(lat: mapCenterLat, lon: mapCenterLon, latDelt: mapDeltaLat, lonDelt: mapDeltaLon)
    }//end func

    // ---- Calculates region;  displays Map ----
    func drawMap(lat: Double, lon: Double, latDelt: Double, lonDelt: Double) {
        let latitude:    CLLocationDegrees = lat
        let longitude:   CLLocationDegrees = lon
        let mapDeltaLat: CLLocationDegrees = latDelt
        let mapDeltaLon: CLLocationDegrees = lonDelt

        let span     = MKCoordinateSpan(latitudeDelta: mapDeltaLat, longitudeDelta: mapDeltaLon)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region   = MKCoordinateRegion(center: location, span: span)

        mapView.showsScale = true
        mapView.setRegion(region, animated: true)
        mapView.acceptsFirstMouse(for: nil)
    }//end func

    func setZoomScale() {
        currentZoomScale = (mapView.bounds.size.width) / CGFloat(mapView.visibleMapRect.size.width)
        gIconSize = IconSize.small
        if currentZoomScale > 0.0015 { gIconSize = IconSize.medium }
        if currentZoomScale > 0.05   { gIconSize = IconSize.large }

        // If IconSize has changed, redraw the icons
        if gIconSize != gPrevIconSize {
            gPrevIconSize = gIconSize
            mapView.removeAnnotations(userWaypoints.waypointAnnotations)  // remove ALL previous WAYPOINT annotations
            mapView.addAnnotations(userWaypoints.waypointAnnotations)     // then add them back with current IconSize
        }
        // Display the new ZoomScale
        let z1000 = currentZoomScale*1000
        var format = "%4.2f"
        if z1000 >= 1.0 { format = "%4.1f" }
        if z1000 >= 10  { format = "%4.0f" }
        lblMap2.stringValue = "zoom \(String(format: format, z1000)) \(gIconSize)"
        // Display Center LatLon
        let mapCenterLat = mapView.centerCoordinate.latitude
        let mapCenterLon = mapView.centerCoordinate.longitude
        displayLatLon(lat: mapCenterLat, lon: mapCenterLon)
    }//end func setZoomScale

    //---- displayLatLon - Display Latitude & Longitude
    func displayLatLon(lat: Double, lon: Double) {
        lblMapLatLon.stringValue =  Gfunc.displayLatLon(lat: lat, lon: lon, isDegMin: isDegMin)
    }//end func

/*
    // DUSTIN EDITS: Draws Track Line using mapDeltaLat, mapDeltaLon
    func drawTrkLine(mapView: MKMapView) {  // 352-416 = 64-lines

        idxFirstPlottedTrk = 9999999
        idxLastPlottedTrk  = -1

        mapView.removeOverlays(mapView.overlays)            // remove previous TrackLines
        mapView.removeAnnotations(trkpointAnns)             // remove Trkpoint Annotations
        mapView.removeAnnotation(trkpointAnnSelected)       // remove selected Trackpoint Annotation
        trkpointAnns     = []                               // clear Trkpoint Annotations array
        idxTrkPtSelected = -1
        flightSegIdSel   = -1                // Change from =0 to fix bug re log_...csv file 2021-06-21 ver 5.7.2

        let isAllDates = !Gb.isNumeric(String(dateStrFromPopup.prefix(2)))   // "All" doesn't start with number
        var gotaPoint = false
        for (iFlt, flight) in flights.enumerated() {
            let thisDate = flight.startDate.ToString("MM/dd/yyyy")
            if iFlt > flights.count { print(" VC+MKMapView#\(#line) Flight \(iFlt) of \(flights.count) \(thisDate) ") } //TempPrint

            if isAllDates || thisDate == dateStrFromPopup {
                for phaseTaxiOrFly in flight.phasesTaxiOrFly {

                    let flightSegID = Int(flightSegIDfromPopup) ?? -1
                    if flightSegID < 0 || (flightSegID == phaseTaxiOrFly.flightSegID) {       //"All SegIDs" or this SegID
                        //print("VC+MKMapView#\(#line) Plotting Flight \(iFlt) of \(flights.count)")    //TempPrint
                        if phaseTaxiOrFly.idxFirst < idxFirstPlottedTrk { idxFirstPlottedTrk = phaseTaxiOrFly.idxFirst }
                        if phaseTaxiOrFly.idxLast  > idxLastPlottedTrk  { idxLastPlottedTrk  = phaseTaxiOrFly.idxLast  }

                        let trkPolyLine = TrackPolyline(coordinates: phaseTaxiOrFly.points, count: phaseTaxiOrFly.points.count)
                        trkPolyLine.color      = phaseTaxiOrFly.wasFlying ? NSColor.blue : NSColor.magenta
                        trkPolyLine.lineWidth  = 2.5
                        trkPolyLine.flightSegID   = phaseTaxiOrFly.flightSegID
                        trkPolyLine.idxFirst   = phaseTaxiOrFly.idxFirst
                        trkPolyLine.idxLast    = phaseTaxiOrFly.idxLast
                        trkPolyLine.idxFlightFirst = flight.idxFirst
                        trkPolyLine.idxFlightLast  = flight.idxLast
                        mapView.addOverlay(trkPolyLine)

                        for point in phaseTaxiOrFly.points {
                            if !gotaPoint {
                                gotaPoint = true
                                trkLog.latTopTrk = point.latitude      // Set bounds for plot
                                trkLog.latBotTrk = point.latitude
                                trkLog.lonRgtTrk = point.longitude
                                trkLog.lonLftTrk = point.longitude
                            }
                            if point.latitude  > trkLog.latTopTrk { trkLog.latTopTrk = point.latitude  }// Set bounds for plot
                            if point.latitude  < trkLog.latBotTrk { trkLog.latBotTrk = point.latitude  }
                            if point.longitude > trkLog.lonRgtTrk { trkLog.lonRgtTrk = point.longitude }
                            if point.longitude < trkLog.lonLftTrk { trkLog.lonLftTrk = point.longitude }
                        }//next point
                    }//endif flghtSeg

                }//next phaseTaxiOrFly
            }//endif dateStrFromPopup
        }//next flight
        print("🏄‍♂️ VC+MKMapView#\(#line) plotted range \(idxFirstPlottedTrk) - \(idxLastPlottedTrk)")
        if trkLog.latTopTrk < -999 {
            print("⛔️ VC+MKMapView#\(#line) Error VC+MKMapView#\(#line) drawTrkLine: No-Trk-Found.")
        } else {
            popupDates.isHidden  = popupDates.numberOfItems <= 2
            txtDates.isHidden    = popupDates.isHidden
        }
        //        let trkPolyLine = TrackPolyline(coordinates: coords, count: coords.count)
        //        mapView.add(trkPolyLine)
    }//end func drawTrkLine
*/


    //MARK: ---- mapView delegates ----

    // ---- built-in "viewFor" is run whenever an annotation is to be displayed ----
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // 2 Check whether the annotation we're creating a view for is one of our WaypointAnnotation objects.
        if annotation is WaypointAnnotation {
            guard let ann = annotation as? WaypointAnnotation else { return nil }
            // 1 Define a reuse identifier. This will be used to ensure we reuse annotation views as much as possible.
            var identifier = "Waypt"
            identifier += ann.wpType    // append "A", "L", etc. to reuse identifier
            let image: NSImage
            if gIconSize == IconSize.large {    // pick the appropiate size image & append "Lrg", "Med", or "Sml" to identifier
                image = ann.imageLarge
                identifier += "Lrg"
            } else if gIconSize == IconSize.medium {
                image = ann.imageMedium
                identifier += "Med"
            } else {
                image = ann.imageSmall
                identifier += "Sml"
            }

            // 3 Try to dequeue an annotation view from the map view's pool of unused views.
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                //4 If it isn't able to find a reusable view, create a new one using MKAnnotationView,
                //print("🌝 VC+MKMapView#\(#line) annotation = \(annotation.title!) \(annotation.subtitle!)")
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.image = image
                annotationView?.canShowCallout = false

                // 5 Create a Button using built-in .detailDisclosure type (small blue "i" symbol with a circle around it).
                //   Does not work with macOS!
                //                let btn = NSButton(type: .annotation)//.detailDisclosure
                //                annotationView!.rightCalloutAccessoryView = btn

            } else {
                // 6 If it can reuse a view, update that view to use a different annotation.
                annotationView?.annotation = annotation
                annotationView?.image = image
            }
            return annotationView

//        } else if annotation is TrackpointAnnotation {
//            // 1 Define a reuse identifier. This will be used to ensure we reuse annotation views as much as possible.
//            let identifier = "Trkpt"
//            guard let ann = annotation as? TrackpointAnnotation else { return nil }
//            let image = ann.image
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            if annotationView == nil {
//                //4 If it isn't able to find a reusable view, create a new one using MKAnnotationView,
//                // and sets its canShowCallout property to true.  This triggers the popup with the name.
//                //print("🌝 VC+MKMapView#\(#line) annotation = \(annotation.title!) \(annotation.subtitle!)")
//                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                annotationView?.image = image
//                annotationView?.canShowCallout = false
//
//                // 5 Create a Button using built-in .detailDisclosure type (small blue "i" symbol in a circle).
//                //   Does not work with macOS!
//                //                let btn = NSButton(type: .annotation)//.detailDisclosure
//                //                annotationView!.rightCalloutAccessoryView = btn
//
//            } else {
//                // 6 If it can reuse a view, update that view to use a different annotation.
//                annotationView?.annotation = annotation
//                annotationView?.image = image
//            }
//            return annotationView
//
        }//endif annotation is

        // 7 If the annotation isn't from a WaypointAnnotation, it must return nil so iOS uses a default view.
        return nil
    }//end func mapView(viewFor annotation:)

    
    // mapView( annotationView view ------ Handles detailDisclosure button on waypointPin ------
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: NSControl) {
        //        let waypointPin = view.annotation as! WaypointPin
        //        let title = waypointPin.title
        //        let info  = waypointPin.info
        //        let alertController = NSAlert(title: title, message: info, preferredStyle: .alert)
        //        alertController.addAction(NSAlertAction(title: "OK", style: .default))
        //        present(alertController, animated: true)
    }//end func

    // mapView( didSelect ---- Handles Click (LongPress) on Map Waypoint ----
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let optionalTitle = view.annotation?.title, let title = optionalTitle {
        //if let title = view.annotation?.title as? String { // Warning: Conditional downcast from 'String?' to 'String' does nothing
            print("😃 VC+MKMapView#\(#line) User tapped on annotation with title: \(title)")
            if title != "My Location" {
                waypointIDFromMap = title
                //lblSelected.stringValue = waypointIDFromMap
                mapReturnType = 1       // ????? .waypoint
                //btnSaveLoc.isEnabled = true
            }
        }//endif let title
    }//end func

    // Debug Messages
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        //print("😍😍 VC+MKMapView#\(#line) mapView WillStartLoadingMap 😍😍")
    }

    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        //print("😍😍 VC+MKMapView#\(#line) mapView DidFinishLoadingMap 😍😍")
        setZoomScale()
    }

    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("\n😡😡 VC+MKMapView#\(#line) Start mapView DidFailLoadingMap 😡😡\n")
        print("\(error)\n")
        print("😡😡 End mapView DidFailLoadingMap 😡😡\n")
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("😍😍 VC+MKMapView#\(#line) mapView regionDidChangeAnimated 😍😍")
        setZoomScale()
    }

    //        //---- MKMapView, viewFor annotation: MKAnnotation - Custom icon
    //        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //            if annotation is MKUserLocation {
    //                return nil
    //            } else {
    //                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
    //                annotationView.image = NSImage(named: "place icon")
    //                return annotationView
    //            }
    //        }//end func

//    // mapView(rendererFor overlay ---- Draw the TrkPolyline overlay ----
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        // DUSTIN EDIT: Draw the TrkPolyline if the overlay is an TrkPolyline
//        if overlay is TrackPolyline {
//            guard let polyline = overlay as? TrackPolyline else {
//                fatalError("⛔️ VC+MKMapView#\(#line) This should never happen!")
//            }
//            let lineRenderer = MKPolylineRenderer(overlay: polyline)
//            lineRenderer.strokeColor = polyline.color
//            lineRenderer.lineWidth = polyline.lineWidth
//            //print("🤠 VC+MKMapView#\(#line) Rendering line for overlay: \(overlay)")
//            return lineRenderer
//        }//endif TrackPolyline
//        fatalError("⛔️ VC+MKMapView#\(#line) This should never happen!  There is an overlay besides TrackPolyline")
//    }//end func mapView rendererFor

    func windowDidResize(_ notification: Notification) {
        // This will print the window's size each time it is resized.
        // print(view.window?.frame.size)
        // setZoomScale()
    }

/*
    //---- showTrkPt - Shows Annotation & statusBarMap - Called from MouseUp & nextOrPrevTrkPt
    func showTrkPt(idx: Int, showOnMap: Bool) {
        let trkPt   = trkLog.trkPoints[idx]
        let pt      = idx - idxFirstTrkID + 1
        let range   = idxLastTrkID - idxFirstTrkID + 1
        let time    = trkPt.date.ToString("MM/dd/yyyy HH:mm:ss")
        let dirStr  = Gb.formatIntWithLeadingZeros(trkPt.lineSegDir, width: 3)
        let ktStr   = formatInt(trkPt.lineSegKts, wid: 3)
        let fpm     = trkPt.lineSegClimbRate
        let fpmD    = (Double(fpm)/100.0).rounded()
        let fpmRnd  = Int(fpmD * 100.0)
        let fpmStr  = formatInt(fpmRnd, wid: 4)
        if fpm != fpmRnd {
            //
        }
        let altStr  = formatInt(trkPt.alt, wid: 5)
        let trkID = trkPt.trkType == .baseCamp ? trkPt.trkIDfromFile: trkPt.flightSegID
        popupCopy.isHidden = true
        statusBarMap.stringValue = "(\(pt) of \(range)) ID=\(trkID) \(trkPt.sequence)  \(time)  \(dirStr)° \(ktStr) kt  \(altStr) ft \(fpmStr) fpm"
        hideTrkPt(false)
        mapView.removeAnnotation(trkpointAnnSelected)
        trkpointSelected = trkPt
        if !showOnMap { return }
        
        trkpointAnnSelected = TrackpointAnnotation(
                                    title:      "",
                                    subtitle:   "",
                                    coordinate: CLLocationCoordinate2D(latitude: trkPt.lat, longitude: trkPt.lon),
                                    info:       "",
                                    image:      NSImage(imageLiteralResourceName: "myDot14")
                                    )
        mapView.addAnnotation(trkpointAnnSelected)
    }//end func showTrkPt
*/


    //MARK: - Mouse Overrides

    override func mouseMoved(with event: NSEvent) {
        if mouseIsInMap {
            let mapPtCG    = mapView.convert(event.locationInWindow, from: nil)    // Screen coords to mapView coords
            let mapCoord2D = mapView.convert(mapPtCG, toCoordinateFrom: mapView)   // mapView coords to Lat/Lon
            displayLatLon(lat: mapCoord2D.latitude, lon: mapCoord2D.longitude)
        }
        //super.mouseMoved(with: event)
    }//end func

    // If Mouse is in map, display Cursor Coordinates (in mouseMoved)
    override func mouseEntered(with event: NSEvent) {
        mouseIsInMap = true
    }

    // If Mouse not in map, display Center Coordinates
    override func mouseExited(with event: NSEvent) {
        displayLatLon(lat: mapView.centerCoordinate.latitude, lon: mapView.centerCoordinate.longitude)
        mouseIsInMap = false
    }

    override func mouseDown(with event: NSEvent) {
        //let locationInView = mapView.convert(event.locationInWindow, from: nil)
        //lblMap2.stringValue = "mouseDown \(Int(locationInView.x)), \(Int(locationInView.y))"
        super.mouseDown(with: event)
    }

    override func mouseUp(with event: NSEvent) {        // 618-727 = 109-lines
        if !mouseIsInMap { return }         // Not on Map.

        let clickedMapPtCG = mapView.convert(event.locationInWindow, from: nil) // Screen coords to mapView coords
        let clickedCoord2D = mapView.convert(clickedMapPtCG, toCoordinateFrom: mapView) // mapView coords to Lat/Lon

        // Get closest *TrackPoint*
//        idxClosestTrkPt = findNearestTrkPt(touchPt: clickedMapPtCG)
        let idxClosestTrkPt = -1
        if idxClosestTrkPt >= 0 {                           // If we found one
//            let closestTP = trkLog.trkPoints[idxClosestTrkPt]
//            print("➡️ VC+MKMapView#\(#line) flightSegID = \(closestTP.flightSegID)")
//            if closestTP.flightSegID != flightSegIdSel {
//                idxTrkPtSelected = idxClosestTrkPt
//                trkpointSelected = closestTP
//                flightSegIdSel      = closestTP.flightSegID
//                mapView.removeAnnotations(trkpointAnns)    // remove all previous trkpoint annotations
//                trkpointAnns = []
//                idxFirstTrkID = idxTrkPtSelected
//                idxLastTrkID  = idxTrkPtSelected
//                for idx in idxFirstPlottedTrk...idxLastPlottedTrk {
//                    let trkPt = trkLog.trkPoints[idx]
//                    if trkPt.flightSegID == flightSegIdSel {
//                        let ann = TrackpointAnnotation(title: "", subtitle: "", coordinate: CLLocationCoordinate2D(latitude: trkPt.lat, longitude: trkPt.lon), info: "", image: NSImage(imageLiteralResourceName: "myDot10"))
//                        trkpointAnns.append(ann)
//                        if idx < idxFirstTrkID { idxFirstTrkID = idx }
//                        if idx > idxLastTrkID  { idxLastTrkID  = idx }
//                    }
//                }//next idx
//                mapView.addAnnotations(trkpointAnns)
//
//                // Make Selected trkPoint icon different (larger)
//                mapView.removeAnnotation(trkpointAnnSelected)
//                let trkPt = trkpointSelected
//                trkpointAnnSelected = TrackpointAnnotation(title: "", subtitle: "", coordinate: CLLocationCoordinate2D(latitude: trkPt.lat, longitude: trkPt.lon), info: "", image: NSImage(imageLiteralResourceName: "myDot14"))
//                mapView.addAnnotation(trkpointAnnSelected)
//            }//endif closestTP
//            print("✅ VC+MKMapView#\(#line) \(closestTP)")
//            showTrkPt(idx: idxClosestTrkPt, showOnMap: true)

        } else {    // idxClosestTrkPt < 0
            let lat = clickedCoord2D.latitude
            let lon = clickedCoord2D.longitude
            let labelLL = Gb.formatF(lat, "%.1f") + "/" + Gb.formatF(abs(lon), "%.1f")
            let genericPasteStr = lblMapLatLon.stringValue
//            let trkLogPasteStr = Gfunc.clipboardLatLon(lat: lat, lon: lon, isDegMin: isDegMin, trkLog: trkLog)
            let userWpPasteStr =  "\(String(format: "%7.4f", lat)) ,\(String(format: "%8.4f", abs(lon)))"

//            //popupCopy.title = "Click to Copy:" + pasteStr
//            popupCopy.removeAllItems()
//            popupCopy.addItem(withTitle: "Select to Copy Lat/lon (\(labelLL))")
//            popupCopy.addItem(withTitle: "Generic:   " + genericPasteStr)
//            popupCopy.addItem(withTitle: "UserWaypt: " + userWpPasteStr)
//            popupCopy.addItem(withTitle: "trkLog:    " + trkLogPasteStr)
//            popupCopy.isHidden = false
        }//endif idxClosestTrkPt < 0

        // Get closest *WayPoint*
        var distClosestWP: CGFloat = 10
        switch gIconSize {
        case .large:
            distClosestWP = 20
        case .medium:
            distClosestWP = 15
        default:
            distClosestWP = 10
        }
        let image = NSImage(imageLiteralResourceName: "ap12")
        var closestWP  = WaypointAnnotation(title: "", subtitle: "",
                                            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                            wpType: "?", elev: 0, radiusNM: 0, state: "",
                                            imageSmall: image, imageMedium: image, imageLarge: image)
        var gotCloseWP = false

        for waypt in userWaypoints.waypointAnnotations {
            let from            = waypt.coordinate
            let wayPtCG:CGPoint = mapView.convert(from, toPointTo: mapView)
            let distanceCG      = hypot(wayPtCG.x - clickedMapPtCG.x, wayPtCG.y - clickedMapPtCG.y)
            if distanceCG < distClosestWP {
                gotCloseWP      = true
                closestWP       = waypt
                distClosestWP   = distanceCG
            }
        }//next waypt

        if gotCloseWP {
            print("✅ VC+MKMapView#\(#line) \(closestWP)")
            let wpID   = closestWP.title ?? "???"
            var wpName = closestWP.subtitle ?? ""
            var wpType = closestWP.wpType

            if wpName.isEmpty {
                if wpType == "A" {
                    wpType = ""
                    wpName += " Airport"
                    let key = "K" + wpID    // If airports is in "MyAirports.txt"
                    if let ap = allAirports.dictByID[key] {
                        wpName = "*" + ap.name  // then use that name
                    }
                }
            } else {
                if wpType == "A" {
                    wpType = ""
                    if !wpName.contains("Airport") {
                        wpName += " Airport"
                    }
                } else if  wpType == "L" {
                    wpType = ""
                    if !wpName.contains("Lake") && !wpName.contains("Pond")  && !wpName.contains("Reservoir")  && !wpName.contains("River") &&
                        !wpName.contains("Beach"){
                        wpName += " Lake"
                    }
                }//end "A" or "L"
            }//end Not noName

            if wpType.count == 1 {wpType = "\"\(wpType)\""}
            lblLocation.stringValue = "\(wpID)  \(wpType) \(wpName)  \(closestWP.state)"

        } else {
            lblLocation.stringValue = "---"
        }
    }//end func mouseUp

}//end extension ViewController: MKMapViewDelegate
