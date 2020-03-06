//
// Created by RevenueCat on 3/01/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Nimble

import Purchases

class PurchasesSubscriberAttributesTests: XCTestCase {

    override func setUp() {
        self.userDefaults = UserDefaults(suiteName: "TestDefaults")
    }

    override func tearDown() {
        purchases?.delegate = nil
        purchases = nil
        Purchases.setDefaultInstance(nil)
        UserDefaults().removePersistentDomain(forName: "TestDefaults")
    }

    let mockReceiptFetcher = MockReceiptFetcher()
    let mockRequestFetcher = MockRequestFetcher()
    let mockBackend = MockBackend()
    let mockStoreKitWrapper = MockStoreKitWrapper()
    let mockNotificationCenter = MockNotificationCenter()
    var userDefaults: UserDefaults! = nil
    let mockAttributionFetcher = MockAttributionFetcher()
    let mockOfferingsFactory = MockOfferingsFactory()
    let mockDeviceCache = MockDeviceCache()
    let mockIdentityManager = MockUserManager(mockAppUserID: "app_user");
    let mockSubscriberAttributesManager = MockSubscriberAttributesManager()

    let purchasesDelegate = MockPurchasesDelegate()

    var purchases: Purchases!

    func setupPurchases(automaticCollection: Bool = false) {
        Purchases.automaticAppleSearchAdsAttributionCollection = automaticCollection
        self.mockIdentityManager.mockIsAnonymous = false
        purchases = Purchases(appUserID: mockIdentityManager.currentAppUserID,
                              requestFetcher: mockRequestFetcher,
                              receiptFetcher: mockReceiptFetcher,
                              attributionFetcher: mockAttributionFetcher,
                              backend: mockBackend,
                              storeKitWrapper: mockStoreKitWrapper,
                              notificationCenter: mockNotificationCenter,
                              userDefaults: userDefaults,
                              observerMode: false,
                              offeringsFactory: mockOfferingsFactory,
                              deviceCache: mockDeviceCache,
                              identityManager: mockIdentityManager,
                              subscriberAttributesManager: mockSubscriberAttributesManager)
        purchases!.delegate = purchasesDelegate
        Purchases.setDefaultInstance(purchases!)
    }

    func testInitializerConfiguresSubscriberAttributesManager() {
        let purchases = Purchases.configure(withAPIKey: "key")
        expect(purchases.subscriberAttributesManager).toNot(beNil())
    }

    func testSubscribesToForegroundNotifications() {
        setupPurchases()

        expect(self.mockNotificationCenter.observers.count) > 0

        var isObservingDidBecomeActive = false

        for (_, _, name, _) in self.mockNotificationCenter.observers {
            if name == UIApplication.didBecomeActiveNotification {
                isObservingDidBecomeActive = true
                break
            }
        }
        expect(isObservingDidBecomeActive) == true

        self.mockNotificationCenter.fireNotifications()
        expect(self.mockSubscriberAttributesManager.invokedSyncIfNeededCount) == 2
    }

    func testSubscribesToBackgroundNotifications() {
        setupPurchases()

        expect(self.mockNotificationCenter.observers.count) > 0

        var isObservingDidBecomeActive = false

        for (_, _, name, _) in self.mockNotificationCenter.observers {
            if name == UIApplication.willResignActiveNotification {
                isObservingDidBecomeActive = true
                break
            }
        }
        expect(isObservingDidBecomeActive) == true

        self.mockNotificationCenter.fireNotifications()
        expect(self.mockSubscriberAttributesManager.invokedSyncIfNeededCount) == 2
    }

    func testSetAttributesMakesRightCalls() {
        setupPurchases()

        Purchases.shared.setAttributes(["genre": "rock n' roll"])
        expect(self.mockSubscriberAttributesManager.invokedSetAttributesCount) == 1
        expect(self.mockSubscriberAttributesManager.invokedSetAttributesParameters?.attributes) == ["genre": "rock n' roll"]
        expect(self.mockSubscriberAttributesManager.invokedSetAttributesParameters?.appUserID) == mockIdentityManager.currentAppUserID
    }

    func testSetEmailMakesRightCalls() {
        setupPurchases()

        Purchases.shared.setEmail("ac.dc@rock.com")
        expect(self.mockSubscriberAttributesManager.invokedSetEmailCount) == 1
        expect(self.mockSubscriberAttributesManager.invokedSetEmailParameters?.email) == "ac.dc@rock.com"
        expect(self.mockSubscriberAttributesManager.invokedSetEmailParameters?.appUserID) == mockIdentityManager
            .currentAppUserID
    }

    func testSetPhoneNumberMakesRightCalls() {
        setupPurchases()

        Purchases.shared.setPhoneNumber("8561365841")
        expect(self.mockSubscriberAttributesManager.invokedSetPhoneNumberCount) == 1
        expect(self.mockSubscriberAttributesManager.invokedSetPhoneNumberParameters?.phoneNumber) == "8561365841"
        expect(self.mockSubscriberAttributesManager.invokedSetPhoneNumberParameters?.appUserID) == mockIdentityManager
            .currentAppUserID
    }

    func testSetDisplayNameMakesRightCalls() {
        setupPurchases()

        Purchases.shared.setDisplayName("Stevie Ray Vaughan")
        expect(self.mockSubscriberAttributesManager.invokedSetDisplayNameCount) == 1
        expect(self.mockSubscriberAttributesManager.invokedSetDisplayNameParameters?.displayName) == "Stevie Ray Vaughan"
        expect(self.mockSubscriberAttributesManager.invokedSetDisplayNameParameters?.appUserID) == mockIdentityManager
            .currentAppUserID
    }

    func testSetPushTokenMakesRightCalls() {
        setupPurchases()

        Purchases.shared.setPushToken("asdf45asdg35asd5")
        expect(self.mockSubscriberAttributesManager.invokedSetPushTokenCount) == 1
        expect(self.mockSubscriberAttributesManager.invokedSetPushTokenParameters?.pushToken) == "asdf45asdg35asd5"
        expect(self.mockSubscriberAttributesManager.invokedSetPushTokenParameters?.appUserID) == mockIdentityManager
            .currentAppUserID
    }
}