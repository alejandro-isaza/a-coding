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

#import "NSInvocation+Constructors.h"
#import "objc/runtime.h"

@implementation NSInvocation (Constructors)

+ (id)invocationWithTarget:(NSObject*)targetObject selector:(SEL)selector {
	NSMethodSignature* sig = [targetObject methodSignatureForSelector:selector];
	NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setTarget:targetObject];
	[inv setSelector:selector];
	return inv;
}

+ (id)invocationWithClass:(Class)targetClass selector:(SEL)selector {
	Method method = class_getInstanceMethod(targetClass, selector);
	struct objc_method_description* desc = method_getDescription(method);
	if (desc == NULL || desc->name == NULL)
		return nil;
	
	NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:desc->types];
	NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setSelector:selector];
	return inv;
}

+ (id)invocationWithProtocol:(Protocol*)targetProtocol selector:(SEL)selector {
	struct objc_method_description desc;
	BOOL required = YES;
	desc = protocol_getMethodDescription(targetProtocol, selector, required, YES);
	if (desc.name == NULL) {
		required = NO;
		desc = protocol_getMethodDescription(targetProtocol, selector, required, YES);
	}
	if (desc.name == NULL)
		return nil;
	
	NSMethodSignature* sig = [NSMethodSignature signatureWithObjCTypes:desc.types];
	NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
	[inv setSelector:selector];
	return inv;
}

@end
