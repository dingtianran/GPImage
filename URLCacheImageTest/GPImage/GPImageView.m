//
//  GPImageView.m
//  GreenPeaceApp
//
//  Created by ding tr on 10-11-9.
//  Copyright 2010 ding. All rights reserved.
//

#import "GPImageView.h"
#import "ImageCache.h"

@implementation GPImageView

- (id) initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor colorWithRed:0.195 green:0.195 blue:0.195 alpha:1.0];
		self.opaque = YES;
		self.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	}
	return self;
	
}

- (void) setImageURL:(NSString*)url {
	self.image = nil;
	[[ImageCache sharedCache] notifyWhenImageLoaded:url notifyWho:self call:@selector(updateImage:)];

}

- (void) updateImage:(UIImage*)newImage {
	self.image = newImage;
}

- (void)dealloc {
    [super dealloc];
}

@end
