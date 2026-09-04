/// RectangleTests.swift

import Carbon.HIToolbox
import MASShortcut
import XCTest
@testable import Rectangle

class RectangleTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }
}

final class ShippingDefaultProfileTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "ShippingDefaultProfileTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testEveryCanonicalShortcutHasExactKeyCodeAndModifiers() throws {
        let expected: [String: (keyCode: Int, modifierFlags: UInt)] = [
            "leftHalf": (123, 1_835_008), "rightHalf": (124, 1_835_008),
            "centerHalf": (87, 1_835_008), "topHalf": (126, 1_966_080),
            "bottomHalf": (125, 1_966_080), "topLeft": (32, 786_432),
            "bottomLeft": (38, 786_432), "bottomRight": (40, 786_432),
            "maximize": (126, 1_835_008), "smaller": (27, 786_432),
            "larger": (24, 786_432), "center": (46, 1_835_008),
            "restore": (51, 786_432), "nextDisplay": (124, 786_432),
            "previousDisplay": (123, 786_432), "firstThird": (18, 1_835_008),
            "centerThird": (19, 1_835_008), "lastThird": (20, 1_835_008),
            "firstTwoThirds": (21, 1_835_008), "lastTwoThirds": (22, 1_835_008),
            "lastFourth": (119, 1_835_008), "firstThreeFourths": (89, 1_835_008),
            "lastThreeFourths": (92, 1_835_008), "topLeftSixth": (21, 1_966_080),
            "topCenterSixth": (23, 1_966_080), "topRightSixth": (22, 1_966_080),
            "bottomLeftSixth": (26, 1_966_080), "bottomCenterSixth": (28, 1_966_080),
            "bottomRightSixth": (25, 1_966_080)
        ]

        XCTAssertEqual(ShippingDefaultProfile.shortcutByDefaultsKey.count, expected.count)
        for (defaultsKey, identity) in expected {
            let shortcut = try XCTUnwrap(ShippingDefaultProfile.shortcutByDefaultsKey[defaultsKey], defaultsKey)
            XCTAssertEqual(shortcut.keyCode, identity.keyCode, defaultsKey)
            XCTAssertEqual(shortcut.modifierFlags, identity.modifierFlags, defaultsKey)
        }
    }

    func testCanonicalShortcutsAreUnique() {
        let identities = ShippingDefaultProfile.shortcutByDefaultsKey.values.map {
            "\($0.keyCode):\($0.modifierFlags)"
        }
        XCTAssertEqual(Set(identities).count, identities.count)
    }

    func testApplyStoresAssignmentsAndLeavesEveryOtherWindowActionUnassigned() throws {
        ShippingDefaultProfile.apply(to: userDefaults)

        for (defaultsKey, expected) in ShippingDefaultProfile.shortcutByDefaultsKey {
            let actual = try XCTUnwrap(ShortcutCycle.shortcut(forDefaultsKey: defaultsKey, userDefaults: userDefaults))
            XCTAssertEqual(actual.keyCode, expected.keyCode, defaultsKey)
            XCTAssertEqual(actual.modifierFlags.rawValue, expected.modifierFlags, defaultsKey)
        }
        for action in ShippingDefaultProfile.intentionallyUnassignedWindowActions {
            XCTAssertEqual(userDefaults.dictionary(forKey: action.name)?.count, 0, action.name)
            XCTAssertNil(ShortcutCycle.shortcut(for: action, userDefaults: userDefaults), action.name)
        }
    }

    func testApplyStoresSnapAndGeneralProfile() throws {
        ShippingDefaultProfile.apply(to: userDefaults)

        XCTAssertTrue(userDefaults.bool(forKey: "launchOnLogin"))
        XCTAssertEqual(userDefaults.integer(forKey: "shippingDefaultProfileVersion"), ShippingDefaultProfile.version)
        XCTAssertFalse(userDefaults.bool(forKey: "hideMenubarIcon"))
        XCTAssertEqual(userDefaults.integer(forKey: "subsequentExecutionMode"), SubsequentExecutionMode.acrossMonitor.rawValue)
        XCTAssertFalse(userDefaults.bool(forKey: "allowAnyShortcut"))
        XCTAssertEqual(userDefaults.integer(forKey: "windowSnapping"), 1)
        XCTAssertEqual(userDefaults.integer(forKey: "unsnapRestore"), 1)
        XCTAssertEqual(userDefaults.float(forKey: "footprintAnimationDurationMultiplier"), 0.75, accuracy: 0.001)
        XCTAssertEqual(userDefaults.integer(forKey: "hapticFeedbackOnSnap"), 1)
        XCTAssertEqual(userDefaults.float(forKey: "gapSize"), 0)
        XCTAssertFalse(userDefaults.bool(forKey: "skipGapTopEdge"))
        XCTAssertEqual(userDefaults.integer(forKey: "moveCursorAcrossDisplays"), 1)
        XCTAssertEqual(userDefaults.integer(forKey: "doubleClickTitleBar"), 0)
        XCTAssertTrue(userDefaults.bool(forKey: "greenButtonOverride"))
        XCTAssertNil(userDefaults.object(forKey: "stageSize"))

        let landscape: [Directional: SnapAreaConfig] = try decodeJSONDefault("landscapeSnapAreas")
        assertSnap(landscape, .tl, action: .topLeft)
        assertSnap(landscape, .t, action: .maximize)
        assertSnap(landscape, .tr, action: .topRight)
        assertSnap(landscape, .l, action: .leftHalf)
        assertSnap(landscape, .r, compound: .rightTopBottomHalf)
        assertSnap(landscape, .bl, action: .bottomLeft)
        assertSnap(landscape, .b, compound: .thirds)
        assertSnap(landscape, .br, action: .bottomRight)

        let portrait: [Directional: SnapAreaConfig] = try decodeJSONDefault("portraitSnapAreas")
        assertSnap(portrait, .tl, action: .topLeft)
        assertSnap(portrait, .t, action: .maximize)
        assertSnap(portrait, .tr, action: .topRight)
        assertSnap(portrait, .l, compound: .portraitThirdsSide)
        assertSnap(portrait, .r, compound: .portraitThirdsSide)
        assertSnap(portrait, .bl, action: .bottomLeft)
        assertSnap(portrait, .b, compound: .halves)
        assertSnap(portrait, .br, action: .bottomRight)
    }

    func testRetiredStageAndExtrasDefaultsAreRemoved() {
        let keys = [
            "stageSize", "dragFromStage", "alwaysAccountForStage",
            "widthStepSize", "showAdditionalSizesInMenu", "showEighthsInMenu",
            "cyclingOverlapOffset", "cyclingOverlapOffsetSize", "cyclingOverlapMaxCascade",
            "stackBadge", "toggleStackBadge", "halvesPreserveOtherAxisSize",
            "horizontalSplitRatio", "verticalSplitRatio"
        ] + WindowAction.retiredExtras.map(\.name)
        keys.forEach { userDefaults.set("legacy", forKey: $0) }

        ShippingDefaultProfile.removeRetiredFeatureDefaults(from: userDefaults)

        keys.forEach { XCTAssertNil(userDefaults.object(forKey: $0), $0) }
        XCTAssertTrue(Set(WindowAction.active).isDisjoint(with: WindowAction.retiredExtras))
        WindowAction.retiredExtras.forEach {
            XCTAssertNil(WindowCalculationFactory.calculationsByAction[$0], $0.name)
        }
    }

    func testFreshInstallGateAppliesOnce() throws {
        XCTAssertTrue(ShippingDefaultProfile.applyIfFreshInstall(to: userDefaults, persistentDomainName: suiteName))
        userDefaults.set("custom", forKey: "leftHalf")

        XCTAssertFalse(ShippingDefaultProfile.applyIfFreshInstall(to: userDefaults, persistentDomainName: suiteName))
        XCTAssertEqual(userDefaults.string(forKey: "leftHalf"), "custom")
    }

    func testOrdinaryUpgradePreservesExistingPreferences() {
        userDefaults.set("99", forKey: "lastVersion")
        userDefaults.set(["com.example.custom"], forKey: "disabledApps")
        userDefaults.set(["custom": "shortcut"], forKey: WindowAction.leftHalf.name)
        userDefaults.set(Float(27), forKey: "gapSize")
        userDefaults.set(false, forKey: "launchOnLogin")

        XCTAssertFalse(ShippingDefaultProfile.applyIfFreshInstall(to: userDefaults, persistentDomainName: suiteName))
        XCTAssertEqual(userDefaults.array(forKey: "disabledApps") as? [String], ["com.example.custom"])
        XCTAssertEqual(userDefaults.dictionary(forKey: WindowAction.leftHalf.name)?["custom"] as? String, "shortcut")
        XCTAssertEqual(userDefaults.float(forKey: "gapSize"), 27)
        XCTAssertFalse(userDefaults.bool(forKey: "launchOnLogin"))
    }

    func testNonemptyCandidateDomainWithoutVersionMarkerIsNotTreatedAsFresh() {
        userDefaults.set(["com.example.custom"], forKey: "disabledApps")

        XCTAssertFalse(ShippingDefaultProfile.applyIfFreshInstall(to: userDefaults, persistentDomainName: suiteName))
        XCTAssertNil(userDefaults.object(forKey: WindowAction.leftHalf.name))
        XCTAssertNil(userDefaults.object(forKey: "launchOnLogin"))
    }

    func testExplicitApplyRestoresMutatedProfileAndCodableRoundTripIsLossless() throws {
        userDefaults.set(["custom": "shortcut"], forKey: WindowAction.topRight.name)
        userDefaults.set(Float(44), forKey: "gapSize")
        ShippingDefaultProfile.apply(to: userDefaults)

        XCTAssertEqual(userDefaults.dictionary(forKey: WindowAction.topRight.name)?.count, 0)
        XCTAssertEqual(userDefaults.float(forKey: "gapSize"), 0)

        let config = Config(
            bundleId: "com.serp.windowmanager",
            version: "ShippingDefaultProfileTests",
            shortcuts: ShippingDefaultProfile.shortcutByDefaultsKey,
            defaults: [
                "shippingDefaultProfileVersion": CodableDefault(int: ShippingDefaultProfile.version),
                "launchOnLogin": CodableDefault(bool: userDefaults.bool(forKey: "launchOnLogin")),
                "landscapeSnapAreas": CodableDefault(string: userDefaults.string(forKey: "landscapeSnapAreas")),
                "portraitSnapAreas": CodableDefault(string: userDefaults.string(forKey: "portraitSnapAreas"))
            ]
        )
        let decoded = try JSONDecoder().decode(Config.self, from: JSONEncoder().encode(config))
        XCTAssertEqual(decoded.shortcuts.count, ShippingDefaultProfile.shortcutByDefaultsKey.count)
        for (key, expected) in ShippingDefaultProfile.shortcutByDefaultsKey {
            XCTAssertEqual(decoded.shortcuts[key]?.keyCode, expected.keyCode, key)
            XCTAssertEqual(decoded.shortcuts[key]?.modifierFlags, expected.modifierFlags, key)
        }
        XCTAssertEqual(decoded.defaults["landscapeSnapAreas"]?.string, userDefaults.string(forKey: "landscapeSnapAreas"))
        XCTAssertEqual(decoded.defaults["portraitSnapAreas"]?.string, userDefaults.string(forKey: "portraitSnapAreas"))
    }

    private func decodeJSONDefault<T: Decodable>(_ key: String) throws -> T {
        let string = try XCTUnwrap(userDefaults.string(forKey: key))
        return try JSONDecoder().decode(T.self, from: Data(string.utf8))
    }

    private func assertSnap(_ map: [Directional: SnapAreaConfig],
                            _ direction: Directional,
                            action: WindowAction? = nil,
                            compound: CompoundSnapArea? = nil,
                            file: StaticString = #filePath,
                            line: UInt = #line) {
        XCTAssertEqual(map[direction]?.action, action, file: file, line: line)
        XCTAssertEqual(map[direction]?.compound, compound, file: file, line: line)
    }
}

final class ShippingDefaultProfileUIReloadTests: XCTestCase {
    func testSnapAreaToggleReloadReflectsResetDefaultsImmediately() {
        let saved: [(Default, CodableDefault)] = [
            (Defaults.windowSnapping, Defaults.windowSnapping.toCodable()),
            (Defaults.unsnapRestore, Defaults.unsnapRestore.toCodable()),
            (Defaults.footprintAnimationDurationMultiplier, Defaults.footprintAnimationDurationMultiplier.toCodable()),
            (Defaults.hapticFeedbackOnSnap, Defaults.hapticFeedbackOnSnap.toCodable()),
            (Defaults.missionControlDragging, Defaults.missionControlDragging.toCodable())
        ]
        defer { saved.forEach { $0.0.load(from: $0.1) } }

        Defaults.windowSnapping.enabled = true
        Defaults.unsnapRestore.enabled = true
        Defaults.footprintAnimationDurationMultiplier.value = 0.75
        Defaults.hapticFeedbackOnSnap.enabled = true
        Defaults.missionControlDragging.enabled = nil

        let controller = SnapAreaViewController()
        let windowSnappingCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        let unsnapRestoreButton = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        let animateFootprintCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        let hapticFeedbackCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        let missionControlDraggingCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)
        controller.windowSnappingCheckbox = windowSnappingCheckbox
        controller.unsnapRestoreButton = unsnapRestoreButton
        controller.animateFootprintCheckbox = animateFootprintCheckbox
        controller.hapticFeedbackCheckbox = hapticFeedbackCheckbox
        controller.missionControlDraggingCheckbox = missionControlDraggingCheckbox

        controller.reloadToggleStates()

        XCTAssertEqual(windowSnappingCheckbox.state, .on)
        XCTAssertEqual(unsnapRestoreButton.state, .on)
        XCTAssertEqual(animateFootprintCheckbox.state, .on)
        XCTAssertEqual(hapticFeedbackCheckbox.state, .on)
        XCTAssertEqual(missionControlDraggingCheckbox.state, .off)
        XCTAssertTrue(missionControlDraggingCheckbox.isHidden)
    }
}

final class TodoRemovalTests: XCTestCase {
    func testShippingProfileContainsNoTodoShortcuts() {
        XCTAssertNil(ShippingDefaultProfile.shortcutByDefaultsKey["toggleTodo"])
        XCTAssertNil(ShippingDefaultProfile.shortcutByDefaultsKey["reflowTodo"])
    }

    func testActiveWindowActionsContainNoTodoActions() {
        let activeNames = Set(WindowAction.active.map(\.name))
        XCTAssertFalse(activeNames.contains("leftTodo"))
        XCTAssertFalse(activeNames.contains("rightTodo"))
    }

    func testExportedDefaultsContainNoTodoPersistenceKeys() {
        let exportedKeys = Set(Defaults.array.map(\.key))
        XCTAssertFalse(exportedKeys.contains("todo"))
        XCTAssertFalse(exportedKeys.contains("todoMode"))
        XCTAssertFalse(exportedKeys.contains("todoApplication"))
        XCTAssertFalse(exportedKeys.contains("todoSidebarWidth"))
        XCTAssertFalse(exportedKeys.contains("todoSidebarWidthUnit"))
        XCTAssertFalse(exportedKeys.contains("todoSidebarSide"))
    }

    func testRetiredTodoPersistenceIsRemoved() {
        let suiteName = "TodoRemovalTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let retiredKeys = [
            "todo", "todoMode", "todoApplication", "todoSidebarWidth",
            "todoSidebarWidthUnit", "todoSidebarSide", "toggleTodo", "reflowTodo"
        ]
        retiredKeys.forEach { userDefaults.set("legacy", forKey: $0) }

        ShippingDefaultProfile.removeRetiredTodoDefaults(from: userDefaults)

        retiredKeys.forEach { XCTAssertNil(userDefaults.object(forKey: $0), $0) }
    }
}

class PositionCyclesTests: XCTestCase {

    func testSixthsReturnTrue() {
        XCTAssertTrue(WindowAction.topLeftSixth.positionCycles)
        XCTAssertTrue(WindowAction.topCenterSixth.positionCycles)
        XCTAssertTrue(WindowAction.topRightSixth.positionCycles)
        XCTAssertTrue(WindowAction.bottomLeftSixth.positionCycles)
        XCTAssertTrue(WindowAction.bottomCenterSixth.positionCycles)
        XCTAssertTrue(WindowAction.bottomRightSixth.positionCycles)
    }

    func testEighthsReturnTrue() {
        XCTAssertTrue(WindowAction.topLeftEighth.positionCycles)
        XCTAssertTrue(WindowAction.topCenterLeftEighth.positionCycles)
        XCTAssertTrue(WindowAction.bottomRightEighth.positionCycles)
    }

    func testNinthsReturnTrue() {
        XCTAssertTrue(WindowAction.topLeftNinth.positionCycles)
        XCTAssertTrue(WindowAction.middleCenterNinth.positionCycles)
        XCTAssertTrue(WindowAction.bottomRightNinth.positionCycles)
    }

    func testTwelfthsReturnTrue() {
        XCTAssertTrue(WindowAction.topLeftTwelfth.positionCycles)
        XCTAssertTrue(WindowAction.middleCenterLeftTwelfth.positionCycles)
        XCTAssertTrue(WindowAction.bottomRightTwelfth.positionCycles)
    }

    func testSixteenthsReturnTrue() {
        XCTAssertTrue(WindowAction.topLeftSixteenth.positionCycles)
        XCTAssertTrue(WindowAction.upperMiddleCenterLeftSixteenth.positionCycles)
        XCTAssertTrue(WindowAction.lowerMiddleRightSixteenth.positionCycles)
        XCTAssertTrue(WindowAction.bottomRightSixteenth.positionCycles)
    }

    func testGridPositionsReturnTrue() {
        XCTAssertTrue(WindowAction.leftHalf.positionCycles)
        XCTAssertTrue(WindowAction.rightHalf.positionCycles)
        XCTAssertTrue(WindowAction.topLeft.positionCycles)
        XCTAssertTrue(WindowAction.bottomRight.positionCycles)
        XCTAssertTrue(WindowAction.firstThird.positionCycles)
        XCTAssertTrue(WindowAction.lastThird.positionCycles)
        XCTAssertTrue(WindowAction.firstFourth.positionCycles)
        XCTAssertTrue(WindowAction.topHalf.positionCycles)
        XCTAssertTrue(WindowAction.bottomHalf.positionCycles)
    }

    func testNonPositionalActionsReturnFalse() {
        XCTAssertFalse(WindowAction.maximize.positionCycles)
        XCTAssertFalse(WindowAction.maximizeHeight.positionCycles)
        XCTAssertFalse(WindowAction.almostMaximize.positionCycles)
        XCTAssertFalse(WindowAction.center.positionCycles)
        XCTAssertFalse(WindowAction.centerProminently.positionCycles)
        XCTAssertFalse(WindowAction.restore.positionCycles)
        XCTAssertFalse(WindowAction.moveLeft.positionCycles)
        XCTAssertFalse(WindowAction.moveRight.positionCycles)
        XCTAssertFalse(WindowAction.nextDisplay.positionCycles)
        XCTAssertFalse(WindowAction.previousDisplay.positionCycles)
        XCTAssertFalse(WindowAction.larger.positionCycles)
        XCTAssertFalse(WindowAction.smaller.positionCycles)
        XCTAssertFalse(WindowAction.tileAll.positionCycles)
        XCTAssertFalse(WindowAction.cascadeAll.positionCycles)
        XCTAssertFalse(WindowAction.specified.positionCycles)
    }
}

class CooperativeResizeSourceTests: XCTestCase {

    func testKeyboardShortcutsAndDragSnappingAllowCooperativeResize() {
        XCTAssertTrue(ExecutionSource.keyboardShortcut.allowsCooperativeResize)
        XCTAssertTrue(ExecutionSource.dragToSnap.allowsCooperativeResize)
    }

    func testNonSnappingSourcesDoNotAllowCooperativeResize() {
        XCTAssertFalse(ExecutionSource.menuItem.allowsCooperativeResize)
        XCTAssertFalse(ExecutionSource.url.allowsCooperativeResize)
        XCTAssertFalse(ExecutionSource.titleBar.allowsCooperativeResize)
    }
}

class ScreenFlippedTests: XCTestCase {

    func testScreenFlippedIsOwnInverse() {
        let rect = CGRect(x: 100, y: 200, width: 400, height: 300)
        let flipped = rect.screenFlipped
        let doubleFlipped = flipped.screenFlipped
        XCTAssertEqual(rect.origin.x, doubleFlipped.origin.x, accuracy: 0.001)
        XCTAssertEqual(rect.origin.y, doubleFlipped.origin.y, accuracy: 0.001)
        XCTAssertEqual(rect.width, doubleFlipped.width, accuracy: 0.001)
        XCTAssertEqual(rect.height, doubleFlipped.height, accuracy: 0.001)
    }

    func testScreenFlippedPreservesSize() {
        let rect = CGRect(x: 50, y: 100, width: 800, height: 600)
        let flipped = rect.screenFlipped
        XCTAssertEqual(rect.width, flipped.width, accuracy: 0.001)
        XCTAssertEqual(rect.height, flipped.height, accuracy: 0.001)
    }

    func testScreenFlippedPreservesX() {
        let rect = CGRect(x: 250, y: 300, width: 500, height: 400)
        let flipped = rect.screenFlipped
        XCTAssertEqual(rect.origin.x, flipped.origin.x, accuracy: 0.001)
    }

    func testScreenFlippedNullRectReturnsNull() {
        let nullRect = CGRect.null
        let flipped = nullRect.screenFlipped
        XCTAssertTrue(flipped.isNull)
    }

    func testScreenFlippedNegativeCoordinates() {
        let rect = CGRect(x: -1000, y: -500, width: 400, height: 300)
        let flipped = rect.screenFlipped
        let doubleFlipped = flipped.screenFlipped
        XCTAssertEqual(rect.origin.x, doubleFlipped.origin.x, accuracy: 0.001)
        XCTAssertEqual(rect.origin.y, doubleFlipped.origin.y, accuracy: 0.001)
    }
}

final class DockVisibleFrameTests: XCTestCase {
    private let screen = CGRect(x: 0, y: 0, width: 1440, height: 900)
    private let visibleWithoutDock = CGRect(x: 0, y: 0, width: 1440, height: 875)

    func testAddsMissingBottomDockInset() {
        let dock = CGRect(x: 400, y: 8, width: 640, height: 62)

        XCTAssertEqual(
            corrected(visibleFrame: visibleWithoutDock, dockFrame: dock),
            CGRect(x: 0, y: 70, width: 1440, height: 805)
        )
    }

    func testAddsMissingLeftDockInset() {
        let dock = CGRect(x: 8, y: 180, width: 62, height: 540)

        XCTAssertEqual(
            corrected(visibleFrame: visibleWithoutDock, dockFrame: dock),
            CGRect(x: 70, y: 0, width: 1370, height: 875)
        )
    }

    func testAddsMissingRightDockInset() {
        let dock = CGRect(x: 1370, y: 180, width: 62, height: 540)

        XCTAssertEqual(
            corrected(visibleFrame: visibleWithoutDock, dockFrame: dock),
            CGRect(x: 0, y: 0, width: 1370, height: 875)
        )
    }

    func testPreservesAccurateAppKitInsetWhenDockFrameDiffersSlightly() {
        let reportedVisibleFrame = CGRect(x: 0, y: 60, width: 1440, height: 815)
        let dock = CGRect(x: 30, y: 10, width: 1380, height: 53)

        XCTAssertEqual(
            corrected(visibleFrame: reportedVisibleFrame, dockFrame: dock),
            reportedVisibleFrame
        )
    }

    func testPreservesPlausibleAppKitInsetWhenAXDiffersMaterially() {
        let reportedVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)
        let dock = CGRect(x: 400, y: 8, width: 640, height: 32)

        XCTAssertEqual(
            corrected(visibleFrame: reportedVisibleFrame, dockFrame: dock),
            reportedVisibleFrame
        )
    }

    func testReclaimsPhantomInsetAfterDockMovesToAnotherDisplay() {
        let externalScreen = CGRect(x: 1440, y: 0, width: 1920, height: 1080)
        let dock = CGRect(x: 1740, y: 8, width: 1320, height: 62)
        let staleVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)

        XCTAssertEqual(
            corrected(
                visibleFrame: staleVisibleFrame,
                screenFrames: [screen, externalScreen],
                dockFrame: dock
            ),
            visibleWithoutDock
        )
    }

    func testCorrectsNewDockDisplayAfterMove() {
        let externalScreen = CGRect(x: 1440, y: 0, width: 1920, height: 1080)
        let externalVisibleFrame = CGRect(x: 1440, y: 0, width: 1920, height: 1055)
        let dock = CGRect(x: 1740, y: 8, width: 1320, height: 62)

        XCTAssertEqual(
            DockUtil.correctedVisibleFrame(
                screenFrame: externalScreen,
                visibleFrame: externalVisibleFrame,
                screenFrames: [screen, externalScreen],
                dockFrame: dock,
                dockAutoHideEnabled: false
            ),
            CGRect(x: 1440, y: 70, width: 1920, height: 985)
        )
    }

    func testAutoHideReclaimsStaleInsetAndPreservesSmallRevealBoundary() {
        let reportedVisibleFrame = CGRect(x: 70, y: 4, width: 1370, height: 871)

        XCTAssertEqual(
            corrected(
                visibleFrame: reportedVisibleFrame,
                dockFrame: nil,
                dockAutoHideEnabled: true
            ),
            CGRect(x: 0, y: 4, width: 1440, height: 871)
        )
    }

    func testAutoHideReclaimsStaleBottomInset() {
        let reportedVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)

        XCTAssertEqual(
            corrected(
                visibleFrame: reportedVisibleFrame,
                dockFrame: nil,
                dockAutoHideEnabled: true
            ),
            visibleWithoutDock
        )
    }

    func testLiveDockClearsStaleWrongEdgeInset() {
        let staleLeftDockFrame = CGRect(x: 4, y: 0, width: 1436, height: 875)
        let currentBottomDock = CGRect(x: 400, y: 8, width: 640, height: 62)

        XCTAssertEqual(
            corrected(visibleFrame: staleLeftDockFrame, dockFrame: currentBottomDock),
            CGRect(x: 0, y: 70, width: 1440, height: 805)
        )
    }

    func testUnreadableDockKeepsReportedFrame() {
        let reportedVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)

        XCTAssertEqual(
            corrected(visibleFrame: reportedVisibleFrame, dockFrame: nil),
            reportedVisibleFrame
        )
    }

    func testCenteredDockFrameIsIgnored() {
        let reportedVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)
        let invalidDock = CGRect(x: 400, y: 300, width: 640, height: 62)

        XCTAssertEqual(
            corrected(visibleFrame: reportedVisibleFrame, dockFrame: invalidDock),
            reportedVisibleFrame
        )
    }

    func testOversizedDockFrameIsIgnoredBeforeReclaimingAnotherDisplay() {
        let externalScreen = CGRect(x: 1440, y: 0, width: 1920, height: 1080)
        let invalidDock = CGRect(x: 1440, y: 0, width: 1920, height: 500)
        let reportedVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)

        XCTAssertEqual(
            corrected(
                visibleFrame: reportedVisibleFrame,
                screenFrames: [screen, externalScreen],
                dockFrame: invalidDock
            ),
            reportedVisibleFrame
        )
    }

    func testCorrectsDockOnNegativeOriginDisplay() {
        let externalScreen = CGRect(x: -1920, y: 0, width: 1920, height: 1080)
        let externalVisibleFrame = CGRect(x: -1920, y: 0, width: 1920, height: 1055)
        let dock = CGRect(x: -1912, y: 240, width: 62, height: 600)

        XCTAssertEqual(
            DockUtil.correctedVisibleFrame(
                screenFrame: externalScreen,
                visibleFrame: externalVisibleFrame,
                screenFrames: [externalScreen, screen],
                dockFrame: dock,
                dockAutoHideEnabled: false
            ),
            CGRect(x: -1850, y: 0, width: 1850, height: 1055)
        )
    }

    func testAmbiguousDockHostIsIgnored() {
        let upperScreen = CGRect(x: 0, y: 900, width: 1440, height: 900)
        let ambiguousDock = CGRect(x: 400, y: 870, width: 640, height: 60)
        let reportedVisibleFrame = CGRect(x: 0, y: 75, width: 1440, height: 800)

        XCTAssertEqual(
            corrected(
                visibleFrame: reportedVisibleFrame,
                screenFrames: [screen, upperScreen],
                dockFrame: ambiguousDock
            ),
            reportedVisibleFrame
        )
    }

    func testCombinedDisplayFrameRetainsOuterBottomDockInset() {
        let combinedScreen = CGRect(x: 0, y: 0, width: 3360, height: 1080)
        let combinedVisibleFrame = CGRect(x: 0, y: 0, width: 3360, height: 1055)
        let dock = CGRect(x: 400, y: 8, width: 640, height: 62)

        XCTAssertEqual(
            DockUtil.correctedVisibleFrame(
                screenFrame: combinedScreen,
                visibleFrame: combinedVisibleFrame,
                screenFrames: [combinedScreen],
                dockFrame: dock,
                dockAutoHideEnabled: false
            ),
            CGRect(x: 0, y: 70, width: 3360, height: 985)
        )
    }

    private func corrected(visibleFrame: CGRect,
                           screenFrames: [CGRect]? = nil,
                           dockFrame: CGRect?,
                           dockAutoHideEnabled: Bool = false) -> CGRect {
        DockUtil.correctedVisibleFrame(
            screenFrame: screen,
            visibleFrame: visibleFrame,
            screenFrames: screenFrames ?? [screen],
            dockFrame: dockFrame,
            dockAutoHideEnabled: dockAutoHideEnabled
        )
    }
}

class DefaultsExportTests: XCTestCase {

    func testRetiredExtrasDefaultsAreNotExported() {
        let keys = Defaults.array.map { $0.key }
        XCTAssertFalse(keys.contains("cyclingOverlapOffset"))
        XCTAssertFalse(keys.contains("cyclingOverlapOffsetSize"))
        XCTAssertFalse(keys.contains("cyclingOverlapMaxCascade"))
        XCTAssertTrue(keys.contains("cooperativeCornerResize"), "cooperativeCornerResize missing from Defaults.array")
        XCTAssertFalse(keys.contains("stackBadge"))
        XCTAssertFalse(keys.contains("stageSize"))
        XCTAssertFalse(keys.contains("showAdditionalSizesInMenu"))
        XCTAssertTrue(keys.contains("shippingDefaultProfileVersion"), "shipping profile marker missing from Defaults.array")
    }
}

class ConfigImportTests: XCTestCase {

    private static let shortcutKeys = WindowAction.active.map(\.name)
    private var storedValues = [String: Any]()
    private var absentKeys = Set<String>()
    private var previousShippingProfileVersion = 0

    override func setUp() {
        super.setUp()
        previousShippingProfileVersion = Defaults.shippingDefaultProfileVersion.value
        for key in Self.shortcutKeys {
            if let value = UserDefaults.standard.object(forKey: key) {
                storedValues[key] = value
            } else {
                absentKeys.insert(key)
            }
        }
    }

    override func tearDown() {
        for key in Self.shortcutKeys {
            if let value = storedValues[key] {
                UserDefaults.standard.set(value, forKey: key)
            } else if absentKeys.contains(key) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        storedValues.removeAll()
        absentKeys.removeAll()
        Defaults.shippingDefaultProfileVersion.value = previousShippingProfileVersion
        super.tearDown()
    }

    func testImportClearsOmittedActiveShortcut() throws {
        let action = WindowAction.almostMaximize
        store(Shortcut(NSEvent.ModifierFlags.command.rawValue, 10), forKey: action.name)

        try loadConfig(shortcuts: [:])

        XCTAssertNil(UserDefaults.standard.object(forKey: action.name))
    }

    func testImportAppliesSuppliedActiveShortcut() throws {
        let action = WindowAction.almostMaximize
        let importedShortcut = Shortcut(NSEvent.ModifierFlags.command.rawValue, 12)

        try loadConfig(shortcuts: [action.name: importedShortcut])

        let storedShortcut = try XCTUnwrap(ShortcutCycle.shortcut(for: action))
        XCTAssertEqual(storedShortcut.keyCode, importedShortcut.keyCode)
        XCTAssertEqual(storedShortcut.modifierFlags.rawValue, importedShortcut.modifierFlags)
    }

    func testImportUsesActiveShortcutAlias() throws {
        let action = WindowAction.leftHalf
        let alias = try XCTUnwrap(action.aliasName)
        let importedShortcut = Shortcut(NSEvent.ModifierFlags.command.rawValue, 13)

        try loadConfig(shortcuts: [alias: importedShortcut])

        let storedShortcut = try XCTUnwrap(ShortcutCycle.shortcut(for: action))
        XCTAssertEqual(storedShortcut.keyCode, importedShortcut.keyCode)
        XCTAssertEqual(storedShortcut.modifierFlags.rawValue, importedShortcut.modifierFlags)
    }

    func testImportClearsInvalidActiveShortcut() throws {
        let action = WindowAction.almostMaximize
        store(Shortcut(NSEvent.ModifierFlags.command.rawValue, 14), forKey: action.name)

        try loadConfig(shortcuts: [action.name: Shortcut(NSEvent.ModifierFlags.command.rawValue, -1)])

        XCTAssertNil(UserDefaults.standard.object(forKey: action.name))
    }

    func testImportOfShippingProfileKeepsOmittedShortcutExplicitlyUnassigned() throws {
        let action = WindowAction.topRight
        store(Shortcut(NSEvent.ModifierFlags.command.rawValue, 14), forKey: action.name)

        try loadConfig(
            shortcuts: [:],
            defaults: ["shippingDefaultProfileVersion": CodableDefault(int: ShippingDefaultProfile.version)]
        )

        XCTAssertEqual(UserDefaults.standard.dictionary(forKey: action.name)?.count, 0)
        XCTAssertNil(ShortcutCycle.shortcut(for: action))
    }

    private func store(_ shortcut: Shortcut, forKey key: String) {
        let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: MASDictionaryTransformerName))!
        let value = transformer.reverseTransformedValue(shortcut.toMASSHortcut())
        UserDefaults.standard.set(value, forKey: key)
    }

    private func loadConfig(shortcuts: [String: Shortcut], defaults: [String: CodableDefault] = [:]) throws {
        let config = Config(bundleId: "com.serp.windowmanager",
                            version: "ConfigImportTests",
                            shortcuts: shortcuts,
                            defaults: defaults)
        let data = try JSONEncoder().encode(config)
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ConfigImportTests-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: fileURL) }
        try data.write(to: fileURL, options: .atomic)

        Defaults.load(fileUrl: fileURL, notificationCenter: NotificationCenter())
    }
}

/// The list briefly excluded screen-covering windows, borrowed from the
/// overlap offset where the exclusion is necessary (a maximized window shares
/// its origin with every placement and would otherwise shift them all, #1766).
/// The list moves nothing, so it never needed it, and the exclusion made a
/// maximized window over a half-screen window show no list at all.

class ChangeSizeCalculationTests: XCTestCase {
    private let visibleFrame = CGRect(x: 0, y: 0, width: 2560, height: 1415)
    private let issueWindowRect = CGRect(x: 1895, y: 0, width: 665, height: 1415)
    private var minimumWindowWidth: Double = 0
    private var minimumWindowHeight: Double = 0
    private var sizeOffset: Float = 0
    private var gapSize: Float = 0
    private var curtainChangeSize: Bool?
    private var smallerShrinksMaximizedHeight = false
    private var storedMinimumWindowWidth: Any?
    private var storedMinimumWindowHeight: Any?

    override func setUp() {
        super.setUp()

        minimumWindowWidth = Defaults.minimumWindowWidth.value
        minimumWindowHeight = Defaults.minimumWindowHeight.value
        sizeOffset = Defaults.sizeOffset.value
        gapSize = Defaults.gapSize.value
        curtainChangeSize = Defaults.curtainChangeSize.enabled
        smallerShrinksMaximizedHeight = Defaults.smallerShrinksMaximizedHeight.enabled
        storedMinimumWindowWidth = UserDefaults.standard.object(forKey: Defaults.minimumWindowWidth.key)
        storedMinimumWindowHeight = UserDefaults.standard.object(forKey: Defaults.minimumWindowHeight.key)

        Defaults.minimumWindowWidth.value = 0
        Defaults.minimumWindowHeight.value = 0
        Defaults.sizeOffset.value = 30
        Defaults.gapSize.value = 0
        Defaults.curtainChangeSize.enabled = true
        Defaults.smallerShrinksMaximizedHeight.enabled = false
    }

    override func tearDown() {
        Defaults.minimumWindowWidth.value = minimumWindowWidth
        Defaults.minimumWindowHeight.value = minimumWindowHeight
        restoreStoredValue(storedMinimumWindowWidth, for: Defaults.minimumWindowWidth.key)
        restoreStoredValue(storedMinimumWindowHeight, for: Defaults.minimumWindowHeight.key)
        Defaults.sizeOffset.value = sizeOffset
        Defaults.gapSize.value = gapSize
        Defaults.curtainChangeSize.enabled = curtainChangeSize
        Defaults.smallerShrinksMaximizedHeight.enabled = smallerShrinksMaximizedHeight

        super.tearDown()
    }

    func testExplicitZeroDisablesScreenFractionMinimum() {
        XCTAssertEqual(smallerResult(for: issueWindowRect),
                       CGRect(x: 1925, y: 0, width: 635, height: 1415))
    }

    func testDoubleDefaultDistinguishesAbsentFromExplicitZero() {
        let key = "ChangeSizeCalculationTests.minimumWindowWidth"
        UserDefaults.standard.removeObject(forKey: key)
        defer { UserDefaults.standard.removeObject(forKey: key) }

        let absentPreference = DoubleDefault(key: key, defaultValue: 0.25)
        XCTAssertEqual(absentPreference.value, 0.25)
        XCTAssertEqual(absentPreference.toCodable().double, 0.25)
        XCTAssertNil(absentPreference.toCodable().float)

        absentPreference.value = 0
        let explicitZeroPreference = DoubleDefault(key: key, defaultValue: 0.25)
        XCTAssertEqual(explicitZeroPreference.value, 0)
        XCTAssertEqual(explicitZeroPreference.toCodable().double, 0)
        XCTAssertNil(explicitZeroPreference.toCodable().float)
    }

    func testDoubleDefaultLoadsLegacyFloatAndNewDoubleConfigValues() throws {
        let key = "ChangeSizeCalculationTests.minimumWindowWidthConfig"
        UserDefaults.standard.removeObject(forKey: key)
        defer { UserDefaults.standard.removeObject(forKey: key) }

        let preference = DoubleDefault(key: key, defaultValue: 0.25)
        let legacyZero = try JSONDecoder().decode(
            CodableDefault.self,
            from: Data(#"{"float":0}"#.utf8)
        )
        let legacyFraction = try JSONDecoder().decode(
            CodableDefault.self,
            from: Data(#"{"float":0.01}"#.utf8)
        )
        let currentZero = try JSONDecoder().decode(
            CodableDefault.self,
            from: Data(#"{"double":0}"#.utf8)
        )
        let currentFraction = try JSONDecoder().decode(
            CodableDefault.self,
            from: Data(#"{"double":0.123456789012345}"#.utf8)
        )

        preference.load(from: legacyZero)
        XCTAssertEqual(preference.value, 0.25)

        preference.load(from: legacyFraction)
        XCTAssertEqual(preference.value, Double(Float(0.01)))

        preference.load(from: currentFraction)
        XCTAssertEqual(preference.value, 0.123456789012345)

        preference.load(from: currentZero)
        XCTAssertEqual(preference.value, 0)
    }

    func testSmallerCanReachExactConfiguredMinimum() {
        Defaults.minimumWindowWidth.value = 0.25
        let windowRect = CGRect(x: 1890, y: 0, width: 670, height: 1415)

        XCTAssertEqual(smallerResult(for: windowRect),
                       CGRect(x: 1920, y: 0, width: 640, height: 1415))
    }

    func testSmallerHonorsConfiguredScreenFractionMinimum() {
        Defaults.minimumWindowWidth.value = 0.25

        XCTAssertEqual(smallerResult(for: issueWindowRect), issueWindowRect)
    }

    func testSmallerKeepsHeightOfFullHeightWindowByDefault() {
        // Default behavior (see #1737): the combined `.smaller` command only shrinks the width of
        // a window pinned to the top and bottom screen edges. The height shrinks only under the
        // height-only `.smallerHeight` command (b97a353, fixes #1645) or when the
        // smallerShrinksMaximizedHeight terminal command config is enabled.
        let fullHeightHalf = CGRect(x: 0, y: 0, width: 1280, height: 1415)

        XCTAssertEqual(smallerResult(for: fullHeightHalf),
                       CGRect(x: 0, y: 0, width: 1250, height: 1415))
    }

    func testSmallerShrinksHeightOfFullHeightWindow() {
        // Regression for #1737, opt-in via the terminal command config: a vertically-maximized
        // (Half / full-height) window shrinks in BOTH dimensions under the combined `.smaller`
        // command. Mirrors the `.smallerHeight` exception added in b97a353 (fixes #1645),
        // extended to `.smaller`.
        Defaults.smallerShrinksMaximizedHeight.enabled = true
        let fullHeightHalf = CGRect(x: 0, y: 0, width: 1280, height: 1415)

        XCTAssertEqual(smallerResult(for: fullHeightHalf),
                       CGRect(x: 0, y: 15, width: 1250, height: 1385))
    }

    func testSmallConfiguredScreenFractionAllowsIssueRegressionStep() {
        Defaults.minimumWindowWidth.value = 0.01

        XCTAssertEqual(smallerResult(for: issueWindowRect),
                       CGRect(x: 1925, y: 0, width: 635, height: 1415))
    }

    func testExplicitZeroStillRejectsNonpositiveSize() {
        let narrowWindow = CGRect(x: 100, y: 100, width: 20, height: 100)

        XCTAssertEqual(smallerResult(for: narrowWindow), narrowWindow)
    }

    private func smallerResult(for windowRect: CGRect) -> CGRect {
        ChangeSizeCalculation().calculateRect(
            RectCalculationParameters(window: Window(id: 1, rect: windowRect),
                                      visibleFrameOfScreen: visibleFrame,
                                      action: .smaller,
                                      lastAction: nil)
        ).rect
    }

    private func restoreStoredValue(_ value: Any?, for key: String) {
        if let value {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

class EnhancedUITests: XCTestCase {
    private func adjustmentEvents(
        mode: EnhancedUI,
        bundleIdentifier: String? = "com.google.Chrome",
        builtInAssistiveTechnologyEnabled: Bool = false,
        initialEnhancedUI: Bool?
    ) -> [String] {
        var events = [String]()
        mode.performWindowAdjustment(
            bundleIdentifier: bundleIdentifier,
            builtInAssistiveTechnologyEnabled: builtInAssistiveTechnologyEnabled,
            readEnhancedUI: {
                events.append("read")
                return initialEnhancedUI
            },
            writeEnhancedUI: { events.append("write:\($0)") },
            adjustment: { events.append("adjust") }
        )
        return events
    }

    func testAutomaticModeLeavesEnhancedUIDisabledForChromium() {
        XCTAssertEqual(
            adjustmentEvents(mode: .automatic, initialEnhancedUI: true),
            ["read", "write:false", "adjust"]
        )
    }

    func testAutomaticModeRestoresEnhancedUIForOtherApps() {
        XCTAssertEqual(
            adjustmentEvents(
                mode: .automatic,
                bundleIdentifier: "com.apple.Safari",
                initialEnhancedUI: true
            ),
            ["read", "write:false", "adjust", "write:true"]
        )
        XCTAssertEqual(
            adjustmentEvents(
                mode: .automatic,
                bundleIdentifier: nil,
                initialEnhancedUI: true
            ),
            ["read", "write:false", "adjust", "write:true"]
        )
    }

    func testAutomaticModeRestoresEnhancedUIForBuiltInAssistiveTechnology() {
        XCTAssertEqual(
            adjustmentEvents(
                mode: .automatic,
                builtInAssistiveTechnologyEnabled: true,
                initialEnhancedUI: true
            ),
            ["read", "write:false", "adjust", "write:true"]
        )
    }

    func testExplicitModesKeepTheirExistingRestoreBehavior() {
        XCTAssertEqual(
            adjustmentEvents(mode: .disableEnable, initialEnhancedUI: true),
            ["read", "write:false", "adjust", "write:true"]
        )
        XCTAssertEqual(
            adjustmentEvents(mode: .disableOnly, initialEnhancedUI: true),
            ["read", "write:false", "adjust"]
        )
        XCTAssertEqual(
            adjustmentEvents(mode: .frontmostDisable, initialEnhancedUI: true),
            ["read", "write:false", "adjust"]
        )
    }

    func testDisabledOrUnavailableEnhancedUIDoesNotWrite() {
        XCTAssertEqual(
            adjustmentEvents(mode: .automatic, initialEnhancedUI: false),
            ["read", "adjust"]
        )
        XCTAssertEqual(
            adjustmentEvents(mode: .automatic, initialEnhancedUI: nil),
            ["read", "adjust"]
        )
    }

    func testApplicationActivationPolicy() {
        XCTAssertTrue(
            EnhancedUI.automatic.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: "com.google.Chrome",
                builtInAssistiveTechnologyEnabled: false
            )
        )
        XCTAssertFalse(
            EnhancedUI.automatic.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: "com.google.Chrome",
                builtInAssistiveTechnologyEnabled: true
            )
        )
        XCTAssertFalse(
            EnhancedUI.automatic.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: "com.apple.Safari",
                builtInAssistiveTechnologyEnabled: false
            )
        )
        XCTAssertFalse(
            EnhancedUI.automatic.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: nil,
                builtInAssistiveTechnologyEnabled: false
            )
        )
        XCTAssertTrue(
            EnhancedUI.frontmostDisable.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: "com.apple.Safari",
                builtInAssistiveTechnologyEnabled: true
            )
        )
        XCTAssertFalse(
            EnhancedUI.disableEnable.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: "com.google.Chrome",
                builtInAssistiveTechnologyEnabled: false
            )
        )
        XCTAssertFalse(
            EnhancedUI.disableOnly.disablesEnhancedUIOnApplicationActivation(
                bundleIdentifier: "com.google.Chrome",
                builtInAssistiveTechnologyEnabled: false
            )
        )
    }

    func testKnownChromiumBrowserBundleIdentifiers() {
        let matchingBundleIdentifiers = [
            "com.google.Chrome",
            "com.google.Chrome.canary",
            "org.chromium.Chromium",
            "com.microsoft.edgemac",
            "com.microsoft.edgemac.Beta",
            "com.brave.Browser",
            "com.brave.Browser.nightly",
            "com.vivaldi.Vivaldi",
            "com.operasoftware.Opera",
            "com.operasoftware.OperaNext",
            "com.operasoftware.OperaDeveloper",
            "com.operasoftware.OperaNightly",
            "com.operasoftware.OperaGX",
            "com.operasoftware.OperaGXNext",
            "com.operasoftware.OperaGXDeveloper",
            "com.operasoftware.OperaGXNightly",
            "company.thebrowser.Browser",
            "company.thebrowser.dia",
            "ai.perplexity.comet",
            "com.openai.atlas"
        ]
        let nonmatchingBundleIdentifiers: [String?] = [
            nil,
            "com.apple.Safari",
            "com.google.Chromecast",
            "com.google.ChromeHelper",
            "com.brave.BrowserHelper"
        ]

        for bundleIdentifier in matchingBundleIdentifiers {
            XCTAssertTrue(EnhancedUI.isKnownChromiumBrowser(bundleIdentifier: bundleIdentifier))
        }
        for bundleIdentifier in nonmatchingBundleIdentifiers {
            XCTAssertFalse(EnhancedUI.isKnownChromiumBrowser(bundleIdentifier: bundleIdentifier))
        }
    }

    func testEnhancedUIPreferenceMigrationAndRawValues() {
        let key = "RectangleTests.enhancedUI.\(UUID().uuidString)"
        defer { UserDefaults.standard.removeObject(forKey: key) }

        let absentPreference = IntEnumDefault<EnhancedUI>(
            key: key,
            defaultValue: .automatic,
            invalidValueFallback: .disableEnable
        )
        XCTAssertEqual(absentPreference.value.rawValue, 4)

        UserDefaults.standard.set(0, forKey: key)
        let legacyZeroPreference = IntEnumDefault<EnhancedUI>(
            key: key,
            defaultValue: .automatic,
            invalidValueFallback: .disableEnable
        )
        XCTAssertEqual(legacyZeroPreference.value.rawValue, 1)

        for rawValue in 1...4 {
            UserDefaults.standard.set(rawValue, forKey: key)
            let preference = IntEnumDefault<EnhancedUI>(
                key: key,
                defaultValue: .automatic,
                invalidValueFallback: .disableEnable
            )
            XCTAssertEqual(preference.value.rawValue, rawValue)
        }

        legacyZeroPreference.load(from: CodableDefault(int: 0))
        XCTAssertEqual(legacyZeroPreference.value.rawValue, 1)
    }
}

class CooperativeCornerResizeTests: XCTestCase {
    private let screenFrame = CGRect(x: 0, y: 0, width: 1200, height: 900)
    private let minimumSize = CGSize(width: 100, height: 100)
    private let tolerance: CGFloat = 8

    func testBottomLeftVerticalExpansionShrinksTopLeftNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 800, height: 600))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 600, width: 800, height: 300))
        XCTAssertEqual(focusedNew.maxY, adjustments[0].newFrame.minY, accuracy: 0.001)
    }

    func testBottomLeftVerticalExpansionKeepsFullTwoThirdsWhenFeasible() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 800, height: 600))

        guard let plan = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: focusedNew)
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 600, width: 800, height: 300))
    }

    func testBottomLeftVerticalExpansionIsReducedByCooperatingMinimumHeight() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2,
                                                        frame: CGRect(x: 0, y: 300, width: 800, height: 600),
                                                        minimumSize: CGSize(width: 100, height: 400))

        guard let plan = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 800, height: 500))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 500, width: 800, height: 400))
        XCTAssertTrue(plan.debugLog.contains { $0.contains("reduced requested movement") })
    }

    func testBottomLeftVerticalExpansionUsesVisibleFrameInsteadOfRawScreenFrame() {
        let visibleFrame = CGRect(x: 0, y: 0, width: 1200, height: 840)
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2,
                                                        frame: CGRect(x: 0, y: 300, width: 800, height: 600),
                                                        minimumSize: CGSize(width: 100, height: 300))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         screenFrame: visibleFrame,
                                         candidates: [topLeft],
                                         axis: .vertical) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 800, height: 540))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 540, width: 800, height: 300))
        XCTAssertLessThanOrEqual(plan.adjustments[0].newFrame.maxY, visibleFrame.maxY)
    }

    func testVerticalExpansionRoundsSharedEdgeAtOneThirdTwoThirdsBoundary() {
        let screenFrame = CGRect(x: 0, y: 0, width: 1200, height: 1000)
        let oneThird = screenFrame.height / 3.0
        let twoThirds = screenFrame.height * 2.0 / 3.0
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: oneThird)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: twoThirds)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: oneThird, width: 800, height: twoThirds))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         screenFrame: screenFrame,
                                         candidates: [topLeft],
                                         axis: .vertical) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 800, height: 667))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 667, width: 800, height: 333))
        XCTAssertEqual(plan.focusedFrame.maxY, plan.adjustments[0].newFrame.minY, accuracy: 0.001)
    }

    func testAffectedWindowsReceiveOneFinalFrameEach() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 400, height: 900)
        let bottomLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 0, width: 800, height: 300))
        let bottomRight = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 800, y: 0, width: 400, height: 300))
        let topRight = CooperativeCornerResize.Candidate(id: 4, frame: CGRect(x: 800, y: 300, width: 400, height: 600))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [bottomLeft, bottomRight, topRight],
                                         axis: .horizontal) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        let adjustedIds = plan.adjustments.map(\.id)
        XCTAssertEqual(adjustedIds.count, Set(adjustedIds).count)
        XCTAssertEqual(adjustedIds.sorted(), [2, 3, 4])
    }

    func testUnrelatedWindowsAreNotMoved() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 800, height: 600))
        let unrelated = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 850, y: 50, width: 250, height: 250))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft, unrelated],
                                         axis: .vertical) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        XCTAssertEqual(plan.adjustments.map(\.id), [topLeft.id])
    }

    func testNearGridNeighborIsDetectedAndNormalized() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let terminalLikeTop = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 5, y: 304, width: 790, height: 596))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [terminalLikeTop],
                                         axis: .vertical,
                                         tolerance: 20) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 600, width: 800, height: 300))
    }

    func testInitialCornerPushPlansAgainstRequestedSharedBoundary() {
        let focusedOld = CGRect(x: 225, y: 120, width: 420, height: 360)
        let focusedNew = CGRect(x: 0, y: 0, width: 600, height: 450)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 450, width: 600, height: 450))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew,
                                         actionDescription: "initial corner/side cooperative placement") else {
            XCTFail("Expected initial cooperative placement plan")
            return
        }

        assertRect(plan.focusedFrame, equals: focusedNew)
        assertRect(plan.adjustments[0].newFrame, equals: topLeft.frame)
        XCTAssertFalse(CooperativeCornerResize.frameNeedsApplication(currentFrame: topLeft.frame,
                                                                     solvedFrame: plan.adjustments[0].newFrame,
                                                                     screenFrame: screenFrame,
                                                                     layoutTolerance: 4))
        XCTAssertTrue(plan.debugLog.contains { $0.contains("initial corner/side cooperative placement") })
    }

    func testInitialCornerPushWithOversizedFocusedMinimumMovesBoundaryBeforeOverlap() {
        let focusedOld = CGRect(x: 225, y: 120, width: 420, height: 360)
        let focusedNew = CGRect(x: 0, y: 0, width: 600, height: 450)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 450, width: 600, height: 450))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         focusedMinimumSize: CGSize(width: 100, height: 520),
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected oversized focused cooperative placement plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 600, height: 520))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 520, width: 600, height: 380))
        XCTAssertEqual(plan.focusedFrame.maxY, plan.adjustments[0].newFrame.minY, accuracy: 0.001)
        XCTAssertLessThanOrEqual(plan.adjustments[0].newFrame.maxY, screenFrame.maxY)
    }

    func testInitialSidePushWithOversizedNeighborGivesFocusedWindowPartialTarget() {
        let focusedOld = CGRect(x: 180, y: 80, width: 480, height: 640)
        let focusedNew = CGRect(x: 0, y: 0, width: 600, height: 900)
        let rightSide = CooperativeCornerResize.Candidate(id: 2,
                                                          frame: CGRect(x: 600, y: 0, width: 600, height: 900),
                                                          minimumSize: CGSize(width: 700, height: 100))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [rightSide],
                                         axis: .horizontal,
                                         movedEdgeOverride: .right,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected initial side cooperative placement plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 500, height: 900))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 500, y: 0, width: 700, height: 900))
        XCTAssertEqual(plan.focusedFrame.maxX, plan.adjustments[0].newFrame.minX, accuracy: 0.001)
    }

    func testInitialCornerPushWithOversizedFocusedWindowAdjustsBothAxesWithoutSpill() {
        let focusedOld = CGRect(x: 250, y: 160, width: 320, height: 260)
        let focusedNew = CGRect(x: 0, y: 0, width: 400, height: 450)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 450, width: 400, height: 450))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         focusedMinimumSize: CGSize(width: 700, height: 520),
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected both-axis oversized cooperative placement plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 700, height: 520))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 520, width: 400, height: 380))
        XCTAssertLessThanOrEqual(plan.focusedFrame.maxX, screenFrame.maxX)
        XCTAssertLessThanOrEqual(plan.adjustments[0].newFrame.maxY, screenFrame.maxY)
        XCTAssertEqual(plan.focusedFrame.maxY, plan.adjustments[0].newFrame.minY, accuracy: 0.001)
        XCTAssertFalse(plan.focusedFrame.intersects(plan.adjustments[0].newFrame))
    }

    func testExistingCorrectInitialLayoutIsNoOpForAllSolvedFrames() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 600)
        let focusedNew = focusedOld
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 600, width: 800, height: 300))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected cooperative no-op plan")
            return
        }

        XCTAssertFalse(CooperativeCornerResize.frameNeedsApplication(currentFrame: focusedOld,
                                                                     solvedFrame: plan.focusedFrame,
                                                                     screenFrame: screenFrame,
                                                                     layoutTolerance: 4))
        XCTAssertFalse(CooperativeCornerResize.frameNeedsApplication(currentFrame: topLeft.frame,
                                                                     solvedFrame: plan.adjustments[0].newFrame,
                                                                     screenFrame: screenFrame,
                                                                     layoutTolerance: 4))
    }

    func testInitialCornerPlacementPreservesExplicitlyShrunkOccupiedCell() {
        let focusedOld = CGRect(x: 225, y: 120, width: 420, height: 360)
        let focusedDefault = CGRect(x: 0, y: 300, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 600, width: 800, height: 300))
        let bottomLeft = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        let focusedNew = CooperativeCornerResize.focusedFramePreservingOccupiedCell(requestedFocusedFrame: focusedDefault,
                                                                                    screenFrame: screenFrame,
                                                                                    candidates: [topLeft, bottomLeft],
                                                                                    axis: .vertical,
                                                                                    movedEdge: .bottom,
                                                                                    tolerance: tolerance)

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft, bottomLeft],
                                         axis: .vertical,
                                         captureTolerance: 72,
                                         movedEdgeOverride: .bottom,
                                         candidateDiscoveryFrame: focusedNew,
                                         actionDescription: "initial corner/side cooperative placement") else {
            XCTFail("Expected initial cooperative placement plan")
            return
        }

        assertRect(focusedNew, equals: topLeft.frame)
        assertRect(plan.focusedFrame, equals: topLeft.frame)
        assertRect(plan.adjustments[0].newFrame, equals: topLeft.frame)
        assertRect(plan.adjustments[1].newFrame, equals: bottomLeft.frame)
    }

    func testInitialCornerPlacementUsesLargerRealizedBoundaryBeforePlanning() {
        let focusedOld = CGRect(x: 225, y: 120, width: 420, height: 360)
        let focusedDefault = CGRect(x: 400, y: 600, width: 800, height: 300)
        let constrainedTopRight = CooperativeCornerResize.Candidate(id: 2,
                                                                    frame: CGRect(x: 400, y: 540, width: 800, height: 360))
        let focusedNew = CooperativeCornerResize.focusedFrameResolvingRealizedCornerBoundary(requestedFocusedFrame: focusedDefault,
                                                                                             screenFrame: screenFrame,
                                                                                             candidates: [constrainedTopRight],
                                                                                             axis: .vertical,
                                                                                             movedEdge: .bottom,
                                                                                             tolerance: tolerance)

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [constrainedTopRight],
                                         axis: .vertical,
                                         movedEdgeOverride: .bottom,
                                         candidateDiscoveryFrame: focusedNew,
                                         actionDescription: "initial corner/side cooperative placement") else {
            XCTFail("Expected initial cooperative placement plan")
            return
        }

        assertRect(focusedNew, equals: constrainedTopRight.frame)
        assertRect(plan.focusedFrame, equals: constrainedTopRight.frame)
        assertRect(plan.adjustments[0].newFrame, equals: constrainedTopRight.frame)
        XCTAssertFalse(CooperativeCornerResize.frameNeedsApplication(currentFrame: constrainedTopRight.frame,
                                                                     solvedFrame: plan.adjustments[0].newFrame,
                                                                     screenFrame: screenFrame,
                                                                     layoutTolerance: 4))
    }

    func testInitialCornerPlacementUsesObservedCyclicBoundaryBeforePlanning() {
        let focusedDefault = CGRect(x: 400, y: 600, width: 800, height: 300)
        let cycledTopRight = CooperativeCornerResize.Candidate(id: 2,
                                                               frame: CGRect(x: 400, y: 300, width: 800, height: 600))

        let focusedNew = CooperativeCornerResize.focusedFrameResolvingRealizedCornerBoundary(requestedFocusedFrame: focusedDefault,
                                                                                             screenFrame: screenFrame,
                                                                                             candidates: [cycledTopRight],
                                                                                             axis: .vertical,
                                                                                             movedEdge: .bottom,
                                                                                             tolerance: tolerance)

        assertRect(focusedNew, equals: cycledTopRight.frame)
    }

    func testCornerCleanupRebalancesRemainingWindowsAfterMinConstrainedWindowLeaves() {
        let removedTopRight = CGRect(x: 400, y: 540, width: 800, height: 360)
        let targetTopRight = CGRect(x: 400, y: 600, width: 800, height: 300)
        let remainingTopRight = CooperativeCornerResize.Candidate(id: 2,
                                                                  frame: CGRect(x: 400, y: 540, width: 800, height: 360))
        let bottomRight = CooperativeCornerResize.Candidate(id: 3,
                                                            frame: CGRect(x: 400, y: 0, width: 800, height: 540))

        guard let plan = cooperativePlan(focusedOld: removedTopRight,
                                         focusedNew: targetTopRight,
                                         candidates: [remainingTopRight, bottomRight],
                                         axis: .vertical,
                                         focusedMinimumSize: CGSize(width: 1, height: 1),
                                         movedEdgeOverride: .bottom,
                                         candidateDiscoveryFrame: removedTopRight,
                                         actionDescription: "cooperative resize cleanup after focused window left corner") else {
            XCTFail("Expected cleanup cooperative plan")
            return
        }

        assertRect(plan.focusedFrame, equals: targetTopRight)
        assertRect(plan.adjustments[0].newFrame, equals: targetTopRight)
        assertRect(plan.adjustments[1].newFrame, equals: CGRect(x: 400, y: 0, width: 800, height: 600))
    }

    func testCornerCleanupKeepsConstrainedLayoutWhenRemainingWindowCannotFitTarget() {
        let removedTopRight = CGRect(x: 400, y: 540, width: 800, height: 360)
        let targetTopRight = CGRect(x: 400, y: 600, width: 800, height: 300)
        let remainingTopRight = CooperativeCornerResize.Candidate(id: 2,
                                                                  frame: CGRect(x: 400, y: 540, width: 800, height: 360),
                                                                  minimumSize: CGSize(width: 100, height: 360))
        let bottomRight = CooperativeCornerResize.Candidate(id: 3,
                                                            frame: CGRect(x: 400, y: 0, width: 800, height: 540))

        guard let plan = cooperativePlan(focusedOld: removedTopRight,
                                         focusedNew: targetTopRight,
                                         candidates: [remainingTopRight, bottomRight],
                                         axis: .vertical,
                                         focusedMinimumSize: CGSize(width: 1, height: 1),
                                         movedEdgeOverride: .bottom,
                                         candidateDiscoveryFrame: removedTopRight,
                                         actionDescription: "cooperative resize cleanup after focused window left corner") else {
            XCTFail("Expected constrained cleanup cooperative plan")
            return
        }

        assertRect(plan.focusedFrame, equals: removedTopRight)
        assertRect(plan.adjustments[0].newFrame, equals: remainingTopRight.frame)
        assertRect(plan.adjustments[1].newFrame, equals: bottomRight.frame)
    }

    func testCornerCleanupRebalancesFocusedAdjacentDestinationAfterMinConstrainedWindowLeaves() {
        let removedTopLeft = CGRect(x: 0, y: 540, width: 800, height: 360)
        let targetTopLeft = CGRect(x: 0, y: 600, width: 800, height: 300)
        let remainingTopLeft = CooperativeCornerResize.Candidate(id: 2,
                                                                 frame: removedTopLeft)
        let focusedBottomLeft = CooperativeCornerResize.Candidate(id: 99,
                                                                  frame: CGRect(x: 0, y: 0, width: 800, height: 540))

        guard let plan = cooperativePlan(focusedOld: removedTopLeft,
                                         focusedNew: targetTopLeft,
                                         candidates: [remainingTopLeft, focusedBottomLeft],
                                         axis: .vertical,
                                         focusedMinimumSize: CGSize(width: 1, height: 1),
                                         movedEdgeOverride: .bottom,
                                         candidateDiscoveryFrame: removedTopLeft,
                                         actionDescription: "cooperative resize cleanup after focused window left corner") else {
            XCTFail("Expected focused destination cleanup cooperative plan")
            return
        }

        let focusedDestinationAdjustment = plan.adjustments.first { $0.id == focusedBottomLeft.id }

        assertRect(plan.focusedFrame, equals: targetTopLeft)
        assertRect(focusedDestinationAdjustment?.newFrame ?? .null,
                   equals: CGRect(x: 0, y: 0, width: 800, height: 600))
    }

    func testNearbyWindowEightPercentOffGridIsCapturedAndNormalized() {
        let focusedOld = CGRect(x: 250, y: 160, width: 320, height: 260)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let offGridTop = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 90, y: 660, width: 620, height: 240))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [offGridTop],
                                         axis: .vertical,
                                         captureTolerance: 72,
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected off-grid nearby window to be captured")
            return
        }

        XCTAssertEqual(plan.adjustments.map(\.id), [offGridTop.id])
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 600, width: 800, height: 300))
        XCTAssertTrue(plan.debugLog.contains { $0.contains("capture-tolerance") })
    }

    func testBoundaryCrossingWindowIsCapturedAndAssignedAdjacent() {
        let focusedOld = CGRect(x: 250, y: 160, width: 320, height: 260)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let crossingTop = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 560, width: 800, height: 340))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [crossingTop],
                                         axis: .vertical,
                                         captureTolerance: 72,
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected boundary-crossing window to be captured")
            return
        }

        XCTAssertEqual(plan.adjustments[0].kind, .adjacent)
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 600, width: 800, height: 300))
        XCTAssertTrue(plan.debugLog.contains { $0.contains("boundary crossing") })
    }

    func testGapConsumingWindowIsCorrectedWhenFeasible() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 600)
        let focusedNew = focusedOld
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 605, width: 800, height: 295))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         gapSize: 12,
                                         captureTolerance: 72,
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected gap-consuming window to be corrected")
            return
        }

        assertRect(plan.focusedFrame, equals: focusedNew)
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 612, width: 800, height: 288))
        XCTAssertEqual(plan.adjustments[0].newFrame.minY - plan.focusedFrame.maxY, 12, accuracy: 0.001)
    }

    func testAggressiveCaptureIgnoresUnrelatedFloatingWindow() {
        let focusedOld = CGRect(x: 250, y: 160, width: 320, height: 260)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let floating = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 900, y: 620, width: 180, height: 160))

        let plan = cooperativePlan(focusedOld: focusedOld,
                                   focusedNew: focusedNew,
                                   candidates: [floating],
                                   axis: .vertical,
                                   captureTolerance: 72,
                                   movedEdgeOverride: .top,
                                   candidateDiscoveryFrame: focusedNew)

        XCTAssertNil(plan)
    }

    func testConfiguredGapIsPreservedForVerticalStack() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 312, width: 800, height: 588))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         gapSize: 12) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: focusedNew)
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 612, width: 800, height: 288))
        XCTAssertEqual(plan.adjustments[0].newFrame.minY - plan.focusedFrame.maxY, 12, accuracy: 0.001)
    }

    func testConfiguredGapAndOversizedNeighborReduceExpansion() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2,
                                                        frame: CGRect(x: 0, y: 312, width: 800, height: 588),
                                                        minimumSize: CGSize(width: 100, height: 350))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         gapSize: 12) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 0, y: 0, width: 800, height: 538))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 0, y: 550, width: 800, height: 350))
        XCTAssertEqual(plan.adjustments[0].newFrame.minY - plan.focusedFrame.maxY, 12, accuracy: 0.001)
    }

    func testCapturedGapPerimeterSurvivesOversizedNeighbor() {
        let focusedOld = CGRect(x: 12, y: 12, width: 782, height: 282)
        let focusedNew = CGRect(x: 12, y: 12, width: 782, height: 582)
        let topLeft = CooperativeCornerResize.Candidate(id: 2,
                                                        frame: CGRect(x: 102, y: 654, width: 602, height: 234),
                                                        minimumSize: CGSize(width: 100, height: 350))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [topLeft],
                                         axis: .vertical,
                                         gapSize: 12,
                                         captureTolerance: 72,
                                         movedEdgeOverride: .top,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected gap-aware cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 12, y: 12, width: 782, height: 514))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 12, y: 538, width: 782, height: 350))
        XCTAssertEqual(plan.adjustments[0].newFrame.minY - plan.focusedFrame.maxY, 12, accuracy: 0.001)
        XCTAssertEqual(plan.adjustments[0].newFrame.maxY, screenFrame.maxY - 12, accuracy: 0.001)
    }

    func testCapturedHorizontalGapPerimeterSurvivesOversizedNeighbor() {
        let focusedOld = CGRect(x: 12, y: 12, width: 282, height: 876)
        let focusedNew = CGRect(x: 12, y: 12, width: 582, height: 876)
        let rightSide = CooperativeCornerResize.Candidate(id: 2,
                                                          frame: CGRect(x: 654, y: 72, width: 534, height: 756),
                                                          minimumSize: CGSize(width: 700, height: 100))

        guard let plan = cooperativePlan(focusedOld: focusedOld,
                                         focusedNew: focusedNew,
                                         candidates: [rightSide],
                                         axis: .horizontal,
                                         gapSize: 12,
                                         captureTolerance: 96,
                                         movedEdgeOverride: .right,
                                         candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected horizontal gap-aware cooperative resize plan")
            return
        }

        assertRect(plan.focusedFrame, equals: CGRect(x: 12, y: 12, width: 464, height: 876))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 488, y: 12, width: 700, height: 876))
        XCTAssertEqual(plan.adjustments[0].newFrame.minX - plan.focusedFrame.maxX, 12, accuracy: 0.001)
        XCTAssertEqual(plan.adjustments[0].newFrame.maxX, screenFrame.maxX - 12, accuracy: 0.001)
    }

    func testSettlingPassAdjustsVerticalOversizedNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 800, height: 600))

        guard let planned = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical),
              let correction = correctionPlan(focusedOld: focusedOld,
                                              focusedNew: focusedNew,
                                              plannedPlan: planned,
                                              candidates: [topLeft],
                                              actualFocusedFrame: planned.focusedFrame,
                                              actualCandidateFramesById: [2: CGRect(x: 0, y: 500, width: 800, height: 400)],
                                              axis: .vertical) else {
            XCTFail("Expected cooperative correction plan")
            return
        }

        assertRect(correction.focusedFrame, equals: CGRect(x: 0, y: 0, width: 800, height: 500))
        assertRect(correction.adjustments[0].newFrame, equals: CGRect(x: 0, y: 500, width: 800, height: 400))
    }

    func testPreFocusedSettlingPreservesGapForOversizedTopNeighbor() {
        let focusedOld = CGRect(x: 1600, y: 160, width: 620, height: 540)
        let focusedNew = CGRect(x: 1077, y: 160, width: 2103, height: 1060)
        let topRight = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 1077, y: 1155, width: 2103, height: 600))

        guard let planned = cooperativePlan(focusedOld: focusedOld,
                                            focusedNew: focusedNew,
                                            screenFrame: CGRect(x: 0, y: 140, width: 3200, height: 1635),
                                            candidates: [topRight],
                                            axis: .vertical,
                                            tolerance: 24,
                                            gapSize: 20,
                                            captureTolerance: 96,
                                            movedEdgeOverride: .top,
                                            candidateDiscoveryFrame: focusedNew),
              let correction = CooperativeCornerResize.correctionPlan(oldFocusedFrame: focusedOld,
                                                                      requestedFocusedFrame: focusedNew,
                                                                      plannedPlan: planned,
                                                                      screenFrame: CGRect(x: 0, y: 140, width: 3200, height: 1635),
                                                                      candidates: [topRight],
                                                                      actualFocusedFrame: planned.focusedFrame,
                                                                      actualCandidateFramesById: [topRight.id: topRight.frame],
                                                                      axis: .vertical,
                                                                      tolerance: 24,
                                                                      layoutTolerance: 4,
                                                                      minimumSize: minimumSize,
                                                                      gapSize: 20,
                                                                      captureTolerance: 96,
                                                                      movedEdgeOverride: .top,
                                                                      candidateDiscoveryFrame: focusedNew) else {
            XCTFail("Expected pre-focused correction plan")
            return
        }

        assertRect(correction.focusedFrame, equals: CGRect(x: 1077, y: 160, width: 2103, height: 975))
        assertRect(correction.adjustments[0].newFrame, equals: CGRect(x: 1077, y: 1155, width: 2103, height: 600))
        XCTAssertEqual(correction.adjustments[0].newFrame.minY - correction.focusedFrame.maxY, 20, accuracy: 0.001)
    }

    func testSettlingPassAdjustsHorizontalOversizedNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 600, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 900)
        let rightSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 600, y: 0, width: 600, height: 900))

        guard let planned = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [rightSide], axis: .horizontal),
              let correction = correctionPlan(focusedOld: focusedOld,
                                              focusedNew: focusedNew,
                                              plannedPlan: planned,
                                              candidates: [rightSide],
                                              actualFocusedFrame: planned.focusedFrame,
                                              actualCandidateFramesById: [2: CGRect(x: 700, y: 0, width: 500, height: 900)],
                                              axis: .horizontal) else {
            XCTFail("Expected cooperative correction plan")
            return
        }

        assertRect(correction.focusedFrame, equals: CGRect(x: 0, y: 0, width: 700, height: 900))
        assertRect(correction.adjustments[0].newFrame, equals: CGRect(x: 700, y: 0, width: 500, height: 900))
    }

    func testSettlingPassHandlesBothAxisOversizedNeighborWithoutSpill() {
        let focusedOld = CGRect(x: 0, y: 0, width: 400, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 400, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 400, height: 600))

        guard let planned = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical),
              let correction = correctionPlan(focusedOld: focusedOld,
                                              focusedNew: focusedNew,
                                              plannedPlan: planned,
                                              candidates: [topLeft],
                                              actualFocusedFrame: planned.focusedFrame,
                                              actualCandidateFramesById: [2: CGRect(x: 0, y: 500, width: 700, height: 400)],
                                              axis: .vertical) else {
            XCTFail("Expected cooperative correction plan")
            return
        }

        assertRect(correction.focusedFrame, equals: CGRect(x: 0, y: 0, width: 400, height: 500))
        assertRect(correction.adjustments[0].newFrame, equals: CGRect(x: 0, y: 500, width: 700, height: 400))
        XCTAssertLessThanOrEqual(correction.adjustments[0].newFrame.maxX, screenFrame.maxX)
        XCTAssertLessThanOrEqual(correction.adjustments[0].newFrame.maxY, screenFrame.maxY)
    }

    func testSettlingPassHandlesOversizedInitiatingWindow() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 800, height: 600))

        guard let planned = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical),
              let correction = correctionPlan(focusedOld: focusedOld,
                                              focusedNew: focusedNew,
                                              plannedPlan: planned,
                                              candidates: [topLeft],
                                              actualFocusedFrame: CGRect(x: 0, y: 0, width: 800, height: 700),
                                              actualCandidateFramesById: [2: planned.adjustments[0].newFrame],
                                              axis: .vertical) else {
            XCTFail("Expected cooperative correction plan")
            return
        }

        assertRect(correction.focusedFrame, equals: CGRect(x: 0, y: 0, width: 800, height: 700))
        assertRect(correction.adjustments[0].newFrame, equals: CGRect(x: 0, y: 700, width: 800, height: 200))
    }

    func testSettlingPassIsSkippedWhenActualFramesMatchPlan() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 300, width: 800, height: 600))

        guard let planned = cooperativePlan(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical) else {
            XCTFail("Expected cooperative resize plan")
            return
        }

        let correction = correctionPlan(focusedOld: focusedOld,
                                        focusedNew: focusedNew,
                                        plannedPlan: planned,
                                        candidates: [topLeft],
                                        actualFocusedFrame: planned.focusedFrame,
                                        actualCandidateFramesById: [2: planned.adjustments[0].newFrame],
                                        axis: .vertical)

        XCTAssertNil(correction)
    }

    func testBottomLeftVerticalShrinkExpandsTopLeftNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 600)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 300)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 600, width: 800, height: 300))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 300, width: 800, height: 600))
        XCTAssertEqual(focusedNew.maxY, adjustments[0].newFrame.minY, accuracy: 0.001)
    }

    func testMatchingBottomLeftWindowShrinksWithFocusedWindowBeforeNeighborExpands() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 600)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 300)
        let matchingBottomLeft = CooperativeCornerResize.Candidate(id: 2, frame: focusedOld)
        let topLeft = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 0, y: 600, width: 800, height: 300))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [matchingBottomLeft, topLeft], axis: .vertical)

        XCTAssertEqual(adjustments.count, 2)
        XCTAssertEqual(adjustments[0].id, matchingBottomLeft.id)
        XCTAssertEqual(adjustments[0].kind, .matchingFocusedFrame)
        assertRect(adjustments[0].newFrame, equals: focusedNew)
        XCTAssertEqual(adjustments[1].id, topLeft.id)
        XCTAssertEqual(adjustments[1].kind, .adjacent)
        assertRect(adjustments[1].newFrame, equals: CGRect(x: 0, y: 300, width: 800, height: 600))
    }

    func testTopLeftHorizontalExpansionShrinksTopRightNeighbor() {
        let focusedOld = CGRect(x: 0, y: 300, width: 600, height: 600)
        let focusedNew = CGRect(x: 0, y: 300, width: 800, height: 600)
        let topRight = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 600, y: 300, width: 600, height: 600))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topRight], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 800, y: 300, width: 400, height: 600))
        XCTAssertEqual(focusedNew.maxX, adjustments[0].newFrame.minX, accuracy: 0.001)
    }

    func testTopLeftHorizontalShrinkExpandsTopRightNeighbor() {
        let focusedOld = CGRect(x: 0, y: 300, width: 800, height: 600)
        let focusedNew = CGRect(x: 0, y: 300, width: 600, height: 600)
        let topRight = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 800, y: 300, width: 400, height: 600))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topRight], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 600, y: 300, width: 600, height: 600))
        XCTAssertEqual(focusedNew.maxX, adjustments[0].newFrame.minX, accuracy: 0.001)
    }

    func testLeftSideHorizontalExpansionShrinksRightSideNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 600, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 900)
        let rightSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 600, y: 0, width: 600, height: 900))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [rightSide], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 800, y: 0, width: 400, height: 900))
        XCTAssertEqual(focusedNew.maxX, adjustments[0].newFrame.minX, accuracy: 0.001)
    }

    func testLeftSideHorizontalExpansionShrinksStackedRightCornerNeighbors() {
        let focusedOld = CGRect(x: 0, y: 0, width: 600, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 900)
        let bottomRight = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 600, y: 0, width: 600, height: 450))
        let topRight = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 600, y: 450, width: 600, height: 450))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [bottomRight, topRight], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 2)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 800, y: 0, width: 400, height: 450))
        assertRect(adjustments[1].newFrame, equals: CGRect(x: 800, y: 450, width: 400, height: 450))
    }

    func testLeftSideHorizontalShrinkExpandsRightSideNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 600, height: 900)
        let rightSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 800, y: 0, width: 400, height: 900))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [rightSide], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 600, y: 0, width: 600, height: 900))
        XCTAssertEqual(focusedNew.maxX, adjustments[0].newFrame.minX, accuracy: 0.001)
    }

    func testMatchingLeftSideWindowShrinksWithFocusedWindowBeforeRightSideNeighborExpands() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 600, height: 900)
        let matchingLeftSide = CooperativeCornerResize.Candidate(id: 2, frame: focusedOld)
        let rightSide = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 800, y: 0, width: 400, height: 900))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [matchingLeftSide, rightSide], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 2)
        XCTAssertEqual(adjustments[0].id, matchingLeftSide.id)
        XCTAssertEqual(adjustments[0].kind, .matchingFocusedFrame)
        assertRect(adjustments[0].newFrame, equals: focusedNew)
        XCTAssertEqual(adjustments[1].id, rightSide.id)
        XCTAssertEqual(adjustments[1].kind, .adjacent)
        assertRect(adjustments[1].newFrame, equals: CGRect(x: 600, y: 0, width: 600, height: 900))
    }

    func testLeftSideShrinkAlsoShrinksPartialBottomLeftOccupant() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 900)
        let focusedNew = CGRect(x: 0, y: 0, width: 400, height: 900)
        let bottomLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 0, width: 800, height: 300))
        let bottomRight = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 800, y: 0, width: 400, height: 300))
        let topRight = CooperativeCornerResize.Candidate(id: 4, frame: CGRect(x: 800, y: 300, width: 400, height: 600))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld,
                                                focusedNew: focusedNew,
                                                candidates: [bottomLeft, bottomRight, topRight],
                                                axis: .horizontal)

        XCTAssertEqual(adjustments.count, 3)
        XCTAssertEqual(adjustments[0].id, bottomLeft.id)
        XCTAssertEqual(adjustments[0].kind, .matchingFocusedFrame)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 0, width: 400, height: 300))
        assertRect(adjustments[1].newFrame, equals: CGRect(x: 400, y: 0, width: 800, height: 300))
        assertRect(adjustments[2].newFrame, equals: CGRect(x: 400, y: 300, width: 800, height: 600))
    }

    func testRightSideHorizontalExpansionShrinksLeftSideNeighbor() {
        let focusedOld = CGRect(x: 600, y: 0, width: 600, height: 900)
        let focusedNew = CGRect(x: 400, y: 0, width: 800, height: 900)
        let leftSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 0, width: 600, height: 900))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [leftSide], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 0, width: 400, height: 900))
        XCTAssertEqual(adjustments[0].newFrame.maxX, focusedNew.minX, accuracy: 0.001)
    }

    func testTopSideVerticalExpansionShrinksBottomSideNeighbor() {
        let focusedOld = CGRect(x: 0, y: 450, width: 1200, height: 450)
        let focusedNew = CGRect(x: 0, y: 300, width: 1200, height: 600)
        let bottomSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 0, width: 1200, height: 450))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [bottomSide], axis: .vertical)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 0, width: 1200, height: 300))
        XCTAssertEqual(adjustments[0].newFrame.maxY, focusedNew.minY, accuracy: 0.001)
    }

    func testTopSideVerticalExpansionShrinksStackedBottomCornerNeighbors() {
        let focusedOld = CGRect(x: 0, y: 450, width: 1200, height: 450)
        let focusedNew = CGRect(x: 0, y: 300, width: 1200, height: 600)
        let bottomLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 0, width: 600, height: 450))
        let bottomRight = CooperativeCornerResize.Candidate(id: 3, frame: CGRect(x: 600, y: 0, width: 600, height: 450))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [bottomLeft, bottomRight], axis: .vertical)

        XCTAssertEqual(adjustments.count, 2)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 0, width: 600, height: 300))
        assertRect(adjustments[1].newFrame, equals: CGRect(x: 600, y: 0, width: 600, height: 300))
    }

    func testTopSideVerticalShrinkExpandsBottomSideNeighbor() {
        let focusedOld = CGRect(x: 0, y: 300, width: 1200, height: 600)
        let focusedNew = CGRect(x: 0, y: 450, width: 1200, height: 450)
        let bottomSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 0, width: 1200, height: 300))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [bottomSide], axis: .vertical)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 0, width: 1200, height: 450))
        XCTAssertEqual(adjustments[0].newFrame.maxY, focusedNew.minY, accuracy: 0.001)
    }

    func testBottomSideVerticalExpansionShrinksTopSideNeighbor() {
        let focusedOld = CGRect(x: 0, y: 0, width: 1200, height: 450)
        let focusedNew = CGRect(x: 0, y: 0, width: 1200, height: 600)
        let topSide = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 0, y: 450, width: 1200, height: 450))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topSide], axis: .vertical)

        XCTAssertEqual(adjustments.count, 1)
        assertRect(adjustments[0].newFrame, equals: CGRect(x: 0, y: 600, width: 1200, height: 300))
        XCTAssertEqual(focusedNew.maxY, adjustments[0].newFrame.minY, accuracy: 0.001)
    }

    func testNoAdjacentCandidateFound() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [], axis: .vertical)

        XCTAssertTrue(adjustments.isEmpty)
    }

    func testAmbiguousFloatingWindowIsIgnored() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let floating = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 20, y: 302, width: 500, height: 240))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [floating], axis: .vertical)

        XCTAssertTrue(adjustments.isEmpty)
    }

    func testToleranceMatchesNormalTiledNeighborsWithGaps() {
        let focusedOld = CGRect(x: 0, y: 0, width: 800, height: 300)
        let focusedNew = CGRect(x: 0, y: 0, width: 800, height: 600)
        let topLeft = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 3, y: 305, width: 794, height: 592))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topLeft], axis: .vertical)

        XCTAssertEqual(adjustments.count, 1)
        XCTAssertEqual(adjustments[0].newFrame.minY, focusedNew.maxY, accuracy: 0.001)
    }

    func testNonCycledAxisRemainsUnchanged() {
        let focusedOld = CGRect(x: 0, y: 300, width: 600, height: 600)
        let focusedNew = CGRect(x: 0, y: 300, width: 800, height: 600)
        let topRight = CooperativeCornerResize.Candidate(id: 2, frame: CGRect(x: 600, y: 300, width: 600, height: 600))

        let adjustments = cooperativeAdjustments(focusedOld: focusedOld, focusedNew: focusedNew, candidates: [topRight], axis: .horizontal)

        XCTAssertEqual(adjustments.count, 1)
        XCTAssertEqual(adjustments[0].newFrame.minY, topRight.frame.minY, accuracy: 0.001)
        XCTAssertEqual(adjustments[0].newFrame.height, topRight.frame.height, accuracy: 0.001)
    }

    private func cooperativeAdjustments(focusedOld: CGRect,
                                        focusedNew: CGRect,
                                        candidates: [CooperativeCornerResize.Candidate],
                                        axis: CornerCycleExpansionAxis,
                                        gapSize: CGFloat = 0) -> [CooperativeCornerResize.Adjustment] {
        CooperativeCornerResize.adjustments(oldFocusedFrame: focusedOld,
                                            newFocusedFrame: focusedNew,
                                            screenFrame: screenFrame,
                                            candidates: candidates,
                                            axis: axis,
                                            tolerance: tolerance,
                                            minimumSize: minimumSize,
                                            gapSize: gapSize)
    }

    private func cooperativePlan(focusedOld: CGRect,
                                 focusedNew: CGRect,
                                 screenFrame: CGRect? = nil,
                                 candidates: [CooperativeCornerResize.Candidate],
                                 axis: CornerCycleExpansionAxis,
                                 tolerance: CGFloat? = nil,
                                 gapSize: CGFloat = 0,
                                 focusedMinimumSize: CGSize? = nil,
                                 captureTolerance: CGFloat? = nil,
                                 movedEdgeOverride: CooperativeCornerResize.MovedEdge? = nil,
                                 candidateDiscoveryFrame: CGRect? = nil,
                                 actionDescription: String = "test cooperative resize") -> CooperativeCornerResize.Plan? {
        CooperativeCornerResize.plan(oldFocusedFrame: focusedOld,
                                     newFocusedFrame: focusedNew,
                                     screenFrame: screenFrame ?? self.screenFrame,
                                     candidates: candidates,
                                     axis: axis,
                                     tolerance: tolerance ?? self.tolerance,
                                     minimumSize: minimumSize,
                                     focusedMinimumSize: focusedMinimumSize,
                                     gapSize: gapSize,
                                     captureTolerance: captureTolerance,
                                     movedEdgeOverride: movedEdgeOverride,
                                     candidateDiscoveryFrame: candidateDiscoveryFrame,
                                     actionDescription: actionDescription)
    }

    private func correctionPlan(focusedOld: CGRect,
                                focusedNew: CGRect,
                                plannedPlan: CooperativeCornerResize.Plan,
                                candidates: [CooperativeCornerResize.Candidate],
                                actualFocusedFrame: CGRect,
                                actualCandidateFramesById: [CGWindowID: CGRect],
                                axis: CornerCycleExpansionAxis,
                                gapSize: CGFloat = 0,
                                captureTolerance: CGFloat? = nil,
                                movedEdgeOverride: CooperativeCornerResize.MovedEdge? = nil,
                                candidateDiscoveryFrame: CGRect? = nil) -> CooperativeCornerResize.Plan? {
        CooperativeCornerResize.correctionPlan(oldFocusedFrame: focusedOld,
                                               requestedFocusedFrame: focusedNew,
                                               plannedPlan: plannedPlan,
                                               screenFrame: screenFrame,
                                               candidates: candidates,
                                               actualFocusedFrame: actualFocusedFrame,
                                               actualCandidateFramesById: actualCandidateFramesById,
                                               axis: axis,
                                               tolerance: tolerance,
                                               layoutTolerance: 4,
                                               minimumSize: minimumSize,
                                               gapSize: gapSize,
                                               captureTolerance: captureTolerance,
                                               movedEdgeOverride: movedEdgeOverride,
                                               candidateDiscoveryFrame: candidateDiscoveryFrame)
    }

    private func assertRect(_ rect: CGRect, equals expected: CGRect, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(rect.origin.x, expected.origin.x, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rect.origin.y, expected.origin.y, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rect.width, expected.width, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rect.height, expected.height, accuracy: 0.001, file: file, line: line)
    }
}

class CycleSizeRatioPresetTests: XCTestCase {

    func testPercentValuesMatchCycleSizeFractions() {
        XCTAssertEqual(CycleSize.oneHalf.percentValue, 50, accuracy: 0.001)
        XCTAssertEqual(CycleSize.twoThirds.percentValue, 66.666, accuracy: 0.001)
        XCTAssertEqual(CycleSize.oneThird.percentValue, 33.333, accuracy: 0.001)
    }

    func testMatchingPercentValueUsesTolerance() {
        XCTAssertEqual(CycleSize.matching(percentValue: 33.3334), .oneThird)
        XCTAssertEqual(CycleSize.matching(percentValue: 66.6666), .twoThirds)
    }

    func testCustomPercentValueDoesNotMatchPreset() {
        XCTAssertNil(CycleSize.matching(percentValue: 60))
    }
}

class ActiveSideSplitRatiosCooperativeTests: XCTestCase {
    private let screenFrame = CGRect(x: 10, y: 20, width: 1200, height: 900)
    private let gapSize: CGFloat = 20
    private var savedHorizontalSplitRatio: Float = 50
    private var savedVerticalSplitRatio: Float = 50
    private var savedCornerCycleExpansionAxis: CornerCycleExpansionAxis = .horizontal
    private var savedSubsequentExecutionMode: SubsequentExecutionMode = .resize

    override func setUp() {
        super.setUp()
        savedHorizontalSplitRatio = Defaults.horizontalSplitRatio.value
        savedVerticalSplitRatio = Defaults.verticalSplitRatio.value
        savedCornerCycleExpansionAxis = Defaults.cornerCycleExpansionAxis.value
        savedSubsequentExecutionMode = Defaults.subsequentExecutionMode.value
        Defaults.horizontalSplitRatio.value = CycleSize.oneQuarter.percentValue
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical
        Defaults.subsequentExecutionMode.value = .resize
        ActiveSideSplitRatios.shared.resetAll()
    }

    override func tearDown() {
        Defaults.horizontalSplitRatio.value = savedHorizontalSplitRatio
        Defaults.verticalSplitRatio.value = savedVerticalSplitRatio
        Defaults.cornerCycleExpansionAxis.value = savedCornerCycleExpansionAxis
        Defaults.subsequentExecutionMode.value = savedSubsequentExecutionMode
        ActiveSideSplitRatios.shared.resetAll()
        super.tearDown()
    }

    func testMinWidthConstrainedTopLeftRecordsAchievedHorizontalSplit() throws {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let plan = try XCTUnwrap(topLeftPlan(focusedMinimumSize: CGSize(width: 360, height: 100)))

        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: plan.focusedFrame,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        XCTAssertEqual(plan.focusedFrame.width, 360, accuracy: 0.001)
        XCTAssertEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: screenFrame), 0.325, accuracy: 0.001)
    }

    func testBottomLeftAfterMinWidthConstraintUsesAchievedHorizontalSplit() throws {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let plan = try XCTUnwrap(topLeftPlan(focusedMinimumSize: CGSize(width: 360, height: 100)))
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: plan.focusedFrame,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        let bottomLeft = WindowCalculationFactory.lowerLeftCalculation.calculateRect(params(for: .bottomLeft)).rect
        let gappedBottomLeft = GapCalculation.applyGaps(bottomLeft,
                                                        sharedEdges: WindowAction.bottomLeft.gapSharedEdge,
                                                        gapSize: Float(gapSize))

        XCTAssertEqual(bottomLeft.width, 390, accuracy: 0.001)
        XCTAssertEqual(gappedBottomLeft.width, plan.focusedFrame.width, accuracy: 0.001)
        XCTAssertEqual(gappedBottomLeft.maxX, plan.focusedFrame.maxX, accuracy: 0.001)
    }

    func testMinHeightConstrainedTopLeftRecordsAchievedVerticalSplit() throws {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let plan = try XCTUnwrap(topLeftPlan(focusedMinimumSize: CGSize(width: 100, height: 360)))

        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: plan.focusedFrame,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        XCTAssertEqual(plan.focusedFrame.height, 360, accuracy: 0.001)
        XCTAssertEqual(ActiveSideSplitRatios.shared.verticalRatio(for: screenFrame), 390.0 / 900.0, accuracy: 0.001)
        XCTAssertEqual(WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf)).rect.height,
                       390,
                       accuracy: 0.001)
    }

    func testRightAndBottomConstraintsRecordSymmetricLeadingSplits() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let constrainedTopRight = gappedCornerFrame(horizontalSide: .trailing,
                                                    verticalSide: .leading,
                                                    horizontalFraction: 390.0 / 1200.0,
                                                    verticalFraction: CycleSize.oneThird.fraction,
                                                    action: .topRight)
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topRight,
                                                                    achievedFrame: constrainedTopRight,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        XCTAssertEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: screenFrame), 0.675, accuracy: 0.001)
        XCTAssertEqual(WindowCalculationFactory.rightHalfCalculation.calculateRect(params(for: .rightHalf)).rect.width,
                       390,
                       accuracy: 0.001)

        let constrainedBottomRight = gappedCornerFrame(horizontalSide: .trailing,
                                                       verticalSide: .trailing,
                                                       horizontalFraction: 390.0 / 1200.0,
                                                       verticalFraction: 390.0 / 900.0,
                                                       action: .bottomRight)
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.bottomRight,
                                                                    achievedFrame: constrainedBottomRight,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        XCTAssertEqual(ActiveSideSplitRatios.shared.verticalRatio(for: screenFrame), 1.0 - 390.0 / 900.0, accuracy: 0.001)
        XCTAssertEqual(WindowCalculationFactory.bottomHalfCalculation.calculateRect(params(for: .bottomHalf)).rect.height,
                       390,
                       accuracy: 0.001)
    }

    func testAchievedCooperativeRatiosDoNotChangeSavedDefaults() throws {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let savedHorizontal = Defaults.horizontalSplitRatio.value
        let savedVertical = Defaults.verticalSplitRatio.value
        let plan = try XCTUnwrap(topLeftPlan(focusedMinimumSize: CGSize(width: 360, height: 360)))

        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: plan.focusedFrame,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        XCTAssertEqual(Defaults.horizontalSplitRatio.value, savedHorizontal, accuracy: 0.001)
        XCTAssertEqual(Defaults.verticalSplitRatio.value, savedVertical, accuracy: 0.001)
        XCTAssertNotEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: screenFrame), savedHorizontal / 100.0)
        XCTAssertNotEqual(ActiveSideSplitRatios.shared.verticalRatio(for: screenFrame), savedVertical / 100.0)
    }

    func testGapIsIncludedWhenDerivingAchievedSplit() throws {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let plan = try XCTUnwrap(topLeftPlan(focusedMinimumSize: CGSize(width: 360, height: 100)))
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: plan.focusedFrame,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        let ratioIgnoringInternalHalfGap = Float((plan.focusedFrame.maxX - screenFrame.minX) / screenFrame.width)
        XCTAssertEqual(ratioIgnoringInternalHalfGap, 380.0 / 1200.0, accuracy: 0.001)
        XCTAssertEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: screenFrame), 390.0 / 1200.0, accuracy: 0.001)
    }

    func testCyclicCornerAfterConstraintUsesAchievedPerpendicularRatio() throws {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        let plan = try XCTUnwrap(topLeftPlan(focusedMinimumSize: CGSize(width: 360, height: 100)))
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: plan.focusedFrame,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: gapSize)

        let firstBottomLeft = WindowCalculationFactory.lowerLeftCalculation.calculateRect(params(for: .bottomLeft)).rect
        let cycledBottomLeft = WindowCalculationFactory.lowerLeftCalculation.calculateRect(
            RectCalculationParameters(window: Window(id: 1, rect: firstBottomLeft),
                                      visibleFrameOfScreen: screenFrame,
                                      action: .bottomLeft,
                                      lastAction: RectangleAction(action: .bottomLeft,
                                                                  subAction: nil,
                                                                  rect: firstBottomLeft,
                                                                  count: 1))
        ).rect

        XCTAssertNotEqual(cycledBottomLeft.height, firstBottomLeft.height)
        XCTAssertEqual(cycledBottomLeft.width, 390, accuracy: 0.001)
    }

    private func topLeftPlan(focusedMinimumSize: CGSize) -> CooperativeCornerResize.Plan? {
        let requestedTopLeft = gappedCornerFrame(horizontalSide: .leading,
                                                 verticalSide: .leading,
                                                 horizontalFraction: CycleSize.oneQuarter.fraction,
                                                 verticalFraction: CycleSize.oneThird.fraction,
                                                 action: .topLeft)
        let bottomLeft = gappedCornerFrame(horizontalSide: .leading,
                                           verticalSide: .trailing,
                                           horizontalFraction: CycleSize.oneQuarter.fraction,
                                           verticalFraction: 1.0 - CycleSize.oneThird.fraction,
                                           action: .bottomLeft)

        return CooperativeCornerResize.plan(oldFocusedFrame: CGRect(x: 300, y: 250, width: 400, height: 300),
                                            newFocusedFrame: requestedTopLeft,
                                            screenFrame: screenFrame,
                                            candidates: [CooperativeCornerResize.Candidate(id: 2, frame: bottomLeft)],
                                            axis: .vertical,
                                            tolerance: 8,
                                            minimumSize: CGSize(width: 100, height: 100),
                                            focusedMinimumSize: focusedMinimumSize,
                                            gapSize: gapSize,
                                            captureTolerance: 72,
                                            movedEdgeOverride: .bottom,
                                            candidateDiscoveryFrame: requestedTopLeft,
                                            actionDescription: "test constrained top-left placement")
    }

    private func gappedCornerFrame(horizontalSide: HalfSplitSide,
                                   verticalSide: HalfSplitSide,
                                   horizontalFraction: Float,
                                   verticalFraction: Float,
                                   action: WindowAction) -> CGRect {
        let rawFrame = HalfSplitFrameCalculation.cornerRect(in: screenFrame,
                                                            horizontalSide: horizontalSide,
                                                            verticalSide: verticalSide,
                                                            horizontalFraction: horizontalFraction,
                                                            verticalFraction: verticalFraction)
        return GapCalculation.applyGaps(rawFrame,
                                        sharedEdges: action.gapSharedEdge,
                                        gapSize: Float(gapSize))
    }

    private func params(for action: WindowAction) -> RectCalculationParameters {
        RectCalculationParameters(window: Window(id: 1, rect: screenFrame),
                                  visibleFrameOfScreen: screenFrame,
                                  action: action,
                                  lastAction: nil)
    }
}

class HalfSplitCornerCalculationTests: XCTestCase {
    
    private var savedHorizontalSplitRatio: Float = 50
    private var savedVerticalSplitRatio: Float = 50
    private var savedSubsequentExecutionMode: SubsequentExecutionMode = .resize
    private var savedCornerCycleExpansionAxis: CornerCycleExpansionAxis = .horizontal
    private var savedCycleSizesIsChanged = false
    private var savedSelectedCycleSizes = Set<CycleSize>()
    private var savedGapSize: Float = 0
    private var savedSkipGapTopEdge = false
    private let visibleFrame = CGRect(x: 10, y: 20, width: 1200, height: 900)
    
    override func setUp() {
        super.setUp()
        savedHorizontalSplitRatio = Defaults.horizontalSplitRatio.value
        savedVerticalSplitRatio = Defaults.verticalSplitRatio.value
        savedSubsequentExecutionMode = Defaults.subsequentExecutionMode.value
        savedCornerCycleExpansionAxis = Defaults.cornerCycleExpansionAxis.value
        savedCycleSizesIsChanged = Defaults.cycleSizesIsChanged.enabled
        savedSelectedCycleSizes = Defaults.selectedCycleSizes.value
        savedGapSize = Defaults.gapSize.value
        savedSkipGapTopEdge = Defaults.skipGapTopEdge.enabled
        Defaults.subsequentExecutionMode.value = .resize
        Defaults.cycleSizesIsChanged.enabled = false
        Defaults.gapSize.value = 0
        Defaults.skipGapTopEdge.enabled = false
        ActiveSideSplitRatios.shared.resetAll()
    }
    
    override func tearDown() {
        Defaults.horizontalSplitRatio.value = savedHorizontalSplitRatio
        Defaults.verticalSplitRatio.value = savedVerticalSplitRatio
        Defaults.subsequentExecutionMode.value = savedSubsequentExecutionMode
        Defaults.cornerCycleExpansionAxis.value = savedCornerCycleExpansionAxis
        Defaults.cycleSizesIsChanged.enabled = savedCycleSizesIsChanged
        Defaults.selectedCycleSizes.value = savedSelectedCycleSizes
        Defaults.gapSize.value = savedGapSize
        Defaults.skipGapTopEdge.enabled = savedSkipGapTopEdge
        ActiveSideSplitRatios.shared.resetAll()
        super.tearDown()
    }
    
    func testCornersUseHalfSplitRatioOneHalf() {
        setSplitRatio(50)
        
        assertCornerRects(
            topLeft: CGRect(x: 10, y: 470, width: 600, height: 450),
            topRight: CGRect(x: 610, y: 470, width: 600, height: 450),
            bottomLeft: CGRect(x: 10, y: 20, width: 600, height: 450),
            bottomRight: CGRect(x: 610, y: 20, width: 600, height: 450)
        )
    }
    
    func testCornersUseHalfSplitRatioTwoThirds() {
        setSplitRatio(CycleSize.twoThirds.percentValue)
        
        assertCornerRects(
            topLeft: CGRect(x: 10, y: 320, width: 800, height: 600),
            topRight: CGRect(x: 810, y: 320, width: 400, height: 600),
            bottomLeft: CGRect(x: 10, y: 20, width: 800, height: 300),
            bottomRight: CGRect(x: 810, y: 20, width: 400, height: 300)
        )
    }
    
    func testCornersUseHalfSplitRatioThreeQuarters() {
        setSplitRatio(CycleSize.threeQuarters.percentValue)
        
        assertCornerRects(
            topLeft: CGRect(x: 10, y: 245, width: 900, height: 675),
            topRight: CGRect(x: 910, y: 245, width: 300, height: 675),
            bottomLeft: CGRect(x: 10, y: 20, width: 900, height: 225),
            bottomRight: CGRect(x: 910, y: 20, width: 300, height: 225)
        )
    }
    
    func testCornersUseCustomHalfSplitRatio() {
        setSplitRatio(60)
        
        assertCornerRects(
            topLeft: CGRect(x: 10, y: 380, width: 720, height: 540),
            topRight: CGRect(x: 730, y: 380, width: 480, height: 540),
            bottomLeft: CGRect(x: 10, y: 20, width: 720, height: 360),
            bottomRight: CGRect(x: 730, y: 20, width: 480, height: 360)
        )
    }
    
    func testHalfActionsStillUseHalfSplitRatio() {
        setSplitRatio(60)
        
        assertRect(WindowCalculationFactory.leftHalfCalculation.calculateRect(params(for: .leftHalf)).rect,
                   equals: CGRect(x: 10, y: 20, width: 720, height: 900))
        assertRect(WindowCalculationFactory.rightHalfCalculation.calculateRect(params(for: .rightHalf)).rect,
                   equals: CGRect(x: 730, y: 20, width: 480, height: 900))
        assertRect(WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf)).rect,
                   equals: CGRect(x: 10, y: 380, width: 1200, height: 540))
        assertRect(WindowCalculationFactory.bottomHalfCalculation.calculateRect(params(for: .bottomHalf)).rect,
                   equals: CGRect(x: 10, y: 20, width: 1200, height: 360))
    }

    func testRepeatedCornersWithHorizontalExpansionCycleWidthOnly() {
        setSplitRatio(60)
        Defaults.cornerCycleExpansionAxis.value = .horizontal

        assertRepeatedCornerRects(
            topLeft: CGRect(x: 10, y: 380, width: 800, height: 540),
            topRight: CGRect(x: 410, y: 380, width: 800, height: 540),
            bottomLeft: CGRect(x: 10, y: 20, width: 800, height: 360),
            bottomRight: CGRect(x: 410, y: 20, width: 800, height: 360)
        )
    }

    func testSecondRepeatedCornerShortcutBeginsCyclingImmediately() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        setSplitRatio(CycleSize.twoThirds.percentValue)
        Defaults.cornerCycleExpansionAxis.value = .horizontal

        let firstFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(params(for: .topLeft)).rect
        let secondFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(repeatedParams(for: .topLeft, currentRect: firstFrame, count: 1)).rect
        let thirdFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(repeatedParams(for: .topLeft, currentRect: secondFrame, count: 2)).rect

        assertRect(firstFrame, equals: CGRect(x: 10, y: 320, width: 800, height: 600))
        assertRect(secondFrame, equals: CGRect(x: 10, y: 320, width: 400, height: 600))
        assertRect(thirdFrame, equals: CGRect(x: 10, y: 320, width: 600, height: 600))
    }

    func testRepeatedCornerCyclingDoesNotReturnNoOpFrameWhenBaseMatchesCycleSize() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        setSplitRatio(CycleSize.twoThirds.percentValue)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let firstFrame = WindowCalculationFactory.upperRightCalculation.calculateRect(params(for: .topRight)).rect
        let secondFrame = WindowCalculationFactory.upperRightCalculation.calculateRect(repeatedParams(for: .topRight, currentRect: firstFrame, count: 1)).rect

        XCTAssertFalse(firstFrame.equalTo(secondFrame))
        XCTAssertEqual(firstFrame.maxY, secondFrame.maxY, accuracy: 0.001)
        XCTAssertEqual(firstFrame.origin.x, secondFrame.origin.x, accuracy: 0.001)
        XCTAssertEqual(firstFrame.width, secondFrame.width, accuracy: 0.001)
    }

    func testRepeatedCornerCyclingRecognizesGapAdjustedCooperativeBoundary() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical
        Defaults.gapSize.value = 20

        let rawTwoThirdsFrame = WindowCalculationFactory.lowerRightCalculation.calculateRect(params(for: .bottomRight)).rect
        var cooperativeCurrentFrame = GapCalculation.applyGaps(rawTwoThirdsFrame,
                                                               dimension: .both,
                                                               sharedEdges: WindowAction.bottomRight.gapSharedEdge,
                                                               gapSize: Defaults.gapSize.value,
                                                               skipTopGap: Defaults.skipGapTopEdge.enabled)
        cooperativeCurrentFrame.size.height = rawTwoThirdsFrame.height

        let repeatedFrame = WindowCalculationFactory.lowerRightCalculation.calculateRect(repeatedParams(for: .bottomRight,
                                                                                                        currentRect: cooperativeCurrentFrame,
                                                                                                        count: 1)).rect

        assertRect(rawTwoThirdsFrame, equals: CGRect(x: 810, y: 20, width: 400, height: 600))
        assertRect(cooperativeCurrentFrame, equals: CGRect(x: 820, y: 40, width: 370, height: 600))
        assertRect(repeatedFrame, equals: CGRect(x: 810, y: 20, width: 400, height: 300))
    }

    func testCleanupTargetSkipsCornerReducedByAdjacentMinimumConstraint() {
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let reducedBottomLeft = CGRect(x: 10, y: 20, width: 800, height: 500)
        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .bottomLeft,
                                                              observedFrame: reducedBottomLeft,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .top,
                                                              tolerance: 8,
                                                              includeCycleTargets: true)

        XCTAssertNil(cleanupTarget)
    }

    func testCleanupSourceFinderSupportsSideActionsAndIgnoresCorners() {
        setSplitRatio(50)

        let expandedLeft = CGRect(x: 10, y: 20, width: 700, height: 900)
        let remainingLeft = CooperativeCornerResize.Candidate(id: 2,
                                                              frame: expandedLeft)
        let cornerWidthMatch = CooperativeCornerResize.Candidate(id: 3,
                                                                 frame: CGRect(x: 10, y: 470, width: 800, height: 450))
        let sourceFrame = WindowManager().observedCooperativeSourceFrame(action: .leftHalf,
                                                                         oldFocusedFrame: expandedLeft,
                                                                         candidates: [cornerWidthMatch, remainingLeft],
                                                                         screenFrame: visibleFrame,
                                                                         axis: .horizontal,
                                                                         movedEdge: .right,
                                                                         tolerance: 8,
                                                                         captureTolerance: 96,
                                                                         gapSize: 0)

        assertRect(sourceFrame ?? .null, equals: expandedLeft)
    }

    func testCleanupTargetShrinksExpandedSideSource() {
        setSplitRatio(50)

        let expandedLeft = CGRect(x: 10, y: 20, width: 700, height: 900)
        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .leftHalf,
                                                              observedFrame: expandedLeft,
                                                              screenFrame: visibleFrame,
                                                              axis: .horizontal,
                                                              movedEdge: .right,
                                                              tolerance: 8,
                                                              includeCycleTargets: false)

        assertRect(cleanupTarget ?? .null, equals: CGRect(x: 10, y: 20, width: 600, height: 900))
    }

    func testCooperativeHistoryActionMapsAdjacentSideAndCornerActions() {
        let manager = WindowManager()

        XCTAssertEqual(manager.cooperativeHistoryAction(for: .matchingFocusedFrame,
                                                        sourceAction: .leftHalf,
                                                        movedEdge: .right),
                       .leftHalf)
        XCTAssertEqual(manager.cooperativeHistoryAction(for: .adjacent,
                                                        sourceAction: .leftHalf,
                                                        movedEdge: .right),
                       .rightHalf)
        XCTAssertEqual(manager.cooperativeHistoryAction(for: .adjacent,
                                                        sourceAction: .topLeft,
                                                        movedEdge: .bottom),
                       .bottomLeft)
    }

    func testRecordActionCanPreserveCooperativeCorrectionCount() {
        let manager = WindowManager()
        let windowId = CGWindowID(987_654)
        let originalRect = CGRect(x: 10, y: 20, width: 600, height: 900)
        let correctedRect = CGRect(x: 10, y: 20, width: 800, height: 900)
        AppDelegate.windowHistory.lastRectangleActions[windowId] = RectangleAction(action: .leftHalf,
                                                                                   subAction: nil,
                                                                                   rect: originalRect,
                                                                                   count: 3)
        defer {
            AppDelegate.windowHistory.lastRectangleActions.removeValue(forKey: windowId)
        }

        manager.recordAction(windowId: windowId,
                             resultingRect: correctedRect,
                             action: .leftHalf,
                             subAction: nil,
                             incrementCount: false)

        let recorded = AppDelegate.windowHistory.lastRectangleActions[windowId]
        XCTAssertEqual(recorded?.count, 3)
        assertRect(recorded?.rect ?? .null, equals: correctedRect)
    }

    func testCleanupTargetAllowsExpandedMinimumConstrainedCorner() {
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let expandedTopLeft = CGRect(x: 10, y: 400, width: 800, height: 520)
        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .topLeft,
                                                              observedFrame: expandedTopLeft,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .bottom,
                                                              tolerance: 8,
                                                              includeCycleTargets: false)

        assertRect(cleanupTarget ?? .null, equals: CGRect(x: 10, y: 620, width: 800, height: 300))
    }

    func testCleanupTargetShrinksMinimumRestrictedSourceAtConfiguredSize() {
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = 40
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let minimumRestrictedTopRight = CGRect(x: 610, y: 560, width: 600, height: 360)

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .topRight,
                                                              observedFrame: minimumRestrictedTopRight,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .bottom,
                                                              tolerance: 8,
                                                              includeCycleTargets: false)

        assertRect(cleanupTarget ?? .null, equals: CGRect(x: 610, y: 620, width: 600, height: 300))
    }

    func testCleanupDestinationAllowsNonAdjacentMinimumRestrictedSourceCleanup() {
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = 40
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let manager = WindowManager()
        let minimumRestrictedTopRight = CGRect(x: 610, y: 560, width: 600, height: 360)
        let focusedTopLeftDestination = CGRect(x: 10, y: 620, width: 600, height: 300)
        guard let cleanupTarget = manager.cleanupTargetFrame(action: .topRight,
                                                            observedFrame: minimumRestrictedTopRight,
                                                            screenFrame: visibleFrame,
                                                            axis: .vertical,
                                                            movedEdge: .bottom,
                                                            tolerance: 8,
                                                            includeCycleTargets: false)
        else {
            XCTFail("Expected minimum-restricted cleanup target")
            return
        }

        XCTAssertFalse(manager.frameIsAdjacentToCleanupSource(focusedTopLeftDestination,
                                                              sourceFrame: minimumRestrictedTopRight,
                                                              movedEdge: .bottom,
                                                              axis: .vertical,
                                                              tolerance: 8,
                                                              gapSize: 0))
        XCTAssertTrue(manager.cleanupDestinationAllowsSourceResize(action: .topRight,
                                                                   observedFrame: minimumRestrictedTopRight,
                                                                   targetFrame: cleanupTarget,
                                                                   focusedDestinationFrame: focusedTopLeftDestination,
                                                                   screenFrame: visibleFrame,
                                                                   axis: .vertical,
                                                                   movedEdge: .bottom,
                                                                   tolerance: 8,
                                                                   gapSize: 0))
    }

    func testCleanupSourceFallsBackToDepartedMinimumRestrictedCornerAndExpandsAdjacent() {
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = 40
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let manager = WindowManager()
        let departedTopRight = CGRect(x: 610, y: 560, width: 600, height: 360)
        let bottomRight = CooperativeCornerResize.Candidate(id: 2,
                                                            frame: CGRect(x: 610, y: 20, width: 600, height: 540))
        guard let sourceFrame = manager.cleanupSourceFrame(action: .topRight,
                                                           oldFocusedFrame: departedTopRight,
                                                           candidates: [bottomRight],
                                                           screenFrame: visibleFrame,
                                                           axis: .vertical,
                                                           movedEdge: .bottom,
                                                           tolerance: 8,
                                                           captureTolerance: 96,
                                                           gapSize: 0),
              let targetFrame = manager.cleanupTargetFrame(action: .topRight,
                                                           observedFrame: sourceFrame,
                                                           screenFrame: visibleFrame,
                                                           axis: .vertical,
                                                           movedEdge: .bottom,
                                                           tolerance: 8,
                                                           includeCycleTargets: false),
              let plan = CooperativeCornerResize.plan(oldFocusedFrame: sourceFrame,
                                                      newFocusedFrame: targetFrame,
                                                      screenFrame: visibleFrame,
                                                      candidates: [bottomRight],
                                                      axis: .vertical,
                                                      tolerance: 8,
                                                      minimumSize: CGSize(width: 100, height: 100),
                                                      focusedMinimumSize: CGSize(width: 1, height: 1),
                                                      movedEdgeOverride: .bottom,
                                                      candidateDiscoveryFrame: sourceFrame,
                                                      actionDescription: "cooperative resize cleanup after focused window left source")
        else {
            XCTFail("Expected departed minimum-restricted corner cleanup plan")
            return
        }

        assertRect(sourceFrame, equals: departedTopRight)
        assertRect(targetFrame, equals: CGRect(x: 610, y: 620, width: 600, height: 300))
        assertRect(plan.adjustments[0].newFrame, equals: CGRect(x: 610, y: 20, width: 600, height: 600))
    }

    func testCleanupSourceDoesNotFallBackToDepartedCycleCorner() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let cycledTopRight = CGRect(x: 610, y: 320, width: 600, height: 600)
        let bottomRight = CooperativeCornerResize.Candidate(id: 2,
                                                            frame: CGRect(x: 610, y: 20, width: 600, height: 300))

        let sourceFrame = WindowManager().cleanupSourceFrame(action: .topRight,
                                                            oldFocusedFrame: cycledTopRight,
                                                            candidates: [bottomRight],
                                                            screenFrame: visibleFrame,
                                                            axis: .vertical,
                                                            movedEdge: .bottom,
                                                            tolerance: 8,
                                                            captureTolerance: 96,
                                                            gapSize: 0)

        XCTAssertNil(sourceFrame)
    }

    func testCleanupDestinationRejectsNonAdjacentCycleSourceCleanup() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let manager = WindowManager()
        let cycledBottomRight = CGRect(x: 610, y: 20, width: 600, height: 600)
        let focusedTopLeftDestination = CGRect(x: 10, y: 620, width: 600, height: 300)
        let hypotheticalCleanupTarget = CGRect(x: 610, y: 20, width: 600, height: 450)

        XCTAssertFalse(manager.frameIsAdjacentToCleanupSource(focusedTopLeftDestination,
                                                              sourceFrame: cycledBottomRight,
                                                              movedEdge: .top,
                                                              axis: .vertical,
                                                              tolerance: 8,
                                                              gapSize: 0))
        XCTAssertFalse(manager.cleanupDestinationAllowsSourceResize(action: .bottomRight,
                                                                    observedFrame: cycledBottomRight,
                                                                    targetFrame: hypotheticalCleanupTarget,
                                                                    focusedDestinationFrame: focusedTopLeftDestination,
                                                                    screenFrame: visibleFrame,
                                                                    axis: .vertical,
                                                                    movedEdge: .top,
                                                                    tolerance: 8,
                                                                    gapSize: 0))
    }

    func testCleanupTargetDoesNotShrinkComplementOfMinimumRestrictedAdjacent() {
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let complementaryBottomRight = CGRect(x: 610, y: 20, width: 600, height: 540)
        let minimumBandTopRight = CooperativeCornerResize.Candidate(id: 2,
                                                                    frame: CGRect(x: 610, y: 560, width: 600, height: 360))

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .bottomRight,
                                                              observedFrame: complementaryBottomRight,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .top,
                                                              tolerance: 8,
                                                              includeCycleTargets: false,
                                                              candidates: [minimumBandTopRight])

        XCTAssertNil(cleanupTarget)
    }

    func testCleanupTargetDoesNotShrinkInitialCycleSourceWithMinimumCycleAdjacent() {
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let cycledBottomLeft = CGRect(x: 10, y: 20, width: 600, height: 600)
        let selectedCycleTopLeft = CooperativeCornerResize.Candidate(id: 2,
                                                                     frame: CGRect(x: 10, y: 620, width: 600, height: 300))

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .bottomLeft,
                                                              observedFrame: cycledBottomLeft,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .top,
                                                              tolerance: 8,
                                                              includeCycleTargets: false,
                                                              candidates: [selectedCycleTopLeft])

        XCTAssertNil(cleanupTarget)
    }

    func testCleanupTargetDoesNotShrinkRepeatedCycleSourceWithMinimumCycleAdjacent() {
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let cycledBottomLeft = CGRect(x: 10, y: 20, width: 600, height: 600)
        let selectedCycleTopLeft = CooperativeCornerResize.Candidate(id: 2,
                                                                     frame: CGRect(x: 10, y: 620, width: 600, height: 300))

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .bottomLeft,
                                                              observedFrame: cycledBottomLeft,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .top,
                                                              tolerance: 8,
                                                              includeCycleTargets: true,
                                                              candidates: [selectedCycleTopLeft])

        XCTAssertNil(cleanupTarget)
    }

    func testCleanupTargetDoesNotShrinkValidCycleCornerFromOriginalLocation() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let cycledTopRight = CGRect(x: 610, y: 320, width: 600, height: 600)
        let minimumCycleBottomRight = CooperativeCornerResize.Candidate(id: 2,
                                                                        frame: CGRect(x: 610, y: 20, width: 600, height: 300))

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .topRight,
                                                              observedFrame: cycledTopRight,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .bottom,
                                                              tolerance: 8,
                                                              includeCycleTargets: false,
                                                              candidates: [minimumCycleBottomRight])

        XCTAssertNil(cleanupTarget)
    }

    func testCleanupTargetDoesNotShrinkComplementOfSelectedAdjacentCycleSize() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = [.oneHalf, .oneThird]

        let complementaryBottomLeft = CGRect(x: 10, y: 20, width: 600, height: 600)
        let selectedCycleTopLeft = CooperativeCornerResize.Candidate(id: 2,
                                                                     frame: CGRect(x: 10, y: 620, width: 600, height: 300))

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .bottomLeft,
                                                              observedFrame: complementaryBottomLeft,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .top,
                                                              tolerance: 8,
                                                              includeCycleTargets: false,
                                                              candidates: [selectedCycleTopLeft])

        XCTAssertNil(cleanupTarget)
    }

    func testCleanupTargetDoesNotShrinkBalancedCorner() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let bottomRight = CGRect(x: 610, y: 20, width: 600, height: 450)
        let balancedTopRight = CooperativeCornerResize.Candidate(id: 2,
                                                                 frame: CGRect(x: 610, y: 470, width: 600, height: 450))

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .bottomRight,
                                                              observedFrame: bottomRight,
                                                              screenFrame: visibleFrame,
                                                              axis: .vertical,
                                                              movedEdge: .top,
                                                              tolerance: 8,
                                                              includeCycleTargets: false,
                                                              candidates: [balancedTopRight])

        XCTAssertNil(cleanupTarget)
    }

    func testRepeatedCornerLookAheadSkipsExpansionWhenAdjacentIsInMinimumCycleBand() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let oldFocusedFrame = CGRect(x: 10, y: 20, width: 600, height: 540)
        let requestedTwoThirdsFrame = CGRect(x: 10, y: 20, width: 600, height: 600)
        let minimumRestrictedTop = CooperativeCornerResize.Candidate(id: 2,
                                                                     frame: CGRect(x: 10, y: 560, width: 600, height: 360))

        let lookAheadTarget = WindowManager().cycleLookAheadTargetForMinimumRestrictedAdjacent(action: .bottomLeft,
                                                                                               oldFocusedFrame: oldFocusedFrame,
                                                                                               requestedFocusedFrame: requestedTwoThirdsFrame,
                                                                                               screenFrame: visibleFrame,
                                                                                               candidates: [minimumRestrictedTop],
                                                                                               axis: .vertical,
                                                                                               movedEdge: .top,
                                                                                               tolerance: 8,
                                                                                               gapSize: 0)

        XCTAssertEqual(lookAheadTarget?.skippedCycleSize, .twoThirds)
        XCTAssertEqual(lookAheadTarget?.targetCycleSize, .oneThird)
        XCTAssertEqual(lookAheadTarget?.restrictedAdjacentId, 2)
        assertRect(lookAheadTarget?.rawFrame ?? .null, equals: CGRect(x: 10, y: 20, width: 600, height: 300))
        assertRect(lookAheadTarget?.gappedFrame ?? .null, equals: CGRect(x: 10, y: 20, width: 600, height: 300))
    }

    func testRepeatedCornerLookAheadDoesNotSkipWhenAdjacentIsAtCycleBoundary() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let oldFocusedFrame = CGRect(x: 10, y: 20, width: 600, height: 450)
        let requestedTwoThirdsFrame = CGRect(x: 10, y: 20, width: 600, height: 600)
        let halfHeightTop = CooperativeCornerResize.Candidate(id: 2,
                                                              frame: CGRect(x: 10, y: 470, width: 600, height: 450))

        let lookAheadTarget = WindowManager().cycleLookAheadTargetForMinimumRestrictedAdjacent(action: .bottomLeft,
                                                                                               oldFocusedFrame: oldFocusedFrame,
                                                                                               requestedFocusedFrame: requestedTwoThirdsFrame,
                                                                                               screenFrame: visibleFrame,
                                                                                               candidates: [halfHeightTop],
                                                                                               axis: .vertical,
                                                                                               movedEdge: .top,
                                                                                               tolerance: 8,
                                                                                               gapSize: 0)

        XCTAssertNil(lookAheadTarget)
    }

    func testRepeatedCornerLookAheadWrapsPastMaximumBlockedByMinimumRestrictedAdjacent() {
        let screenFrame = CGRect(x: 0, y: 140, width: 3200, height: 1660)
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = Set(CycleSize.allCases)
        Defaults.gapSize.value = 20
        ActiveSideSplitRatios.shared.resetAll()

        let achievedBottomLeft = CGRect(x: 20, y: 160, width: 2200, height: 1100)
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.bottomLeft,
                                                                    achievedFrame: achievedBottomLeft,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: 20)
        let cycleParams = RectCalculationParameters(window: Window(id: 1, rect: achievedBottomLeft),
                                                    visibleFrameOfScreen: screenFrame,
                                                    action: .bottomLeft,
                                                    lastAction: nil)
        let rawThreeQuarters = WindowCalculationFactory.lowerLeftCalculation.calculateFractionalRect(cycleParams,
                                                                                                      fraction: CycleSize.threeQuarters.fraction).rect
        let requestedThreeQuarters = GapCalculation.applyGaps(rawThreeQuarters,
                                                              sharedEdges: WindowAction.bottomLeft.gapSharedEdge,
                                                              gapSize: 20)
        let minimumRestrictedTop = CooperativeCornerResize.Candidate(id: 2,
                                                                     frame: CGRect(x: 20, y: 1280, width: 2200, height: 500))

        let lookAheadTarget = WindowManager().cycleLookAheadTargetForMinimumRestrictedAdjacent(action: .bottomLeft,
                                                                                               oldFocusedFrame: achievedBottomLeft,
                                                                                               requestedFocusedFrame: requestedThreeQuarters,
                                                                                               screenFrame: screenFrame,
                                                                                               candidates: [minimumRestrictedTop],
                                                                                               axis: .vertical,
                                                                                               movedEdge: .top,
                                                                                               tolerance: 24,
                                                                                               gapSize: 20)

        XCTAssertEqual(lookAheadTarget?.skippedCycleSize, .threeQuarters)
        XCTAssertEqual(lookAheadTarget?.targetCycleSize, .oneQuarter)
        XCTAssertEqual(lookAheadTarget?.gappedFrame.height ?? -1, 385, accuracy: 0.001)
    }

    func testRestrictedHeightCornerLeavingAttemptsNextSmallerCycleSize() {
        let screenFrame = CGRect(x: 0, y: 140, width: 3200, height: 1660)
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        Defaults.verticalSplitRatio.value = CycleSize.oneThird.percentValue
        Defaults.cornerCycleExpansionAxis.value = .vertical
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = Set(CycleSize.allCases)
        Defaults.gapSize.value = 20
        ActiveSideSplitRatios.shared.resetAll()

        let minimumRestrictedTop = CGRect(x: 20, y: 1280, width: 2200, height: 500)
        ActiveSideSplitRatios.shared.recordAchievedCooperativeAction(.topLeft,
                                                                    achievedFrame: minimumRestrictedTop,
                                                                    screenFrame: screenFrame,
                                                                    gapSize: 20)

        let cleanupTarget = WindowManager().cleanupTargetFrame(action: .topLeft,
                                                              observedFrame: minimumRestrictedTop,
                                                              screenFrame: screenFrame,
                                                              axis: .vertical,
                                                              movedEdge: .bottom,
                                                              tolerance: 24,
                                                              includeCycleTargets: false,
                                                              gapSize: 20)

        assertRect(cleanupTarget ?? .null, equals: CGRect(x: 20, y: 1395, width: 2200, height: 385))
    }

    func testCleanupSourceAdjacencyOnlyMatchesDirectDestination() {
        let manager = WindowManager()
        let sourceTopLeft = CGRect(x: 10, y: 400, width: 800, height: 520)
        let adjacentBottomLeft = CGRect(x: 10, y: 20, width: 800, height: 380)
        let otherBottom = CGRect(x: 810, y: 20, width: 400, height: 380)
        let sourceBottomRight = CGRect(x: 610, y: 20, width: 600, height: 540)
        let diagonalTopLeft = CGRect(x: 10, y: 560, width: 600, height: 360)

        XCTAssertTrue(manager.frameIsAdjacentToCleanupSource(adjacentBottomLeft,
                                                             sourceFrame: sourceTopLeft,
                                                             movedEdge: .bottom,
                                                             axis: .vertical,
                                                             tolerance: 8,
                                                             gapSize: 0))
        XCTAssertFalse(manager.frameIsAdjacentToCleanupSource(otherBottom,
                                                              sourceFrame: sourceTopLeft,
                                                              movedEdge: .bottom,
                                                              axis: .vertical,
                                                              tolerance: 8,
                                                              gapSize: 0))
        XCTAssertFalse(manager.frameIsAdjacentToCleanupSource(adjacentBottomLeft,
                                                              sourceFrame: sourceTopLeft,
                                                              movedEdge: .right,
                                                              axis: .vertical,
                                                              tolerance: 8,
                                                              gapSize: 0))
        XCTAssertFalse(manager.frameIsAdjacentToCleanupSource(diagonalTopLeft,
                                                              sourceFrame: sourceBottomRight,
                                                              movedEdge: .top,
                                                              axis: .vertical,
                                                              tolerance: 8,
                                                              gapSize: 0))
    }

    func testRepeatedCornersWithVerticalExpansionCycleHeightOnly() {
        setSplitRatio(60)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        assertRepeatedCornerRects(
            topLeft: CGRect(x: 10, y: 320, width: 720, height: 600),
            topRight: CGRect(x: 730, y: 320, width: 480, height: 600),
            bottomLeft: CGRect(x: 10, y: 20, width: 720, height: 600),
            bottomRight: CGRect(x: 730, y: 20, width: 480, height: 600)
        )
    }

    func testRepeatedHalfActionsStillCycleOnTheirNaturalAxis() {
        setSplitRatio(60)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        assertRect(WindowCalculationFactory.leftHalfCalculation.calculateRepeatedRect(repeatedParams(for: .leftHalf)).rect,
                   equals: CGRect(x: 10, y: 20, width: 800, height: 900))
        assertRect(WindowCalculationFactory.rightHalfCalculation.calculateRepeatedRect(repeatedParams(for: .rightHalf)).rect,
                   equals: CGRect(x: 410, y: 20, width: 800, height: 900))

        Defaults.cornerCycleExpansionAxis.value = .horizontal

        assertRect(WindowCalculationFactory.topHalfCalculation.calculateRect(repeatedParams(for: .topHalf)).rect,
                   equals: CGRect(x: 10, y: 320, width: 1200, height: 600))
        assertRect(WindowCalculationFactory.bottomHalfCalculation.calculateRect(repeatedParams(for: .bottomHalf)).rect,
                   equals: CGRect(x: 10, y: 20, width: 1200, height: 600))
    }

    func testRepeatedHalfActionStartsAtFirstSelectedCycleSizeWhenOneHalfIsDeselected() {
        setSplitRatio(50)
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = [.oneThird, .twoThirds]

        let firstRepeatedRect = WindowCalculationFactory.bottomHalfCalculation.calculateRepeatedRect(repeatedParams(for: .bottomHalf)).rect
        let secondRepeatedRect = WindowCalculationFactory.bottomHalfCalculation.calculateRepeatedRect(repeatedParams(for: .bottomHalf, currentRect: firstRepeatedRect, count: 2)).rect

        assertRect(firstRepeatedRect, equals: CGRect(x: 10, y: 20, width: 1200, height: 600))
        assertRect(secondRepeatedRect, equals: CGRect(x: 10, y: 20, width: 1200, height: 300))
    }

    func testRepeatedBottomCornerStartsAtFirstSelectedCycleSizeWhenOneHalfIsDeselected() {
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = [.oneThird, .twoThirds]

        let firstRect = WindowCalculationFactory.lowerLeftCalculation.calculateRect(params(for: .bottomLeft)).rect
        let firstRepeatedRect = WindowCalculationFactory.lowerLeftCalculation.calculateRect(repeatedParams(for: .bottomLeft, currentRect: firstRect)).rect
        let secondRepeatedRect = WindowCalculationFactory.lowerLeftCalculation.calculateRect(repeatedParams(for: .bottomLeft, currentRect: firstRepeatedRect, count: 2)).rect

        assertRect(firstRect, equals: CGRect(x: 10, y: 20, width: 600, height: 450))
        assertRect(firstRepeatedRect, equals: CGRect(x: 10, y: 20, width: 600, height: 600))
        assertRect(secondRepeatedRect, equals: CGRect(x: 10, y: 20, width: 600, height: 300))
    }

    func testRepeatedSideShortcutAdvancesWhenCurrentFrameMatchesSplitRatioCycleSize() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        setSplitRatio(CycleSize.twoThirds.percentValue)

        let leftFrame = WindowCalculationFactory.leftHalfCalculation.calculateRect(params(for: .leftHalf)).rect
        let repeatedLeftFrame = WindowCalculationFactory.leftHalfCalculation.calculateRepeatedRect(repeatedParams(for: .leftHalf, currentRect: leftFrame)).rect

        assertRect(leftFrame, equals: CGRect(x: 10, y: 20, width: 800, height: 900))
        assertRect(repeatedLeftFrame, equals: CGRect(x: 10, y: 20, width: 400, height: 900))
    }

    func testRepeatedTopShortcutAdvancesWhenCurrentFrameMatchesSplitRatioCycleSize() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        setSplitRatio(CycleSize.twoThirds.percentValue)

        let topFrame = WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf)).rect
        let repeatedTopFrame = WindowCalculationFactory.topHalfCalculation.calculateRepeatedRect(repeatedParams(for: .topHalf, currentRect: topFrame)).rect

        assertRect(topFrame, equals: CGRect(x: 10, y: 320, width: 1200, height: 600))
        assertRect(repeatedTopFrame, equals: CGRect(x: 10, y: 620, width: 1200, height: 300))
    }

    func testRepeatedRightShortcutUpdatesActiveSplitForSubsequentCorners() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        Defaults.verticalSplitRatio.value = 50
        ActiveSideSplitRatios.shared.resetAll()

        let firstRightFrame = WindowCalculationFactory.rightHalfCalculation.calculateRect(params(for: .rightHalf)).rect
        let repeatedRightFrame = WindowCalculationFactory.rightHalfCalculation.calculateRepeatedRect(repeatedParams(for: .rightHalf,
                                                                                                                    currentRect: firstRightFrame)).rect

        ActiveSideSplitRatios.shared.recordSideAction(.rightHalf,
                                                      targetFrame: repeatedRightFrame,
                                                      screenFrame: visibleFrame)

        let topRightFrame = WindowCalculationFactory.upperRightCalculation.calculateRect(params(for: .topRight)).rect
        let topLeftFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(params(for: .topLeft)).rect

        assertRect(firstRightFrame, equals: CGRect(x: 810, y: 20, width: 400, height: 900))
        assertRect(repeatedRightFrame, equals: CGRect(x: 410, y: 20, width: 800, height: 900))
        assertRect(topRightFrame, equals: CGRect(x: 410, y: 470, width: 800, height: 450))
        assertRect(topLeftFrame, equals: CGRect(x: 10, y: 470, width: 400, height: 450))
        XCTAssertEqual(Defaults.horizontalSplitRatio.value, CycleSize.twoThirds.percentValue, accuracy: 0.001)
    }

    func testRepeatedBottomShortcutUpdatesActiveSplitForSubsequentCorners() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = CycleSize.twoThirds.percentValue
        ActiveSideSplitRatios.shared.resetAll()

        let firstBottomFrame = WindowCalculationFactory.bottomHalfCalculation.calculateRect(params(for: .bottomHalf)).rect
        let repeatedBottomFrame = WindowCalculationFactory.bottomHalfCalculation.calculateRepeatedRect(repeatedParams(for: .bottomHalf,
                                                                                                                      currentRect: firstBottomFrame)).rect

        ActiveSideSplitRatios.shared.recordSideAction(.bottomHalf,
                                                      targetFrame: repeatedBottomFrame,
                                                      screenFrame: visibleFrame)

        let bottomRightFrame = WindowCalculationFactory.lowerRightCalculation.calculateRect(params(for: .bottomRight)).rect
        let topRightFrame = WindowCalculationFactory.upperRightCalculation.calculateRect(params(for: .topRight)).rect

        assertRect(firstBottomFrame, equals: CGRect(x: 10, y: 20, width: 1200, height: 300))
        assertRect(repeatedBottomFrame, equals: CGRect(x: 10, y: 20, width: 1200, height: 600))
        assertRect(bottomRightFrame, equals: CGRect(x: 610, y: 20, width: 600, height: 600))
        assertRect(topRightFrame, equals: CGRect(x: 610, y: 620, width: 600, height: 300))
        XCTAssertEqual(Defaults.verticalSplitRatio.value, CycleSize.twoThirds.percentValue, accuracy: 0.001)
    }

    func testActiveSideSplitIsScopedToDisplayFrame() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        ActiveSideSplitRatios.shared.resetAll()

        let cycledRightFrame = CGRect(x: 410, y: 20, width: 800, height: 900)
        let otherDisplayFrame = CGRect(x: 2000, y: 20, width: 1200, height: 900)

        ActiveSideSplitRatios.shared.recordSideAction(.rightHalf,
                                                      targetFrame: cycledRightFrame,
                                                      screenFrame: visibleFrame)

        XCTAssertEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: visibleFrame),
                       CycleSize.oneThird.fraction,
                       accuracy: 0.001)
        XCTAssertEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: otherDisplayFrame),
                       CycleSize.twoThirds.fraction,
                       accuracy: 0.001)
    }

    func testChangingSavedSplitRatioResetsActiveRuntimeSplit() {
        Defaults.horizontalSplitRatio.value = CycleSize.twoThirds.percentValue
        ActiveSideSplitRatios.shared.resetAll()
        ActiveSideSplitRatios.shared.recordSideAction(.rightHalf,
                                                      targetFrame: CGRect(x: 410, y: 20, width: 800, height: 900),
                                                      screenFrame: visibleFrame)

        Defaults.horizontalSplitRatio.value = 50

        XCTAssertEqual(ActiveSideSplitRatios.shared.horizontalRatio(for: visibleFrame), 0.5, accuracy: 0.001)
    }

    func testHorizontalCornerShortcutCanCycleAfterCompatibleSideShortcut() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .horizontal

        let leftFrame = WindowCalculationFactory.leftHalfCalculation.calculateRect(params(for: .leftHalf)).rect
        let topLeftFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(RectCalculationParameters(window: Window(id: 1, rect: leftFrame),
                                                                                                                visibleFrameOfScreen: visibleFrame,
                                                                                                                action: .topLeft,
                                                                                                                lastAction: RectangleAction(action: .leftHalf,
                                                                                                                                            subAction: nil,
                                                                                                                                            rect: leftFrame,
                                                                                                                                            count: 1))).rect

        assertRect(topLeftFrame, equals: CGRect(x: 10, y: 470, width: 800, height: 450))
    }

    func testVerticalCornerShortcutCanCycleAfterCompatibleSideShortcut() {
        guard Defaults.cooperativeCornerResize.enabled else { return }
        setSplitRatio(50)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let topFrame = WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf)).rect
        let topLeftFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(RectCalculationParameters(window: Window(id: 1, rect: topFrame),
                                                                                                                visibleFrameOfScreen: visibleFrame,
                                                                                                                action: .topLeft,
                                                                                                                lastAction: RectangleAction(action: .topHalf,
                                                                                                                                            subAction: nil,
                                                                                                                                            rect: topFrame,
                                                                                                                                            count: 1))).rect

        assertRect(topLeftFrame, equals: CGRect(x: 10, y: 320, width: 600, height: 600))
    }

    func testDifferentTopCornerShortcutDoesNotTriggerVerticalExpansionCycleAtOneThirdSplit() {
        setSplitRatio(CycleSize.oneThird.percentValue)
        Defaults.cornerCycleExpansionAxis.value = .vertical

        let topLeftFrame = WindowCalculationFactory.upperLeftCalculation.calculateRect(params(for: .topLeft)).rect
        let topRightFrame = WindowCalculationFactory.upperRightCalculation.calculateRect(RectCalculationParameters(window: Window(id: 1, rect: topLeftFrame),
                                                                                                                  visibleFrameOfScreen: visibleFrame,
                                                                                                                  action: .topRight,
                                                                                                                  lastAction: RectangleAction(action: .topLeft,
                                                                                                                                              subAction: nil,
                                                                                                                                              rect: topLeftFrame,
                                                                                                                                              count: 1))).rect

        assertRect(topLeftFrame, equals: CGRect(x: 10, y: 620, width: 400, height: 300))
        assertRect(topRightFrame, equals: CGRect(x: 410, y: 620, width: 800, height: 300))
    }

    func testRepeatedHalfActionWithNoCycleSizesSelectedUsesFirstRect() {
        setSplitRatio(60)
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = []

        assertRect(WindowCalculationFactory.leftHalfCalculation.calculateRepeatedRect(repeatedParams(for: .leftHalf)).rect,
                   equals: CGRect(x: 10, y: 20, width: 720, height: 900))
    }

    func testRepeatedCornerActionWithNoCycleSizesSelectedUsesFirstRect() {
        setSplitRatio(60)
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = []

        let firstRect = WindowCalculationFactory.upperLeftCalculation.calculateRect(params(for: .topLeft)).rect
        let repeatedRect = WindowCalculationFactory.upperLeftCalculation.calculateRect(repeatedParams(for: .topLeft, currentRect: firstRect)).rect

        assertRect(repeatedRect, equals: firstRect)
    }
    
    private func setSplitRatio(_ percent: Float) {
        Defaults.horizontalSplitRatio.value = percent
        Defaults.verticalSplitRatio.value = percent
    }
    
    private func assertCornerRects(topLeft: CGRect, topRight: CGRect, bottomLeft: CGRect, bottomRight: CGRect) {
        assertRect(WindowCalculationFactory.upperLeftCalculation.calculateRect(params(for: .topLeft)).rect, equals: topLeft)
        assertRect(WindowCalculationFactory.upperRightCalculation.calculateRect(params(for: .topRight)).rect, equals: topRight)
        assertRect(WindowCalculationFactory.lowerLeftCalculation.calculateRect(params(for: .bottomLeft)).rect, equals: bottomLeft)
        assertRect(WindowCalculationFactory.lowerRightCalculation.calculateRect(params(for: .bottomRight)).rect, equals: bottomRight)
    }

    private func assertRepeatedCornerRects(topLeft: CGRect, topRight: CGRect, bottomLeft: CGRect, bottomRight: CGRect) {
        let topLeftBase = WindowCalculationFactory.upperLeftCalculation.calculateRect(params(for: .topLeft)).rect
        let topRightBase = WindowCalculationFactory.upperRightCalculation.calculateRect(params(for: .topRight)).rect
        let bottomLeftBase = WindowCalculationFactory.lowerLeftCalculation.calculateRect(params(for: .bottomLeft)).rect
        let bottomRightBase = WindowCalculationFactory.lowerRightCalculation.calculateRect(params(for: .bottomRight)).rect

        assertRect(WindowCalculationFactory.upperLeftCalculation.calculateRect(repeatedParams(for: .topLeft, currentRect: topLeftBase)).rect, equals: topLeft)
        assertRect(WindowCalculationFactory.upperRightCalculation.calculateRect(repeatedParams(for: .topRight, currentRect: topRightBase)).rect, equals: topRight)
        assertRect(WindowCalculationFactory.lowerLeftCalculation.calculateRect(repeatedParams(for: .bottomLeft, currentRect: bottomLeftBase)).rect, equals: bottomLeft)
        assertRect(WindowCalculationFactory.lowerRightCalculation.calculateRect(repeatedParams(for: .bottomRight, currentRect: bottomRightBase)).rect, equals: bottomRight)
    }
    
    private func params(for action: WindowAction) -> RectCalculationParameters {
        RectCalculationParameters(window: Window(id: 1, rect: visibleFrame),
                                  visibleFrameOfScreen: visibleFrame,
                                  action: action,
                                  lastAction: nil)
    }

    private func repeatedParams(for action: WindowAction, currentRect: CGRect? = nil, count: Int = 1) -> RectCalculationParameters {
        RectCalculationParameters(window: Window(id: 1, rect: currentRect ?? visibleFrame),
                                  visibleFrameOfScreen: visibleFrame,
                                  action: action,
                                  lastAction: RectangleAction(action: action,
                                                              subAction: nil,
                                                              rect: currentRect ?? visibleFrame,
                                                              count: count))
    }
    
    private func assertRect(_ rect: CGRect, equals expected: CGRect, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(rect.origin.x, expected.origin.x, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rect.origin.y, expected.origin.y, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rect.width, expected.width, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(rect.height, expected.height, accuracy: 0.001, file: file, line: line)
    }
}


class SnappingManagerSessionTests: XCTestCase {

    private var savedSnappingEnabled: Bool?

    override func setUp() {
        super.setUp()
        savedSnappingEnabled = Defaults.windowSnapping.enabled
        Defaults.windowSnapping.enabled = false
    }

    override func tearDown() {
        super.tearDown()
        Defaults.windowSnapping.enabled = savedSnappingEnabled
    }

    func testSessionDidBecomeActiveTriggersCheckFullScreen() {
        let sm = SnappingManager()
        sm.isFullScreen = true

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        XCTAssertFalse(sm.isFullScreen,
            "receiveSessionNote should call checkFullScreen, re-evaluating isFullScreen")
    }

    func testSessionDidBecomeActiveEventMonitorPreserved() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "toggleListening should be called but preserve event monitor state")
    }

    func testSessionDidBecomeActiveDoesNotEnableSnapping() {
        let sm = SnappingManager()

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        XCTAssertNil(sm.eventMonitor,
            "snapping should remain disabled after session became active notification")
    }

    func testSessionDidBecomeActiveMultiplePostsNoCrash() {
        let sm = SnappingManager()

        for _ in 0..<5 {
            NSWorkspace.shared.notificationCenter.post(
                name: NSWorkspace.sessionDidBecomeActiveNotification,
                object: nil
            )
        }

        XCTAssertFalse(sm.isFullScreen)
    }

    func testSleepWakeMaintainsSnapping() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "activeSpaceDidChange (simulating wake) should preserve event monitor state")
    }

    func testSessionUnlockThenWakeMaintainsSnapping() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "session unlock followed by wake should restore event monitor state")
    }

    func testSessionUnlockWithDisabledSnapping() {
        let sm = SnappingManager()

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        XCTAssertNil(sm.eventMonitor,
            "session unlock -> wake should not enable snapping when disabled")
    }

    func testFullScreenThenWakeThenLeaveFullScreen() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "session restore after full screen should preserve event monitor state")
    }

    func testSessionResignActiveDoesNotCrash() {
        let sm = SnappingManager()

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )

        XCTAssertFalse(sm.isFullScreen)
    }

    func testSessionResignActiveThenBecomeActive() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "session resign then become active should preserve event monitor state")
    }

    func testScreensDoNotSleepNotificationsBreakSnapping() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "screen sleep then wake should preserve event monitor state")
    }

    func testScreenSleepSessionResignThenWakeAndSessionActive() {
        Defaults.windowSnapping.enabled = true
        let sm = SnappingManager()
        let wasRunning = sm.eventMonitor?.running ?? false

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.post(
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )

        let isRunning = sm.eventMonitor?.running ?? false
        XCTAssertEqual(isRunning, wasRunning,
            "screen sleep + session resign -> session active + wake should restore event monitor state")
    }
}

class ShortcutManagerSessionTests: XCTestCase {

    private final class ValueBox<Value> {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }
    }

    private final class BindingStoreSpy: ShortcutBindingStore {
        private(set) var configureCallCount = 0
        private(set) var registeredDefaultKeys = Set<String>()
        private(set) var boundKeys = Set<String>()
        private(set) var bindCallCount = 0
        private(set) var breakBindingCallCount = 0

        func configure() {
            configureCallCount += 1
        }

        func registerDefaultShortcuts(_ shortcuts: [String: MASShortcut]) {
            registeredDefaultKeys.formUnion(shortcuts.keys)
        }

        func bindShortcut(withDefaultsKey defaultsKey: String, toAction action: @escaping () -> Void) {
            bindCallCount += 1
            boundKeys.insert(defaultsKey)
        }

        func breakBinding(withDefaultsKey defaultsKey: String) {
            breakBindingCallCount += 1
            boundKeys.remove(defaultsKey)
        }
    }

    private final class SchedulerSpy {
        private var scheduledActions = [() -> Void]()

        var pendingCount: Int {
            scheduledActions.count
        }

        func schedule(_ action: @escaping () -> Void) {
            scheduledActions.append(action)
        }

        func runNext() {
            guard !scheduledActions.isEmpty else {
                XCTFail("Expected a scheduled shortcut rebind")
                return
            }
            scheduledActions.removeFirst()()
        }
    }

    private struct Harness {
        let manager: ShortcutManager
        let bindingStore: BindingStoreSpy
        let notificationCenter: NotificationCenter
        let workspaceNotificationCenter: NotificationCenter
        let shortcuts: ValueBox<[WindowAction: MASShortcut]>
        let appDisabled: ValueBox<Bool>
        let scheduler: SchedulerSpy
        let appShortcutSessionStates: ValueBox<[Bool]>
    }

    private func shortcut(_ keyCode: Int) -> MASShortcut {
        MASShortcut(keyCode: keyCode, modifierFlags: [.command, .option])
    }

    private func makeHarness(
        initiallyActive: Bool = true,
        appDisabled: Bool = false,
        shortcuts: [WindowAction: MASShortcut]? = nil
    ) -> Harness {
        let bindingStore = BindingStoreSpy()
        let notificationCenter = NotificationCenter()
        let workspaceNotificationCenter = NotificationCenter()
        let shortcuts = ValueBox(shortcuts ?? [.leftHalf: shortcut(1)])
        let appDisabled = ValueBox(appDisabled)
        let scheduler = SchedulerSpy()
        let appShortcutSessionStates = ValueBox<[Bool]>([])
        let manager = ShortcutManager(
            windowManager: WindowManager(),
            bindingStore: bindingStore,
            notificationCenter: notificationCenter,
            workspaceNotificationCenter: workspaceNotificationCenter,
            shortcutsProvider: { shortcuts.value },
            activeStateProvider: { initiallyActive },
            appDisabledProvider: { appDisabled.value },
            scheduler: { scheduler.schedule($0) },
            appShortcutSessionStateChanged: { appShortcutSessionStates.value.append($0) }
        )

        return Harness(
            manager: manager,
            bindingStore: bindingStore,
            notificationCenter: notificationCenter,
            workspaceNotificationCenter: workspaceNotificationCenter,
            shortcuts: shortcuts,
            appDisabled: appDisabled,
            scheduler: scheduler,
            appShortcutSessionStates: appShortcutSessionStates
        )
    }

    private func resignSession(_ harness: Harness) {
        harness.workspaceNotificationCenter.post(
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )
    }

    private func activateSession(_ harness: Harness) {
        harness.workspaceNotificationCenter.post(
            name: NSWorkspace.sessionDidBecomeActiveNotification,
            object: nil
        )
    }

    func testActiveSessionResignThenDelayedActivationRestoresBindings() {
        let harness = makeHarness()
        let expectedKeys: Set<String> = [WindowAction.leftHalf.name]

        XCTAssertEqual(harness.bindingStore.boundKeys, expectedKeys)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [true])

        resignSession(harness)

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)
        XCTAssertEqual(harness.scheduler.pendingCount, 0)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [true, false])

        activateSession(harness)

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)
        XCTAssertEqual(harness.scheduler.pendingCount, 1)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [true, false])

        harness.scheduler.runNext()

        XCTAssertEqual(harness.bindingStore.boundKeys, expectedKeys)
        XCTAssertEqual(harness.scheduler.pendingCount, 0)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [true, false, true])
    }

    func testDuplicateSessionNotificationsAreIdempotent() {
        let harness = makeHarness()

        resignSession(harness)
        let breakCallsAfterFirstResign = harness.bindingStore.breakBindingCallCount

        resignSession(harness)

        XCTAssertEqual(harness.bindingStore.breakBindingCallCount, breakCallsAfterFirstResign)

        activateSession(harness)
        activateSession(harness)

        XCTAssertEqual(harness.scheduler.pendingCount, 1)

        harness.scheduler.runNext()
        let bindCallsAfterActivation = harness.bindingStore.bindCallCount

        activateSession(harness)

        XCTAssertEqual(harness.scheduler.pendingCount, 0)
        XCTAssertEqual(harness.bindingStore.bindCallCount, bindCallsAfterActivation)
        XCTAssertEqual(harness.bindingStore.boundKeys, [WindowAction.leftHalf.name])
    }

    func testActivationRestoresCurrentLogicalShortcutsAfterTheyChangeWhileInactive() {
        let harness = makeHarness()

        resignSession(harness)
        harness.shortcuts.value = [.rightHalf: shortcut(2)]

        activateSession(harness)
        harness.scheduler.runNext()

        XCTAssertEqual(harness.bindingStore.boundKeys, [WindowAction.rightHalf.name])
        XCTAssertFalse(harness.bindingStore.boundKeys.contains(WindowAction.leftHalf.name))
    }

    func testDisabledApplicationBlocksSessionRestore() {
        let harness = makeHarness()

        resignSession(harness)
        harness.appDisabled.value = true

        activateSession(harness)
        harness.scheduler.runNext()

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)
    }

    func testRecordingBlocksSessionRestoreUntilRecordingEnds() throws {
        let binder = try XCTUnwrap(MASShortcutBinder.shared())
        let previousBindingOptions = binder.bindingOptions
        binder.bindingOptions = [NSBindingOption.valueTransformerName: MASDictionaryTransformerName]
        defer {
            binder.bindingOptions = previousBindingOptions
        }

        let harness = makeHarness()

        harness.notificationCenter.post(name: .shortcutRecording, object: true)
        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)

        resignSession(harness)
        activateSession(harness)
        harness.scheduler.runNext()

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)

        harness.notificationCenter.post(name: .shortcutRecording, object: false)

        XCTAssertEqual(harness.bindingStore.boundKeys, [WindowAction.leftHalf.name])
    }

    func testInitiallyInactiveSessionDoesNotBindUntilActivationCompletes() {
        let harness = makeHarness(initiallyActive: false)

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)
        XCTAssertEqual(harness.scheduler.pendingCount, 0)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [false])

        activateSession(harness)

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)
        XCTAssertEqual(harness.scheduler.pendingCount, 1)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [false])

        harness.scheduler.runNext()

        XCTAssertEqual(harness.bindingStore.boundKeys, [WindowAction.leftHalf.name])
        XCTAssertEqual(harness.appShortcutSessionStates.value, [false, true])
    }

    func testResignBeforeQueuedActivationCompletesCancelsRestore() {
        let harness = makeHarness()

        resignSession(harness)
        activateSession(harness)
        XCTAssertEqual(harness.scheduler.pendingCount, 1)

        resignSession(harness)
        harness.scheduler.runNext()

        XCTAssertTrue(harness.bindingStore.boundKeys.isEmpty)
        XCTAssertEqual(harness.scheduler.pendingCount, 0)
        XCTAssertEqual(harness.appShortcutSessionStates.value, [true, false, false])
    }
}

class ShortcutCycleTests: XCTestCase {

    private func shortcut(_ keyCode: Int, _ flags: NSEvent.ModifierFlags) -> MASShortcut {
        MASShortcut(keyCode: keyCode, modifierFlags: flags)
    }

    func testSideShortcutActionsKeepLegacyDefaultsKeys() {
        XCTAssertEqual(WindowAction.leftHalf.name, "leftHalf")
        XCTAssertEqual(WindowAction.rightHalf.name, "rightHalf")
        XCTAssertEqual(WindowAction.centerHalf.name, "centerHalf")
        XCTAssertEqual(WindowAction.topHalf.name, "topHalf")
        XCTAssertEqual(WindowAction.bottomHalf.name, "bottomHalf")
    }

    func testRenamedSideShortcutAliasSyncWritesLegacyDefaultsKey() {
        let suiteName = "ShortcutCycleTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let centerSectionShortcut = shortcut(1, [.option, .command])
        let dictTransformer = ValueTransformer(forName: NSValueTransformerName(rawValue: MASDictionaryTransformerName))!
        let shortcutDict = dictTransformer.reverseTransformedValue(centerSectionShortcut)
        userDefaults.setValue(shortcutDict, forKey: "centerSection")

        MASShortcutMigration.syncRenamedSideShortcutAliases(userDefaults: userDefaults)

        XCTAssertNil(userDefaults.object(forKey: "centerSection"))
        XCTAssertNotNil(userDefaults.object(forKey: "centerHalf"))
        XCTAssertNotNil(ShortcutCycle.shortcut(for: .centerHalf, userDefaults: userDefaults))

        let updatedCenterHalfShortcut = shortcut(2, [.option, .command])
        let updatedShortcutDict = dictTransformer.reverseTransformedValue(updatedCenterHalfShortcut)
        userDefaults.setValue(updatedShortcutDict, forKey: "centerHalf")

        MASShortcutMigration.syncRenamedSideShortcutAliases(userDefaults: userDefaults)
        XCTAssertEqual(ShortcutCycle.shortcut(for: .centerHalf, userDefaults: userDefaults)?.keyCode, updatedCenterHalfShortcut.keyCode)
    }

    func testUniqueShortcutsProduceSingletonGroups() {
        let groups = ShortcutCycle.groups(
            actions: [.centerHalf, .centerThird],
            shortcutsByAction: [
                .centerHalf: shortcut(1, [.option, .command]),
                .centerThird: shortcut(2, [.option, .command])
            ]
        )

        XCTAssertEqual(groups.map(\.actions), [[.centerHalf], [.centerThird]])
        XCTAssertFalse(groups.contains { $0.isCycle })
    }

    func testDuplicateShortcutsFollowWindowActionActiveOrder() {
        let groups = ShortcutCycle.groups(
            actions: WindowAction.active,
            shortcutsByAction: [
                .centerHalf: shortcut(1, [.option, .command]),
                .centerThird: shortcut(1, [.option, .command])
            ]
        )

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.actions, [.centerHalf, .centerThird])
    }

    func testDuplicateShortcutStartsAtFirstActionWithoutPreviousAction() {
        let group = ShortcutCycle.Group(shortcut: shortcut(1, [.option, .command]), actions: [.centerHalf, .centerThird])

        XCTAssertEqual(group.action(after: nil), .centerHalf)
    }

    func testDuplicateShortcutSelectsNextActionAndWraps() {
        let group = ShortcutCycle.Group(shortcut: shortcut(1, [.option, .command]), actions: [.centerHalf, .centerThird])

        XCTAssertEqual(group.action(after: .centerHalf), .centerThird)
        XCTAssertEqual(group.action(after: .centerThird), .centerHalf)
    }

    func testDuplicateShortcutStartsAtFirstActionWhenPreviousActionIsOutsideGroup() {
        let group = ShortcutCycle.Group(shortcut: shortcut(1, [.option, .command]), actions: [.centerHalf, .centerThird])

        XCTAssertEqual(group.action(after: .maximize), .centerHalf)
    }

    func testStaleWindowHistoryIsIgnoredForCycleSelection() {
        let group = ShortcutCycle.Group(shortcut: shortcut(1, [.option, .command]), actions: [.centerHalf, .centerThird])
        let lastAction = RectangleAction(
            action: .centerHalf,
            subAction: nil,
            rect: CGRect(x: 0, y: 0, width: 500, height: 500),
            count: 1
        )

        let selectedAction = ShortcutCycle.action(
            in: group,
            lastAction: lastAction,
            currentWindowRect: CGRect(x: 20, y: 20, width: 500, height: 500)
        )

        XCTAssertEqual(selectedAction, .centerHalf)
    }

    func testDuplicateShortcutAssignmentsRemainReadableFromUserDefaults() {
        let suiteName = "ShortcutCycleTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer {
            userDefaults.removePersistentDomain(forName: suiteName)
        }

        let duplicatedShortcut = shortcut(1, [.option, .command])
        let dictTransformer = ValueTransformer(forName: NSValueTransformerName(rawValue: MASDictionaryTransformerName))!
        let shortcutDict = dictTransformer.reverseTransformedValue(duplicatedShortcut)
        userDefaults.setValue(shortcutDict, forKey: WindowAction.centerHalf.name)
        userDefaults.setValue(shortcutDict, forKey: WindowAction.centerThird.name)

        let shortcutsByAction = ShortcutCycle.shortcutsByAction(actions: [.centerHalf, .centerThird], userDefaults: userDefaults)
        let groups = ShortcutCycle.groups(actions: [.centerHalf, .centerThird], shortcutsByAction: shortcutsByAction)

        XCTAssertNotNil(ShortcutCycle.shortcut(for: .centerHalf, userDefaults: userDefaults))
        XCTAssertNotNil(ShortcutCycle.shortcut(for: .centerThird, userDefaults: userDefaults))
        XCTAssertEqual(groups.map(\.actions), [[.centerHalf, .centerThird]])
        XCTAssertEqual(groups.first?.representativeAction, .centerHalf)
    }
}

class AppShortcutValidatorTests: XCTestCase {

    private func shortcut(_ keyCode: Int, _ flags: NSEvent.ModifierFlags) -> MASShortcut {
        MASShortcut(keyCode: keyCode, modifierFlags: flags)
    }

    private func save(_ shortcut: MASShortcut, forKey key: String, in userDefaults: UserDefaults) {
        let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: MASDictionaryTransformerName))!
        userDefaults.set(transformer.reverseTransformedValue(shortcut), forKey: key)
    }

    func testWindowActionValidatorAllowsItsExistingAssignment() {
        let suiteName = "AppShortcutValidatorTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let existing = shortcut(1, [.option, .command])
        save(existing, forKey: WindowAction.centerHalf.name, in: userDefaults)

        let validator = AppShortcutValidator(defaultsKey: WindowAction.centerHalf.name, userDefaults: userDefaults)

        XCTAssertTrue(validator.isShortcutValid(existing))
        XCTAssertFalse(validator.isShortcutAlreadyTaken(bySystem: existing, explanation: nil))
    }

    func testWindowActionValidatorExplainsConflictWithAnotherAction() {
        let suiteName = "AppShortcutValidatorTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let duplicate = shortcut(1, [.option, .command])
        save(duplicate, forKey: WindowAction.centerHalf.name, in: userDefaults)
        var explanation: NSString?

        let validator = AppShortcutValidator(defaultsKey: WindowAction.centerThird.name, userDefaults: userDefaults)

        XCTAssertTrue(validator.isShortcutValid(duplicate))
        XCTAssertTrue(validator.isShortcutAlreadyTaken(bySystem: duplicate, explanation: &explanation))
        XCTAssertTrue(explanation?.contains(WindowAction.centerHalf.displayName ?? WindowAction.centerHalf.name) == true)
    }

    func testDuplicateCleanupKeepsFirstActionAndRemovesLaterAssignment() {
        let suiteName = "AppShortcutValidatorTests.\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let duplicate = shortcut(1, [.option, .command])
        save(duplicate, forKey: WindowAction.centerHalf.name, in: userDefaults)
        save(duplicate, forKey: WindowAction.centerThird.name, in: userDefaults)

        let removed = AppShortcutConflict.removeDuplicateAssignments(userDefaults: userDefaults)

        XCTAssertNotNil(userDefaults.object(forKey: WindowAction.centerHalf.name))
        XCTAssertNil(userDefaults.object(forKey: WindowAction.centerThird.name))
        XCTAssertEqual(removed, [WindowAction.centerThird.name])
    }
}

class ProductIdentityTests: XCTestCase {

    func testAppShowsInDockByDefault() {
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "LSUIElement") as? Bool, false)
    }
}

class ClampedWindowAlignerTests: XCTestCase {

    // Screen 2000x1200 at origin. Coordinates are already screen-flipped (window space):
    // the zone's maxY edge is the screen TOP, minY edge is the screen BOTTOM.

    func testRightHalfClampedBothAxesAnchorsRightCentersVertically() {
        let zone = CGRect(x: 1000, y: 0, width: 1000, height: 1200)
        let window = CGRect(x: 1000, y: 0, width: 600, height: 800) // narrower + shorter than zone
        let result = ClampedWindowAligner.aligned(window: window, inZone: zone, sharedEdges: [.right, .top, .bottom])
        XCTAssertEqual(result.origin.x, 1400, accuracy: 0.001) // zone.maxX - width = 2000 - 600
        XCTAssertEqual(result.origin.y, 200, accuracy: 0.001)  // centered: (1200 - 800)/2
        XCTAssertEqual(result.width, 600, accuracy: 0.001)
        XCTAssertEqual(result.height, 800, accuracy: 0.001)
    }

    func testRightHalfFullHeightLeavesVerticalUntouched() {
        let zone = CGRect(x: 1000, y: 0, width: 1000, height: 1200)
        let window = CGRect(x: 1000, y: 0, width: 600, height: 1200) // fills height
        let result = ClampedWindowAligner.aligned(window: window, inZone: zone, sharedEdges: [.right, .top, .bottom])
        XCTAssertEqual(result.origin.x, 1400, accuracy: 0.001)
        XCTAssertEqual(result.origin.y, 0, accuracy: 0.001)
    }

    func testLeftHalfClampedAnchorsLeftCentersVertically() {
        let zone = CGRect(x: 0, y: 0, width: 1000, height: 1200)
        let window = CGRect(x: 0, y: 0, width: 600, height: 800)
        let result = ClampedWindowAligner.aligned(window: window, inZone: zone, sharedEdges: [.left, .top, .bottom])
        XCTAssertEqual(result.origin.x, 0, accuracy: 0.001)
        XCTAssertEqual(result.origin.y, 200, accuracy: 0.001)
    }

    func testTopRightQuarterAnchorsToCorner() {
        let zone = CGRect(x: 1000, y: 600, width: 1000, height: 600) // top-right; maxY=1200=screen top
        let window = CGRect(x: 1000, y: 600, width: 600, height: 400)
        let result = ClampedWindowAligner.aligned(window: window, inZone: zone, sharedEdges: [.right, .top])
        XCTAssertEqual(result.origin.x, 1400, accuracy: 0.001) // maxX - width
        XCTAssertEqual(result.origin.y, 800, accuracy: 0.001)  // maxY - height = 1200 - 400
    }

    func testInteriorZoneCentersBothAxes() {
        let zone = CGRect(x: 600, y: 400, width: 800, height: 400)
        let window = CGRect(x: 600, y: 400, width: 400, height: 200)
        let result = ClampedWindowAligner.aligned(window: window, inZone: zone, sharedEdges: [])
        XCTAssertEqual(result.origin.x, 800, accuracy: 0.001) // (800-400)/2 + 600
        XCTAssertEqual(result.origin.y, 500, accuracy: 0.001) // (400-200)/2 + 400
    }

    func testExactFitReturnsUnchanged() {
        let zone = CGRect(x: 1000, y: 0, width: 1000, height: 1200)
        let window = zone
        let result = ClampedWindowAligner.aligned(window: window, inZone: zone, sharedEdges: [.right, .top, .bottom])
        XCTAssertTrue(result.equalTo(window))
    }

    func testEdgesAndCornersAlignmentKeepsHalfEdges() {
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1200)
        let rightHalf = CGRect(x: 1000, y: 0, width: 1000, height: 1200)
        let result = EdgeAlignment.edgesAndCorners.alignmentEdges(for: rightHalf, in: screenFrame)
        XCTAssertEqual(result, [.right, .top, .bottom])
    }

    func testCornersAlignmentCentersHalfEdges() {
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1200)
        let rightHalf = CGRect(x: 1000, y: 0, width: 1000, height: 1200)
        let result = EdgeAlignment.corners.alignmentEdges(for: rightHalf, in: screenFrame)
        XCTAssertEqual(result, .none)
    }

    func testCornersAlignmentKeepsCornerEdges() {
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1200)
        let topRight = CGRect(x: 1000, y: 600, width: 1000, height: 600)
        let result = EdgeAlignment.corners.alignmentEdges(for: topRight, in: screenFrame)
        XCTAssertEqual(result, [.right, .top])
    }

    func testCenteredAlignmentIgnoresSharedEdges() {
        let screenFrame = CGRect(x: 0, y: 0, width: 2000, height: 1200)
        let topRight = CGRect(x: 1000, y: 600, width: 1000, height: 600)
        let result = EdgeAlignment.centered.alignmentEdges(for: topRight, in: screenFrame)
        XCTAssertEqual(result, .none)
    }
}

class NilWindowIdCalculationTests: XCTestCase {
    
    private let visibleFrame = CGRect(x: 10, y: 20, width: 1200, height: 900)
    private let windowRect = CGRect(x: 100, y: 100, width: 600, height: 400)
    
    /// The window id is bookkeeping only (#640); geometry must not depend on it.
    func testRectCalculationsMatchWithAndWithoutWindowId() {
        for action in WindowAction.active {
            guard let calculation = WindowCalculationFactory.calculationsByAction[action] else { continue }
            
            let withId = calculation.calculateRect(params(windowId: 1, action: action)).rect
            let withoutId = calculation.calculateRect(params(windowId: nil, action: action)).rect
            
            XCTAssertEqual(withId, withoutId, "\(action.name) geometry should not depend on window id")
        }
    }
    
    private func params(windowId: CGWindowID?, action: WindowAction) -> RectCalculationParameters {
        RectCalculationParameters(window: Window(id: windowId, rect: windowRect),
                                  visibleFrameOfScreen: visibleFrame,
                                  action: action,
                                  lastAction: nil)
    }
}

class DerivedWindowIdTests: XCTestCase {

    func testPublicWindowInfoMatchUsesPidAndFrame() {
        let targetFrame = CGRect(x: 10, y: 20, width: 640, height: 480)
        let windowInfo = [
            WindowInfo(id: 11, level: 0, frame: targetFrame, pid: 100, processName: "Wrong Process"),
            WindowInfo(id: 12, level: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), pid: 200, processName: "Wrong Frame"),
            WindowInfo(id: 13, level: 0, frame: targetFrame, pid: 200, processName: "Target")
        ]

        XCTAssertEqual(AccessibilityElement.matchingWindowId(pid: 200, frame: targetFrame, windowInfo: windowInfo), 13)
        XCTAssertNil(AccessibilityElement.matchingWindowId(pid: 300, frame: targetFrame, windowInfo: windowInfo))
    }
    
    func testDerivedIdHasHighBitSet() {
        XCTAssertEqual(AccessibilityElement.deriveWindowId(fromElementHash: 0) & 0x8000_0000, 0x8000_0000)
        XCTAssertEqual(AccessibilityElement.deriveWindowId(fromElementHash: CFHashCode.max) & 0x8000_0000, 0x8000_0000)
    }
    
    func testDerivedIdIsDeterministic() {
        XCTAssertEqual(AccessibilityElement.deriveWindowId(fromElementHash: 1668292462),
                       AccessibilityElement.deriveWindowId(fromElementHash: 1668292462))
    }
    
    func testDistinctHashesGiveDistinctIds() {
        let ids: [CGWindowID] = [1668318964, 1668318948, 1668321588].map { AccessibilityElement.deriveWindowId(fromElementHash: CFHashCode($0)) }
        XCTAssertEqual(Set(ids).count, ids.count)
    }
}

// Portrait eighth snapping tiles the screen into four rows. On a display whose
// visible-frame height is not divisible by 4, the row origins must be expressed
// as cell-height multiples (floor(height / 4)) so adjacent rows abut exactly
// instead of drifting apart by the raw height fraction's sub-pixel remainder.
class PortraitEighthAbutmentTests: XCTestCase {

    // Portrait frame whose height is NOT divisible by 4 (1002 % 4 == 2): the case
    // that used to leave 1-2px gaps between rows.
    private static let nonDivisibleFrame = CGRect(x: 0, y: 0, width: 800, height: 1002)
    // Portrait frame whose height IS divisible by 4: rows already tile seamlessly.
    private static let divisibleFrame = CGRect(x: 0, y: 0, width: 800, height: 1000)

    private func portraitEighths(_ frame: CGRect) -> [CGRect] {
        return [
            TopLeftEighthCalculation().portraitRect(frame).rect,
            TopCenterLeftEighthCalculation().portraitRect(frame).rect,
            TopCenterRightEighthCalculation().portraitRect(frame).rect,
            TopRightEighthCalculation().portraitRect(frame).rect,
            BottomLeftEighthCalculation().portraitRect(frame).rect,
            BottomCenterLeftEighthCalculation().portraitRect(frame).rect,
            BottomCenterRightEighthCalculation().portraitRect(frame).rect,
            BottomRightEighthCalculation().portraitRect(frame).rect,
        ]
    }

    private func rowOrigins(_ frame: CGRect) -> [CGFloat] {
        return Set(portraitEighths(frame).map { $0.origin.y }).sorted(by: >)
    }

    func testAllPortraitEighthsAreOneCellTall() {
        let cellHeight = floor(Self.nonDivisibleFrame.height / 4.0)
        for rect in portraitEighths(Self.nonDivisibleFrame) {
            XCTAssertEqual(rect.height, cellHeight, accuracy: 0.001)
        }
    }

    func testPortraitEighthRowsAlignToCellHeightGridOnNonDivisibleHeight() {
        let frame = Self.nonDivisibleFrame
        let cellHeight = floor(frame.height / 4.0)
        let origins = rowOrigins(frame)

        XCTAssertEqual(origins.count, 4)
        XCTAssertEqual(origins[0], frame.maxY - cellHeight, accuracy: 0.001)
        XCTAssertEqual(origins[1], frame.maxY - cellHeight * 2.0, accuracy: 0.001)
        XCTAssertEqual(origins[2], frame.maxY - cellHeight * 3.0, accuracy: 0.001)
        XCTAssertEqual(origins[3], frame.minY, accuracy: 0.001)
    }

    func testPortraitEighthRowsAbutExactlyOnNonDivisibleHeight() {
        // Before the fix, rows 2 and 3 used raw height fractions (height / 2 and
        // height * 0.75), so rows 1-2 and 2-3 each drifted ~1px apart. The top
        // three rows must abut exactly now: each row's minY equals the row
        // above's maxY. (The height % 4 residual sits at the row3-row4 boundary
        // and is zero only when height is divisible by 4 — see the divisible test.)
        let frame = Self.nonDivisibleFrame
        let cellHeight = floor(frame.height / 4.0)
        let origins = rowOrigins(frame)

        XCTAssertEqual(origins[0], origins[1] + cellHeight, accuracy: 0.001)
        XCTAssertEqual(origins[1], origins[2] + cellHeight, accuracy: 0.001)
    }

    func testPortraitEighthRowsTileFullyWhenHeightDivisibleByFour() {
        // When height % 4 == 0 the rounding residual is zero, so every row boundary
        // abuts. Guards against regressing the already-seamless divisible case.
        let frame = Self.divisibleFrame
        let cellHeight = frame.height / 4.0
        let origins = rowOrigins(frame)

        XCTAssertEqual(origins[0], origins[1] + cellHeight, accuracy: 0.001)
        XCTAssertEqual(origins[1], origins[2] + cellHeight, accuracy: 0.001)
        XCTAssertEqual(origins[2], origins[3] + cellHeight, accuracy: 0.001)
    }
}
      
final class CrossDisplayResizeTests: XCTestCase {
    func testDisplayCycleRetriesWidthUntilWindowFillsRightHalf() {
        let settings: [(Default, CodableDefault)] = [
            (Defaults.subsequentExecutionMode, CodableDefault(int: SubsequentExecutionMode.cycleMonitor.rawValue)),
            (Defaults.cooperativeCornerResize, CodableDefault(bool: false)),
            (Defaults.horizontalSplitRatio, CodableDefault(float: 50)),
            (Defaults.moveFixedSizeToEdge, CodableDefault(int: EdgeAlignment.edgesAndCorners.rawValue)),
            (Defaults.gapSize, CodableDefault(float: 0)),
            (Defaults.screenEdgeGapLeft, CodableDefault(float: 0)),
            (Defaults.screenEdgeGapRight, CodableDefault(float: 0)),
            (Defaults.screenEdgeGapTop, CodableDefault(float: 0)),
            (Defaults.screenEdgeGapBottom, CodableDefault(float: 0)),
            (Defaults.combinedDisplayMode, CodableDefault(int: 2))
        ]
        let savedDefaults = settings.map { ($0.0, $0.0.toCodable()) }
        defer {
            savedDefaults.forEach { $0.0.load(from: $0.1) }
            ActiveSideSplitRatios.shared.resetAll()
        }
        settings.forEach { $0.0.load(from: $0.1) }

        let laptop = TestScreen(frame: CGRect(x: 0, y: 0, width: 2056, height: 1329))
        let monitor = TestScreen(frame: CGRect(x: -702, y: 1329, width: 3440, height: 1440))
        let target = CGRect(x: 1018, y: 1329, width: 1720, height: 1440).screenFlipped
        let window = ClampingWindow(target: target)
        let manager = TestWindowManager(screenDetection: TestScreenDetection(source: laptop))
        let finished = expectation(description: "Display-cycle resize completed")
        var completedFrames: [CGRect] = []
        manager.didFinish = { result, frame in
            XCTAssertTrue(result.usableScreens.currentScreen === laptop)
            completedFrames.append(frame)
            finished.fulfill()
        }

        // Repeated shortcuts pass the destination explicitly. Simulate macOS accepting
        // the height but clamping the width on the initial move and immediate retry.
        manager.execute(ExecutionParameters(.rightHalf, screen: monitor, windowElement: window))

        XCTAssertEqual(window.resizeAttempts, 2)
        XCTAssertEqual(window.frame.maxX, target.maxX)
        XCTAssertEqual(window.frame.minX, target.minX + 400)
        XCTAssertTrue(completedFrames.isEmpty)

        wait(for: [finished], timeout: 1)
        XCTAssertEqual(window.resizeAttempts, 3)
        XCTAssertEqual(window.frame, target)
        XCTAssertEqual(completedFrames, [target])
    }

    private final class TestScreen: NSScreen {
        private let testFrame: CGRect

        init(frame: CGRect) {
            testFrame = frame
            super.init()
        }

        override var frame: NSRect { testFrame }
        override var visibleFrame: NSRect { testFrame }
        override var safeAreaInsets: NSEdgeInsets { NSEdgeInsetsZero }
        override var hash: Int { ObjectIdentifier(self).hashValue }

        // AppKit's equality implementation requires a real display ID.
        override func isEqual(_ object: Any?) -> Bool {
            (object as AnyObject?) === self
        }
    }

    private final class TestScreenDetection: ScreenDetection {
        let source: NSScreen

        init(source: NSScreen) {
            self.source = source
        }

        override func detectScreens(using frontmostWindowElement: AccessibilityElement?) -> UsableScreens? {
            UsableScreens(currentScreen: source, numScreens: 2)
        }
    }

    private final class ClampingWindow: AccessibilityElement {
        private var currentFrame = CGRect(x: 1028, y: 0, width: 1028, height: 645).screenFlipped
        private let target: CGRect
        private(set) var resizeAttempts = 0

        init(target: CGRect) {
            self.target = target
            super.init(AXUIElementCreateSystemWide())
        }

        override var frame: CGRect { currentFrame }
        override var isSheet: Bool? { false }
        override var isSystemDialog: Bool? { false }
        override var minimumSize: CGSize? { nil }
        override func getWindowId() -> CGWindowID? { nil }
        override func isResizable() -> Bool { true }

        override func setFrame(_ frame: CGRect, adjustSizeFirst: Bool = true) {
            currentFrame = frame
            if frame.size == target.size {
                resizeAttempts += 1
                if resizeAttempts <= 2 {
                    currentFrame.size.width -= 400
                }
            }
        }
    }

    private final class TestWindowManager: WindowManager {
        var didFinish: ((ResultParameters, CGRect) -> Void)?

        override func windowMovedAcrossDisplays(windowElement: AccessibilityElement, resultingRect: CGRect) {}

        override func postProcess(result: ResultParameters, resultingRect: CGRect) {
            didFinish?(result, resultingRect)
        }
    }
}

final class NextPrevDisplayMappingTests: XCTestCase {
    // The opt-in is NOT needed to test the pure helper; setUp/tearDown still save & restore it
    // so the wiring tests below are isolated from host state.
    private var savedOptIn: Bool?

    override func setUp() {
        super.setUp()
        savedOptIn = Defaults.attemptMatchOnNextPrevDisplay.enabled
        Defaults.attemptMatchOnNextPrevDisplay.enabled = true
    }

    override func tearDown() {
        Defaults.attemptMatchOnNextPrevDisplay.enabled = savedOptIn
        super.tearDown()
    }

    // --- Helper-level: RED until relativePositionedRect exists, then GREEN ---

    func testRelativePositionedRectMapsRightThirdToRightThird() {
        // Issue #1723 repro geometry: a window pinned to the right third (full height) of a
        // 3000x2000 source must land at the right third of a 1500x1000 destination.
        let source      = CGRect(x: 0,    y: 0,    width: 3000, height: 2000)
        let window      = CGRect(x: 2000, y: 0,    width: 1000, height: 2000)
        let destination = CGRect(x: 0,    y: 0,    width: 1500, height: 1000)

        XCTAssertEqual(
            NextPrevDisplayCalculation.relativePositionedRect(window: window, source: source, destination: destination),
            CGRect(x: 1000, y: 0, width: 500, height: 1000)
        )
    }

    func testRelativePositionedRectPreservesCenteredQuarter() {
        // A centered-quarter window stays a centered quarter after the cross-display map.
        let source      = CGRect(x: 0,   y: 0,   width: 2560, height: 1440)
        let window      = CGRect(x: 960, y: 360, width: 640,  height: 720)   // centered quarter
        let destination = CGRect(x: 0,   y: 0,   width: 1280, height: 720)

        XCTAssertEqual(
            NextPrevDisplayCalculation.relativePositionedRect(window: window, source: source, destination: destination),
            CGRect(x: 480, y: 180, width: 320, height: 360)
        )
    }

    func testRelativePositionedRectClampsOverflowIntoDestination() {
        // Window occupies 60% width starting at the 50% mark on a 1000x1000 source.
        // Mapped onto a 500x500 destination: width 300 @ x 250 -> maxX 550 > 500 -> clamp to x 200.
        let source      = CGRect(x: 0,   y: 0, width: 1000, height: 1000)
        let window      = CGRect(x: 500, y: 0, width: 600,  height: 1000)
        let destination = CGRect(x: 0,   y: 0, width: 500,  height: 500)

        XCTAssertEqual(
            NextPrevDisplayCalculation.relativePositionedRect(window: window, source: source, destination: destination),
            CGRect(x: 200, y: 0, width: 300, height: 500)
        )
    }

    func testRelativePositionedRectIsIdentityWhenSourceEqualsDestination() {
        let frame = CGRect(x: 0,   y: 0,   width: 2000, height: 1000)
        let window = CGRect(x: 300, y: 200, width: 500, height: 600)

        XCTAssertEqual(
            NextPrevDisplayCalculation.relativePositionedRect(window: window, source: frame, destination: frame),
            window
        )
    }
}

class HalvesPreserveOtherAxisSizeTests: XCTestCase {

    private var savedHalvesPreserveOtherAxisSize = false
    private var savedGapSize: Float = 0
    private var savedSkipGapTopEdge = false
    private var savedHorizontalSplitRatio: Float = 50
    private var savedVerticalSplitRatio: Float = 50
    private var savedSubsequentExecutionMode: SubsequentExecutionMode = .resize
    private var savedCycleSizesIsChanged = false
    private var savedCooperativeCornerResize = false

    private let visibleFrame = CGRect(x: 10, y: 20, width: 1200, height: 900)
    // Ungapped rects that the half and quarter actions produce on `visibleFrame` at the default 50% split.
    private let leftHalf = CGRect(x: 10, y: 20, width: 600, height: 900)
    private let rightHalf = CGRect(x: 610, y: 20, width: 600, height: 900)
    private let topHalf = CGRect(x: 10, y: 470, width: 1200, height: 450)
    private let bottomHalf = CGRect(x: 10, y: 20, width: 1200, height: 450)
    private let topLeftQuarter = CGRect(x: 10, y: 470, width: 600, height: 450)
    private let topRightQuarter = CGRect(x: 610, y: 470, width: 600, height: 450)
    private let bottomLeftQuarter = CGRect(x: 10, y: 20, width: 600, height: 450)
    private let bottomRightQuarter = CGRect(x: 610, y: 20, width: 600, height: 450)

    override func setUp() {
        super.setUp()
        savedHalvesPreserveOtherAxisSize = Defaults.halvesPreserveOtherAxisSize.enabled
        savedGapSize = Defaults.gapSize.value
        savedSkipGapTopEdge = Defaults.skipGapTopEdge.enabled
        savedHorizontalSplitRatio = Defaults.horizontalSplitRatio.value
        savedVerticalSplitRatio = Defaults.verticalSplitRatio.value
        savedSubsequentExecutionMode = Defaults.subsequentExecutionMode.value
        savedCycleSizesIsChanged = Defaults.cycleSizesIsChanged.enabled
        savedCooperativeCornerResize = Defaults.cooperativeCornerResize.enabled
        Defaults.halvesPreserveOtherAxisSize.enabled = true
        Defaults.gapSize.value = 0
        Defaults.skipGapTopEdge.enabled = false
        Defaults.horizontalSplitRatio.value = 50
        Defaults.verticalSplitRatio.value = 50
        Defaults.subsequentExecutionMode.value = .resize
        Defaults.cycleSizesIsChanged.enabled = false
        Defaults.cooperativeCornerResize.enabled = false
        ActiveSideSplitRatios.shared.resetAll()
    }

    override func tearDown() {
        Defaults.halvesPreserveOtherAxisSize.enabled = savedHalvesPreserveOtherAxisSize
        Defaults.gapSize.value = savedGapSize
        Defaults.skipGapTopEdge.enabled = savedSkipGapTopEdge
        Defaults.horizontalSplitRatio.value = savedHorizontalSplitRatio
        Defaults.verticalSplitRatio.value = savedVerticalSplitRatio
        Defaults.subsequentExecutionMode.value = savedSubsequentExecutionMode
        Defaults.cycleSizesIsChanged.enabled = savedCycleSizesIsChanged
        Defaults.cooperativeCornerResize.enabled = savedCooperativeCornerResize
        ActiveSideSplitRatios.shared.resetAll()
        super.tearDown()
    }

    // MARK: A half action keeps the other axis: Left + Top = top left quarter, in either order

    func testTopHalfKeepsLeftHalfColumn() {
        assertTiled(.topHalf, from: leftHalf, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testLeftHalfKeepsTopHalfRow() {
        assertTiled(.leftHalf, from: topHalf, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testBottomHalfKeepsRightHalfColumn() {
        assertTiled(.bottomHalf, from: rightHalf, gives: bottomRightQuarter, as: .bottomRight, subAction: .bottomRightQuarter)
    }

    func testRightHalfKeepsBottomHalfRow() {
        assertTiled(.rightHalf, from: bottomHalf, gives: bottomRightQuarter, as: .bottomRight, subAction: .bottomRightQuarter)
    }

    func testTopHalfKeepsRightHalfColumn() {
        assertTiled(.topHalf, from: rightHalf, gives: topRightQuarter, as: .topRight, subAction: .topRightQuarter)
    }

    func testBottomHalfKeepsLeftHalfColumn() {
        assertTiled(.bottomHalf, from: leftHalf, gives: bottomLeftQuarter, as: .bottomLeft, subAction: .bottomLeftQuarter)
    }

    // MARK: The action for the opposite edge expands the window along that axis

    func testBottomHalfExpandsTopLeftQuarterToLeftHalf() {
        assertTiled(.bottomHalf, from: topLeftQuarter, gives: leftHalf, as: .leftHalf)
    }

    func testTopHalfExpandsBottomLeftQuarterToLeftHalf() {
        assertTiled(.topHalf, from: bottomLeftQuarter, gives: leftHalf, as: .leftHalf)
    }

    func testRightHalfExpandsTopLeftQuarterToTopHalf() {
        assertTiled(.rightHalf, from: topLeftQuarter, gives: topHalf, as: .topHalf)
    }

    func testLeftHalfExpandsBottomRightQuarterToBottomHalf() {
        assertTiled(.leftHalf, from: bottomRightQuarter, gives: bottomHalf, as: .bottomHalf)
    }

    func testLeftHalfExpandsRightHalfToFullScreen() {
        assertTiled(.leftHalf, from: rightHalf, gives: visibleFrame, as: .maximize)
    }

    func testTopHalfExpandsBottomHalfToFullScreen() {
        assertTiled(.topHalf, from: bottomHalf, gives: visibleFrame, as: .maximize)
    }

    // MARK: The action for the edge a quarter is docked to cycles sizes along its own axis

    func testLeftHalfCyclesWidthOfTopLeftQuarter() {
        let twoThirdsWide = CGRect(x: 10, y: 470, width: 800, height: 450)
        let oneThirdWide = CGRect(x: 10, y: 470, width: 400, height: 450)

        assertTiled(.leftHalf, from: topLeftQuarter, gives: twoThirdsWide, as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.leftHalf, from: twoThirdsWide, gives: oneThirdWide, as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.leftHalf, from: oneThirdWide, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testRightHalfCyclesWidthOfBottomRightQuarterFromItsEdge() {
        assertTiled(.rightHalf, from: bottomRightQuarter,
                    gives: CGRect(x: 410, y: 20, width: 800, height: 450), as: .bottomRight, subAction: .bottomRightQuarter)
    }

    func testTopHalfCyclesHeightOfTopLeftQuarter() {
        let twoThirdsHigh = CGRect(x: 10, y: 320, width: 600, height: 600)
        let oneThirdHigh = CGRect(x: 10, y: 620, width: 600, height: 300)

        assertTiled(.topHalf, from: topLeftQuarter, gives: twoThirdsHigh, as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.topHalf, from: twoThirdsHigh, gives: oneThirdHigh, as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.topHalf, from: oneThirdHigh, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testBottomHalfCyclesHeightOfBottomRightQuarterFromItsEdge() {
        assertTiled(.bottomHalf, from: bottomRightQuarter,
                    gives: CGRect(x: 610, y: 20, width: 600, height: 600), as: .bottomRight, subAction: .bottomRightQuarter)
    }

    func testCyclingInsideQuarterUsesSelectedCycleSizes() {
        let savedSelectedCycleSizes = Defaults.selectedCycleSizes.value
        defer { Defaults.selectedCycleSizes.value = savedSelectedCycleSizes }
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = [.twoThirds, .oneQuarter]

        let twoThirdsWide = CGRect(x: 10, y: 470, width: 800, height: 450)
        let oneQuarterWide = CGRect(x: 10, y: 470, width: 300, height: 450)

        // One half is not selected: the cycle starts at the first selected size and never returns to one half.
        assertTiled(.leftHalf, from: topLeftQuarter, gives: twoThirdsWide, as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.leftHalf, from: twoThirdsWide, gives: oneQuarterWide, as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.leftHalf, from: oneQuarterWide, gives: twoThirdsWide, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testCyclingInsideQuarterStartsOverFromCustomSplitRatio() {
        Defaults.horizontalSplitRatio.value = 60
        let sixtyPercentWide = CGRect(x: 10, y: 470, width: 720, height: 450)

        assertTiled(.leftHalf, from: sixtyPercentWide, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testCyclingInsideQuarterRecognizesGappedWindow() {
        Defaults.gapSize.value = 20
        let gappedTopLeftQuarter = GapCalculation.applyGaps(topLeftQuarter, dimension: .both, sharedEdges: [.right, .bottom], gapSize: 20, skipTopGap: false)

        assertTiled(.leftHalf, from: gappedTopLeftQuarter,
                    gives: CGRect(x: 10, y: 470, width: 800, height: 450), as: .topLeft, subAction: .topLeftQuarter)
    }

    func testQuarterStaysPutWhenRepeatedCommandsDoNotResize() {
        for mode in [SubsequentExecutionMode.none, .acrossMonitor, .cycleMonitor] {
            Defaults.subsequentExecutionMode.value = mode
            assertTiled(.leftHalf, from: topLeftQuarter, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
            assertTiled(.topHalf, from: topLeftQuarter, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
        }
    }

    func testQuarterStaysPutWhenNoCycleSizesAreSelected() {
        let savedSelectedCycleSizes = Defaults.selectedCycleSizes.value
        defer { Defaults.selectedCycleSizes.value = savedSelectedCycleSizes }
        Defaults.cycleSizesIsChanged.enabled = true
        Defaults.selectedCycleSizes.value = []

        assertTiled(.leftHalf, from: topLeftQuarter, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testRepeatedTopHalfInsideQuarterCyclesHeightWithoutHistory() {
        let params = params(for: .topHalf, windowRect: topLeftQuarter,
                            lastAction: RectangleAction(action: .topLeft, subAction: .topLeftQuarter, rect: topLeftQuarter, count: 5))

        let result = WindowCalculationFactory.topHalfCalculation.calculateRect(params)

        XCTAssertEqual(result.rect, CGRect(x: 10, y: 320, width: 600, height: 600))
        XCTAssertEqual(result.resultingAction, .topLeft)
        XCTAssertEqual(result.subAction, .topLeftQuarter)
    }

    // MARK: Plain halves and windows that are not tiled behave as without the feature

    func testPlainHalvesRepeatAsUsual() {
        XCTAssertNil(tiled(.leftHalf, from: leftHalf))
        XCTAssertNil(tiled(.rightHalf, from: rightHalf))
        XCTAssertNil(tiled(.topHalf, from: topHalf))
        XCTAssertNil(tiled(.bottomHalf, from: bottomHalf))
    }

    func testRepeatedPlainTopHalfStillCyclesHeight() {
        let params = params(for: .topHalf, windowRect: topHalf,
                            lastAction: RectangleAction(action: .topHalf, subAction: nil, rect: topHalf, count: 1))

        let result = WindowCalculationFactory.topHalfCalculation.calculateRect(params)

        XCTAssertEqual(result.rect, CGRect(x: 10, y: 320, width: 1200, height: 600))
    }

    func testUntiledWindowsAreNotAffected() {
        let floating = CGRect(x: 300, y: 100, width: 700, height: 500)
        let centeredColumn = CGRect(x: 310, y: 20, width: 600, height: 900)

        for action in [WindowAction.leftHalf, .rightHalf, .topHalf, .bottomHalf] {
            XCTAssertNil(tiled(action, from: floating), "\(action)")
            XCTAssertNil(tiled(action, from: visibleFrame), "\(action)")
        }
        XCTAssertNil(tiled(.topHalf, from: centeredColumn))
    }

    func testTopHalfCalculationFallsBackToDefaultBehaviorForUntiledWindows() {
        let result = WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf, windowRect: CGRect(x: 300, y: 100, width: 700, height: 500)))

        XCTAssertEqual(result.rect, topHalf)
        XCTAssertNil(result.resultingAction)
        XCTAssertNil(result.subAction)
    }

    func testTopHalfCalculationTilesWhenEnabled() {
        let result = WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf, windowRect: leftHalf))

        XCTAssertEqual(result.rect, topLeftQuarter)
        XCTAssertEqual(result.resultingAction, .topLeft)
        XCTAssertEqual(result.subAction, .topLeftQuarter)
    }

    func testBottomHalfCalculationTilesWhenEnabled() {
        let result = WindowCalculationFactory.bottomHalfCalculation.calculateRect(params(for: .bottomHalf, windowRect: topLeftQuarter))

        XCTAssertEqual(result.rect, leftHalf)
        XCTAssertEqual(result.resultingAction, .leftHalf)
    }

    func testDisabledFeatureKeepsFullWidthTopHalf() {
        Defaults.halvesPreserveOtherAxisSize.enabled = false

        let result = WindowCalculationFactory.topHalfCalculation.calculateRect(params(for: .topHalf, windowRect: leftHalf))

        XCTAssertEqual(result.rect, topHalf)
        XCTAssertNil(result.resultingAction)
        XCTAssertNil(result.subAction)
    }

    // MARK: Columns and rows other than exactly one half

    func testTopHalfKeepsCycledTwoThirdsColumn() {
        assertTiled(.topHalf, from: CGRect(x: 10, y: 20, width: 800, height: 900),
                    gives: CGRect(x: 10, y: 470, width: 800, height: 450), as: .topLeft, subAction: .topLeftQuarter)
    }

    func testBottomHalfExpandsTwoThirdsWideTopLeftQuarterToTwoThirdsColumn() {
        assertTiled(.bottomHalf, from: CGRect(x: 10, y: 470, width: 800, height: 450),
                    gives: CGRect(x: 10, y: 20, width: 800, height: 900), as: .leftHalf)
    }

    func testLeftHalfKeepsCycledTopThirdRow() {
        assertTiled(.leftHalf, from: CGRect(x: 10, y: 620, width: 1200, height: 300),
                    gives: CGRect(x: 10, y: 620, width: 600, height: 300), as: .topLeft, subAction: .topLeftQuarter)
    }

    func testTopHalfKeepsRightThirdColumn() {
        assertTiled(.topHalf, from: CGRect(x: 810, y: 20, width: 400, height: 900),
                    gives: CGRect(x: 810, y: 470, width: 400, height: 450), as: .topRight, subAction: .topRightQuarter)
    }

    func testCustomSplitRatioIsUsedForRecognitionAndResults() {
        Defaults.horizontalSplitRatio.value = 60

        assertTiled(.topHalf, from: CGRect(x: 10, y: 20, width: 720, height: 900),
                    gives: CGRect(x: 10, y: 470, width: 720, height: 450), as: .topLeft, subAction: .topLeftQuarter)
        assertTiled(.topHalf, from: CGRect(x: 730, y: 20, width: 480, height: 900),
                    gives: CGRect(x: 730, y: 470, width: 480, height: 450), as: .topRight, subAction: .topRightQuarter)
        assertTiled(.leftHalf, from: topHalf,
                    gives: CGRect(x: 10, y: 470, width: 720, height: 450), as: .topLeft, subAction: .topLeftQuarter)
    }

    // MARK: Gaps and tolerance

    func testRecognizesGappedColumnAndReturnsUngappedRect() {
        Defaults.gapSize.value = 20
        // Left half with gaps applied by WindowManager: inset 20 on each side, half a gap back on the shared right edge.
        let gappedLeftHalf = CGRect(x: 30, y: 40, width: 570, height: 860)

        assertTiled(.topHalf, from: gappedLeftHalf, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testRecognizesGappedRowWithSkippedTopGap() {
        Defaults.gapSize.value = 20
        Defaults.skipGapTopEdge.enabled = true
        let gappedTopHalf = GapCalculation.applyGaps(topHalf, dimension: .both, sharedEdges: .bottom, gapSize: 20, skipTopGap: true)

        assertTiled(.leftHalf, from: gappedTopHalf, gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testToleratesWindowsThatCannotTakeTheExactSize() {
        assertTiled(.topHalf, from: CGRect(x: 10, y: 20, width: 594, height: 900),
                    gives: topLeftQuarter, as: .topLeft, subAction: .topLeftQuarter)
    }

    func testDoesNotMatchWindowsFarFromAnyColumn() {
        XCTAssertNil(tiled(.topHalf, from: CGRect(x: 10, y: 20, width: 560, height: 900)))
    }

    // MARK: Helpers

    private func tiled(_ action: WindowAction, from windowRect: CGRect) -> RectResult? {
        HalvesPreserveOtherAxisSize.rect(for: params(for: action, windowRect: windowRect))
    }

    private func assertTiled(_ action: WindowAction,
                             from windowRect: CGRect,
                             gives expectedRect: CGRect,
                             as expectedAction: WindowAction,
                             subAction expectedSubAction: SubWindowAction? = nil,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        guard let result = tiled(action, from: windowRect) else {
            XCTFail("\(action) from \(windowRect) fell back to the default behavior", file: file, line: line)
            return
        }
        XCTAssertEqual(result.rect, expectedRect, file: file, line: line)
        XCTAssertEqual(result.resultingAction, expectedAction, file: file, line: line)
        XCTAssertEqual(result.subAction, expectedSubAction, file: file, line: line)
    }

    private func params(for action: WindowAction, windowRect: CGRect, lastAction: RectangleAction? = nil) -> RectCalculationParameters {
        RectCalculationParameters(window: Window(id: 1, rect: windowRect),
                                  visibleFrameOfScreen: visibleFrame,
                                  action: action,
                                  lastAction: lastAction)
    }
}
