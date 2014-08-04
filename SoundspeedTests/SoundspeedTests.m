//
//  SoundspeedTests.m
//  SoundspeedTests
//
//  Created by Clay Jones on 7/30/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import <XCTest/XCTest.h>


@interface SoundspeedTests : XCTestCase

@end

@implementation SoundspeedTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testTimeFormat {
  XCTAssertEqualObjects([SSHelper timeFormat:20], @"00:20", @"should be this format");
  XCTAssertEqualObjects([SSHelper timeFormat:120], @"02:00", @"should be this format");
  XCTAssertEqualObjects([SSHelper timeFormat:121], @"02:01", @"should be this format");
  XCTAssertEqualObjects([SSHelper timeFormat:3600], @"1:00:00", @"should be this format");
  XCTAssertEqualObjects([SSHelper timeFormat:3601], @"1:00:01", @"should be this format");
  XCTAssertEqualObjects([SSHelper timeFormat:10861], @"3:01:01", @"should be this format");
}

@end
