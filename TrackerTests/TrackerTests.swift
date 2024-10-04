//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Артур  Арсланов on 04.10.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testMainScreen() throws {
        let mainViewController = TrackersViewController()

        mainViewController.overrideUserInterfaceStyle = .light

        mainViewController.view.frame = UIScreen.main.bounds

        mainViewController.viewDidLoad()

        assertSnapshot(of: mainViewController, as: .image)
    }
}
