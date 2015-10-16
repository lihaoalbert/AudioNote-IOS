//
//  AudioNoteTests.m
//  AudioNoteTests
//
//  Created by lijunjie on 14-12-6.
//  Copyright (c) 2014年 Intfocus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "Version+Pgyer.h"

@interface AudioNoteTests : XCTestCase

@end

@implementation AudioNoteTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssertNotNil(@1);
    
    [[[Version alloc] init] checkUpdate:^{
        NSLog(@"upgrade!");
    }FailBloc:^{
        NSLog(@"no upgrade!");
    }];
            
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
}

@end
