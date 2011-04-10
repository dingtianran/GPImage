//
//  ImageCache.h
//  GreenPeaceApp
//
//  Created by ding tr on 10-11-9.
//  Copyright 2010 ding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLCacheConnection.h"

@interface ImageCache : NSObject <URLCacheConnectionDelegate> {
	NSMutableDictionary* filename2UIImages;
	NSMutableDictionary* urlStr2LocalFilename;
	NSMutableDictionary* urlStr2Connection;
	NSMutableDictionary* notifyWhenURLLoadedList;

}

+ (ImageCache*) sharedCache;
- (void) notifyWhenImageLoaded:(NSString*)URLStr notifyWho:(id)obj call:(SEL)notifyFunc;

- (UIImage*) createUIImageFromFilename:(NSString*)filename;

- (void) saveData:(NSData*)data fileName:(NSString*)fname;
- (void) deleteFile:(NSString*)filename;

@end
