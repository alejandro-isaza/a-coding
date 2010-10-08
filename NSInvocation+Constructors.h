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

#import <Foundation/Foundation.h>


@interface NSInvocation (Constructors)

// Returns an initialized invocation from a target and a selector.
+ (id)invocationWithTarget:(NSObject*)targetObject selector:(SEL)selector;

// Returns an invocation from a class and a selector. The selector property of the
// invocation is initialized but you still need to set the target before invoking it.
+ (id)invocationWithClass:(Class)targetClass selector:(SEL)selector;

// Returns an invocation from a protocol and a selector. The selector property of the
// invocation is initialized but you still need to set the target before invoking it.
+ (id)invocationWithProtocol:(Protocol*)targetProtocol selector:(SEL)selector;

@end
