//
//  IJSPhotoSDKProjectUITests.m
//  IJSPhotoSDKProjectUITests
//
//  Created by 山神 on 2018/9/14.
//  Copyright © 2018年 shanshen. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface IJSPhotoSDKProjectUITests : XCTestCase

@end

@implementation IJSPhotoSDKProjectUITests

- (void)setUp {
    [super setUp];
    
    self.continueAfterFailure = NO;

    [[[XCUIApplication alloc] init] launch];

}

- (void)tearDown {
  
    [super tearDown];
}

- (void)testExample {
   
}

- (void)testAddNewItems{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    XCUIElement *window = [[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0];
    XCUIElement *element = [[window childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element;
    [element tap];
    [app.buttons[@"选图"] tap];
    [app.navigationBars[@"Camera Roll"].buttons[@"Back"] tap];
    [app.tables/*@START_MENU_TOKEN@*/.staticTexts[@"Camera Roll"]/*[[".cells.staticTexts[@\"Camera Roll\"]",".staticTexts[@\"Camera Roll\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElementQuery *collectionViewsQuery = app.collectionViews;
    [[[[collectionViewsQuery childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:5].otherElements childrenMatchingType:XCUIElementTypeButton].element tap];
    [[[[collectionViewsQuery childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:4].otherElements childrenMatchingType:XCUIElementTypeButton].element tap];
    [[[[collectionViewsQuery childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:1].otherElements childrenMatchingType:XCUIElementTypeButton].element tap];
    [[collectionViewsQuery.cells.otherElements containingType:XCUIElementTypeButton identifier:@"1"].element tap];
    [app.buttons[@"Edit"] tap];
    
    XCUIElement *element2 = [[[[[[window childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeOther].element;
    [[[element2 childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
    [[[[[[[app.scrollViews childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeImage] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeImage].element swipeDown];
    [[[element2 childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:1] tap];
    [[[collectionViewsQuery.cells containingType:XCUIElementTypeImage identifier:@"/Users/shan/Library/Developer/CoreSimulator/Devices/271826E7-7FAD-46C4-823C-D7D8F5E7EEE9/data/Containers/Bundle/Application/1FF59884-0627-41B2-B68F-2A9EF0E18544/IJSPhotoSDKProject.app/JSPhotoSDK.bundle/Expression/Expression_33@2x.png"] childrenMatchingType:XCUIElementTypeOther].element tap];
    [app.buttons[@"OK"] tap];
    [[[[[[[[[element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeCollectionView] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeOther].element tap];
    [app.buttons[@"Done(3)"] tap];

}
@end
