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

#import "Observable.h"


@implementation Observable

- (id)init {
	self = [super init];
	if (self) {
		// Create non-retaining sets
		observers = (NSMutableSet*)CFSetCreateMutable(NULL, 0, NULL);
		pendingAdds = (NSMutableSet*)CFSetCreateMutable(NULL, 0, NULL);
		pendingRemoves = (NSMutableSet*)CFSetCreateMutable(NULL, 0, NULL);
	}
	return self;
}

- (void)dealloc {
	[observers release];
	[pendingAdds release];
	[pendingRemoves release];
	[super dealloc];
}

- (void)addObserver:(id<NSObject>)observer {
	if (notifying) {
		// The main set cannot be mutated while iterating, add to a secondary set
		// to be processed when the iteration finishes
		[pendingRemoves removeObject:observer];
		[pendingAdds addObject:observer];
	} else {
		[observers addObject:observer];
	}
}

- (void)removeObserver:(id<NSObject>)observer {
	if (notifying) {
		// The main set cannot be mutated while iterating, add to a secondary set
		// to be processed when the iteration finishes
		[pendingAdds removeObject:observer];
		[pendingRemoves addObject:observer];
	} else {
		[observers removeObject:observer];
	}
}

- (BOOL)containsObserver:(id<NSObject>)observer {
	return ([observers containsObject:observer] && ![pendingRemoves containsObject:observer]) ||
		[pendingAdds containsObject:observer];
}

- (void)commitPending {
	NSAssert(!notifying, @"Tried to commit pending observers while notifying");
	for (id<NSObject> observer in pendingRemoves)
		[observers removeObject:observer];
	[pendingRemoves removeAllObjects];
	
	for (id<NSObject> observer in pendingAdds)
		[observers addObject:observer];
	[pendingAdds removeAllObjects];
}

- (void)notifyObservers:(NSInvocation*)invocation {
	notifying = YES;
	for (id<NSObject> observer in observers) {
		if (![pendingRemoves containsObject:observer] && [observer respondsToSelector:[invocation selector]]) {
			[invocation setTarget:observer];
			[invocation invoke];
		}
	}
	notifying = NO;
	[self commitPending];
}

@end
