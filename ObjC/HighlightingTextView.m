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
#import "LuaSyntaxHighlighter.h"
#import <QuartzCore/QuartzCore.h>


@interface HighlightingTextViewDelegate : NSObject <UITextViewDelegate>
@end

@implementation HighlightingTextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSString* newText = [text stringByReplacingOccurrencesOfString:@"\t" withString:@"  "];
	if (![newText isEqualToString:text]) {
		textView.text = [textView.text stringByReplacingCharactersInRange:range withString:newText];
		return NO;
	}
	return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
	[textView setNeedsDisplay];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[scrollView setNeedsDisplay];
}
@end


@interface HighlightingTextView ()
- (void)setup;
@end

@implementation HighlightingTextView

@synthesize attributedTextView;
@synthesize syntaxHighlighter;

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
	internalDelegate = [[HighlightingTextViewDelegate alloc] init];
	self.delegate = internalDelegate;
	
	syntaxHighlighter = [[LuaSyntaxHighlighter alloc] init];
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
	
}

- (void)dealloc {
	self.delegate = nil;
	[internalDelegate release];
	[attributedTextView release];
	[syntaxHighlighter release];
	[super dealloc];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	attributedTextView.bounds = internalDocumentView.bounds;
	attributedTextView.center = internalDocumentView.center;
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	attributedTextView.string = [syntaxHighlighter highlight:self.text];
	[attributedTextView setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];
	syntaxHighlighter.font = font;
}

- (void)setText:(NSString *)text {
	[super setText:text];
	attributedTextView.string = [syntaxHighlighter highlight:self.text];
}

@end
