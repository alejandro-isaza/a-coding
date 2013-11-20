//  Copyright 2010 Alejandro Isaza.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.

#import <XCTest/XCTest.h>
#import "Observable.h"
#import "NSInvocation+Constructors.h"


#pragma mark -
#pragma mark ObserverProtocol
@protocol ObservableTest_ObserverProtocol
- (void)notification;
@optional
- (void)notificationWithInt:(int)i;
@end


#pragma mark -
#pragma mark Observable
@interface ObservableTest_Observable : Observable
@end

@implementation ObservableTest_Observable
@end


#pragma mark -
#pragma mark Basic Observer
@interface ObservableTest_Observer : NSObject <ObservableTest_ObserverProtocol> {
	BOOL notified;
}

@property (assign) BOOL notified;

@end

@implementation ObservableTest_Observer
@synthesize notified;
- (void)notification {
	notified = YES;
}
@end


#pragma mark -
#pragma mark Extended Observer
@interface ObservableTest_ExtendedObserver : NSObject <ObservableTest_ObserverProtocol> {
	BOOL notified;
}

@property (assign) BOOL notified;

@end

@implementation ObservableTest_ExtendedObserver
@synthesize notified;
- (void)notification {
	notified = YES;
}
- (void)notificationWithInt:(int)i {
	notified = YES;
}
@end


#pragma mark -
#pragma mark Removing Observer
@interface ObservableTest_RemovingObserver : NSObject <ObservableTest_ObserverProtocol> {
	Observable* observable;
	ObservableTest_Observer* observerToRemove;
	BOOL notified;
	BOOL observerToRemoveWasNotified;
}

@property (assign) Observable* observable;
@property (assign) ObservableTest_Observer* observerToRemove;
@property (assign) BOOL notified;
@property (assign) BOOL observerToRemoveWasNotified;

@end

@implementation ObservableTest_RemovingObserver
@synthesize observable;
@synthesize observerToRemove;
@synthesize notified;
@synthesize observerToRemoveWasNotified;

- (void)notification {
	notified = YES;
	observerToRemoveWasNotified = observerToRemove.notified;
	[observable removeObserver:observerToRemove];
}

@end


#pragma mark -
#pragma mark Adding Observer
@interface ObservableTest_AddingObserver : NSObject <ObservableTest_ObserverProtocol> {
	Observable* observable;
	id<NSObject> observerToAdd;
	BOOL notified;
}

@property (assign) Observable* observable;
@property (assign) id<NSObject> observerToAdd;
@property (assign) BOOL notified;

@end

@implementation ObservableTest_AddingObserver
@synthesize observable;
@synthesize observerToAdd;
@synthesize notified;

- (void)notification {
	notified = YES;
	[observable addObserver:observerToAdd];
}

@end



#pragma mark -
#pragma mark ObservableTest
@interface ObservableTest : XCTestCase
@end

@implementation ObservableTest

- (void)testNotification {
	ObservableTest_Observer* observer = [[[ObservableTest_Observer alloc] init] autorelease];
	ObservableTest_Observable* observable = [[[ObservableTest_Observable alloc] init] autorelease];
	
	[observable addObserver:observer];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
															selector:@selector(notification)]];
	
	XCTAssertTrue(observer.notified, @"");
}

- (void)testOptionalNotification {
	ObservableTest_Observer* observer1 = [[[ObservableTest_Observer alloc] init] autorelease];
	ObservableTest_ExtendedObserver* observer2 = [[[ObservableTest_ExtendedObserver alloc] init] autorelease];
	ObservableTest_Observable* observable = [[[ObservableTest_Observable alloc] init] autorelease];
	
	[observable addObserver:observer1];
	[observable addObserver:observer2];
	
	NSInvocation* inv = [NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
													selector:@selector(notificationWithInt:)];
	int i = 3;
	[inv setArgument:&i atIndex:2];
	[observable notifyObservers:inv];
	
	// 'observer1' does not implement the optional method, so it should not be notified
	XCTAssertFalse(observer1.notified, @"");
	XCTAssertTrue(observer2.notified, @"");
}

- (void)testObserverRemoving {
	ObservableTest_Observer* observer1 = [[[ObservableTest_Observer alloc] init] autorelease];
	ObservableTest_Observer* observer2 = [[[ObservableTest_Observer alloc] init] autorelease];
	ObservableTest_Observable* observable = [[[ObservableTest_Observable alloc] init] autorelease];
	
	[observable addObserver:observer1];
	[observable addObserver:observer2];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
															selector:@selector(notification)]];
	
	// Both observers are notified
	XCTAssertTrue(observer1.notified, @"");
	XCTAssertTrue(observer2.notified, @"");
	
	observer1.notified = NO;
	observer2.notified = NO;
	[observable removeObserver:observer1];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
															selector:@selector(notification)]];
	
	// After removing 'observer2' it is no longer notified
	XCTAssertFalse(observer1.notified, @"");
	XCTAssertTrue(observer2.notified, @"");
}

- (void)testLiveRemoval {
	ObservableTest_Observer* observer = [[[ObservableTest_Observer alloc] init] autorelease];
	ObservableTest_RemovingObserver* removingObserver = [[[ObservableTest_RemovingObserver alloc] init] autorelease];
	ObservableTest_Observable* observable = [[[ObservableTest_Observable alloc] init] autorelease];
	
	// when it gets a notification 'removingObserver' will remove 'observer' from the notification list
	removingObserver.observable = observable;
	removingObserver.observerToRemove = observer;
	
	[observable addObserver:removingObserver];
	[observable addObserver:observer];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
															selector:@selector(notification)]];
	
	// The order of the notifications cannot be guaranteed, but either the observer was notified before it was removed
	// or it was not notified at all.
	XCTAssertTrue(removingObserver.observerToRemoveWasNotified || !observer.notified, @"");
	XCTAssertTrue(removingObserver.notified, @"");
}

- (void)testLiveAddition {
	ObservableTest_Observer* observer = [[[ObservableTest_Observer alloc] init] autorelease];
	ObservableTest_AddingObserver* addingObserver = [[[ObservableTest_AddingObserver alloc] init] autorelease];
	ObservableTest_Observable* observable = [[[ObservableTest_Observable alloc] init] autorelease];
	
	// when it gets a notification 'addingObserver' will add 'observer' to the notification list
	addingObserver.observable = observable;
	addingObserver.observerToAdd = observer;
	
	[observable addObserver:addingObserver];
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
															selector:@selector(notification)]];
	
	// 'observer' is not notified on the first run, it was just added
	XCTAssertFalse(observer.notified, @"");
	XCTAssertTrue(addingObserver.notified, @"");
	
	addingObserver.notified = NO;
	[observable notifyObservers:[NSInvocation invocationWithProtocol:@protocol(ObservableTest_ObserverProtocol)
															selector:@selector(notification)]];
	
	// But it's notified on the second run
	XCTAssertTrue(observer.notified, @"");
	XCTAssertTrue(addingObserver.notified, @"");
}

@end
