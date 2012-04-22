//  Copyright 2012 Alejandro Isaza.
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

#import "ViewController.h"

#import "LuaSyntaxHighligther.h"
#import "HighlightingTextView.h"

@interface ViewController ()

@end


@implementation ViewController

@synthesize textView = _textView;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.textView.syntaxHighlighter = [[[LuaSyntaxHighligther alloc] init] autorelease];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	self.textView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
