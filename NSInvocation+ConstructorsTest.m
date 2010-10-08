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

#import "GTMSenTestCase.h"
#import "NSInvocation+Constructors.h"

@protocol NSInvocation_Constructors_TestProtocol
- (NSString*)requiredMethod;
@optional
- (NSString*)optionalMethod;
@end

@interface NSInvocation_Constructors_TestProtocolImpl : NSObject
- (NSString*)requiredMethod;
- (NSString*)optionalMethod;
@end

@implementation NSInvocation_Constructors_TestProtocolImpl
- (NSString*)requiredMethod {
	return @"requiredMethod";
}
- (NSString*)optionalMethod {
	return @"optionalMethod";
}
@end

@interface NSInvocation_Constructors_TestClass : NSObject
- (NSString*)classMethod;
@end

@implementation NSInvocation_Constructors_TestClass
- (NSString*)classMethod {
	return @"classMethod";
}
@end



@interface NSInvocation_ConstructorsTest : GTMTestCase
@end


@implementation NSInvocation_ConstructorsTest

- (void)testTargetSelectorContstructor {
	NSInvocation_Constructors_TestClass* object = [[[NSInvocation_Constructors_TestClass alloc] init] autorelease];
	NSInvocation* inv = [NSInvocation invocationWithTarget:object selector:@selector(classMethod)];
	STAssertNotNil(inv, nil);
	
	[inv invoke];
	
	NSString* string;
	[inv getReturnValue:&string];
	
	STAssertEqualStrings(string, @"classMethod", nil);
}

- (void)testClassSelectorConstructor {
	NSInvocation* inv = [NSInvocation invocationWithClass:[NSInvocation_Constructors_TestClass class] selector:@selector(classMethod)];
	STAssertNotNil(inv, nil);
	
	NSInvocation_Constructors_TestClass* impl = [[[NSInvocation_Constructors_TestClass alloc] init] autorelease];
	[inv setTarget:impl];
	[inv invoke];
	
	NSString* string;
	[inv getReturnValue:&string];
	
	STAssertEqualStrings(string, @"classMethod", nil);
}

- (void)testInvalidClassSelectorConstructor {
	NSInvocation* inv = [NSInvocation invocationWithClass:[NSInvocation_Constructors_TestClass class] selector:@selector(requiredMethod)];
	STAssertNil(inv, nil);
}

- (void)testProtocolSelectorConstructorWithRequiredMethod {
	NSInvocation* inv = [NSInvocation invocationWithProtocol:@protocol(NSInvocation_Constructors_TestProtocol) selector:@selector(requiredMethod)];
	STAssertNotNil(inv, nil);
	
	NSInvocation_Constructors_TestProtocolImpl* impl = [[[NSInvocation_Constructors_TestProtocolImpl alloc] init] autorelease];
	[inv setTarget:impl];
	[inv invoke];
	
	NSString* string;
	[inv getReturnValue:&string];
	
	STAssertEqualStrings(string, @"requiredMethod", nil);
}

- (void)testProtocolSelectorConstructorWithOptionalMethod {
	NSInvocation* inv = [NSInvocation invocationWithProtocol:@protocol(NSInvocation_Constructors_TestProtocol) selector:@selector(optionalMethod)];
	STAssertNotNil(inv, nil);
	
	NSInvocation_Constructors_TestProtocolImpl* imp = [[[NSInvocation_Constructors_TestProtocolImpl alloc] init] autorelease];
	[inv setTarget:imp];
	[inv invoke];
	
	NSString* string;
	[inv getReturnValue:&string];
	
	STAssertEqualStrings(string, @"optionalMethod", nil);
}

- (void)testProtocolSelectorConstructorWithInvalidMethod {
	NSInvocation* inv = [NSInvocation invocationWithProtocol:@protocol(NSInvocation_Constructors_TestProtocol) selector:@selector(classMethod)];
	STAssertNil(inv, nil);
}

@end
