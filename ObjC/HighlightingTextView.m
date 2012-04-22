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

#import "HighlightingTextView.h"
#import "AttributedTextView.h"
#import <QuartzCore/QuartzCore.h>


@interface HighlightingTextView ()
- (void)setup;
@end

@implementation HighlightingTextView

@synthesize attributedTextView;
@synthesize syntaxHighlighter;

- (void)setSyntaxHighlighter:(id<SyntaxHighlighter>)sh {
	if (syntaxHighlighter == sh)
		return;
	
	[syntaxHighlighter release];
	syntaxHighlighter = [sh retain];
	[self update];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];
	syntaxHighlighter.font = font;
	[self update];
}

- (void)setText:(NSString *)text {
	[super setText:text];
	[self update];
}


#pragma mark -

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self setup];
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (!self)
		return nil;
	
	[self setup];
	return self;
}

- (void)setup {
	syntaxHighlighter.font = self.font;
	
	attributedTextView = [[AttributedTextView alloc] init];
	attributedTextView.string = [syntaxHighlighter highlight:self.text];
	[self addSubview:attributedTextView];
	
	for (UIView* view in self.subviews) {
		if ([view isKindOfClass:NSClassFromString(@"UIWebDocumentView")]) {
			internalDocumentView = view;
			break;
		}
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(textDidChangeNotification:)
												 name:UITextViewTextDidChangeNotification
											   object:self];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.delegate = nil;
	[attributedTextView release];
	[syntaxHighlighter release];
	[super dealloc];
}


#pragma mark -

- (void)awakeFromNib {
	[self update];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	attributedTextView.bounds = internalDocumentView.bounds;
	attributedTextView.center = internalDocumentView.center;
}

- (void)textDidChangeNotification:(NSNotification*)notification {
	[self update];
}

- (void)update {
	attributedTextView.string = [syntaxHighlighter highlight:self.text];
	[attributedTextView setNeedsDisplay];
}

@end
