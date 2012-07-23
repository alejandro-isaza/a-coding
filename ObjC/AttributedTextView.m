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

#import "AttributedTextView.h"
#import <CoreText/CoreText.h>

static CGFloat MARGIN = 8;


@interface AttributedTextView ()
- (void)drawLine:(NSRange)range offset:(CGFloat)offset context:(CGContextRef)context;
@end

@implementation AttributedTextView

@synthesize string;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	self.backgroundColor = [UIColor whiteColor];
	self.userInteractionEnabled = NO;
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (!self)
		return nil;
	
	self.backgroundColor = [UIColor whiteColor];
	self.userInteractionEnabled = NO;
	return self;
}

- (void)dealloc {
	[string release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	if (string.length == 0)
		return;
	
	// flip the coordinate system
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Get the text bounds
	CGSize size = self.bounds.size;
	CGRect r = CGRectMake(MARGIN, MARGIN, size.width - 2*MARGIN, size.height - 2*MARGIN);
	
	// Get line height
	CTFontRef font = (CTFontRef)[string attribute:(id)kCTFontAttributeName atIndex:0 effectiveRange:NULL];
	CGFloat lineHeight = [[self class] lineHeight:font];
	
	// Draw lines
	CGFloat y = r.size.height - MARGIN + 2;
	NSCharacterSet* cs = [NSCharacterSet newlineCharacterSet];
	NSCharacterSet* wscs = [NSCharacterSet whitespaceCharacterSet];
	NSRange range = NSMakeRange(0, string.length);
	while (range.length > 0) {
		// Find next line break
		NSUInteger len;
		NSRange next = [string.string rangeOfCharacterFromSet:cs options:NSLiteralSearch range:range];
		if (next.location == NSNotFound)
			len = range.length;
		else
			len = next.location - range.location;
		
		// Empty line, just skip
		if (len == 0) {
			range.location += 1;
			range.length -=  1;
			y -= lineHeight;
			continue;
		}
		
		// Get one line of text
		NSRange lineRange = NSMakeRange(range.location, len);
		NSAttributedString* s = [string attributedSubstringFromRange:lineRange];
		CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)s);
		CGRect lineRect = CTLineGetImageBounds(line, context);
		while (lineRange.length > 0 && lineRect.size.width > rect.size.width - 16) {
			// Line doesn't fit, wrap
			NSRange wsRange = [string.string rangeOfCharacterFromSet:wscs options:NSBackwardsSearch range:lineRange];
			if (wsRange.length == 0)
				len -= 1;
			else
				len = wsRange.location - lineRange.location;
			
			// Get shorter line of text
			lineRange.length = len;
			s = [string attributedSubstringFromRange:lineRange];
			CFRelease(line);
			line = CTLineCreateWithAttributedString((CFAttributedStringRef)s);
			lineRect = CTLineGetImageBounds(line, context);
		}
		
		// Adjust range
		range.location += len + 1;
		range.length -= MIN(range.length, len + 1);
		
		// Draw
		CGContextSetTextPosition(context, MARGIN, y);
		CTLineDraw(line, context);
		CFRelease(line);
		
		y -= lineHeight;
	}
}

+ (CGFloat)lineHeight:(CTFontRef)font {
	CGFloat ascent = CTFontGetAscent(font);
	CGFloat descent = CTFontGetDescent(font);
	CGFloat leading = CTFontGetLeading(font);
	return ceilf(ascent + descent + leading);
}

@end
