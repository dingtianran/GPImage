//
//  ImageCache.m
//  GreenPeaceApp
//
//  Created by ding tr on 10-11-9.
//  Copyright 2010 ding. All rights reserved.
//

#import "ImageCache.h"
#import "URLCacheConnection.h"

static ImageCache* shared;

@implementation ImageCache

- (ImageCache*) init {
	self = [super init];
	if(self!= nil) {
		filename2UIImages =  [[NSMutableDictionary alloc] initWithCapacity:100];
		urlStr2LocalFilename =  [[NSMutableDictionary alloc] initWithCapacity:20];
		urlStr2Connection =  [[NSMutableDictionary alloc] initWithCapacity:20];
		notifyWhenURLLoadedList =  [[NSMutableDictionary alloc] initWithCapacity:20];
		
	}
	return self;
}

+ (ImageCache*) sharedCache {
	if( shared == nil ) {
		shared = [[ImageCache alloc] init];
	}
	return shared;
	
}

- (void) notifyWhenImageLoaded:(NSString*)URLStr notifyWho:(id)obj call:(SEL)notifyFunc {
	if( URLStr == nil ) {
		return;
	}
	// check if image has already been downloaded
	NSString* filename;
	if( (filename = [urlStr2LocalFilename objectForKey:URLStr]) != nil ) {
		UIImage* img = [filename2UIImages objectForKey:filename];
		if( img == nil ) {
			img = [UIImage imageWithContentsOfFile:filename];
			if(img) {
				[filename2UIImages setObject:img forKey:filename];
			}
		}
		else {
			[obj performSelector:notifyFunc withObject:img];
		}
		return;
	}
	// check if a request has been issued for the image path already.
	if( [urlStr2Connection objectForKey:URLStr] == nil ) {
		NSURL* url;
		url = [NSURL URLWithString:URLStr];
		URLCacheConnection* con = [[URLCacheConnection alloc] initWithURL:url withTag:0 delegate:self];
		[urlStr2Connection setObject:con forKey:URLStr];
		[con release];
		
	}
	
	if( obj != nil ) // happens when precaching the image.
	{
		NSMutableArray* list = [notifyWhenURLLoadedList objectForKey:URLStr];
		if( list == nil ) {
			list = [[NSMutableArray alloc] initWithCapacity:4];
			[notifyWhenURLLoadedList setObject:list forKey:URLStr];
			[list release];
		}
		NSArray* found = nil;
		NSValue* notifySelector = [NSValue valueWithPointer:notifyFunc];
		for( NSArray* tuple in list ) {
			// compare func as well incase wants multiple func calls for 1 url
			if( [tuple objectAtIndex:0] == obj && [[tuple objectAtIndex:1] isEqualToValue: notifySelector] ) {
				found = tuple;
				break;
			}
		}
		if( found == nil ) {
			found = [NSArray arrayWithObjects:obj, notifySelector, nil];
			[list addObject:found];
		}
	}
	
}

- (void) processNotificationsForURL:(NSString*)URLStr Image:(UIImage*)img {
	NSMutableArray* list;
	if( list = [notifyWhenURLLoadedList objectForKey:URLStr] ) {
		for( NSArray* tuple in list ) {
			[[tuple objectAtIndex:0] performSelector:(SEL)[[tuple objectAtIndex:1] pointerValue] withObject:img];
		}
	}
}

#pragma mark URLCacheConnectionDelegate
- (void) connectionDidFail:(URLCacheConnection *)theConnection {
	NSLog(@"Failed image connection received from URL %@", theConnection.URL);

	
}

- (void) connectionDidFinish:(URLCacheConnection *)theConnection {
	URLCacheConnection* con;
	NSString* URLStr;
	if( con = [urlStr2Connection objectForKey:[theConnection.URL absoluteString]] ) {
		URLStr = [theConnection.URL absoluteString];
	}
	else if( con = [urlStr2Connection objectForKey:[theConnection.URL relativeString]] ) {
		URLStr = [theConnection.URL relativeString];
	}
	else {
		NSLog(@"unknown connection received from URL %@", theConnection.URL);
		return;
	}
	NSArray* urlPathElements = [URLStr componentsSeparatedByString:@"/"];
	NSString* filename = [urlPathElements objectAtIndex:([urlPathElements count] - 1)]; // get last path element, should be the filename
	
	[self saveData:theConnection.receivedData fileName:filename];
	
	[urlStr2LocalFilename setObject:filename forKey:URLStr];
	UIImage* img = [self createUIImageFromFilename:filename];
	[self processNotificationsForURL:URLStr Image:img];
	
	[urlStr2Connection removeObjectForKey:URLStr];
		
}


- (UIImage*) createUIImageFromFilename:(NSString*)filename {
	NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
	UIImage* img = [UIImage imageWithContentsOfFile:filePath];
	if(img){
		[filename2UIImages setObject:img forKey:filename];
	}
	return img;
}

- (void) saveData:(NSData*)data fileName:(NSString*)fname
{
	NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fname];
	// Cache image if not already cached
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO)
	{
		/* file doesn't exist, so create it */
		[[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
	}
}

- (void) deleteFile:(NSString*)filePath
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES)
	{
		/* file exists, so delete it */
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
	}
}

- (void) dealloc {
	[filename2UIImages removeAllObjects];
	[filename2UIImages release];
	[urlStr2LocalFilename removeAllObjects];
	[urlStr2LocalFilename release];
	[urlStr2Connection removeAllObjects];
	[urlStr2Connection release];
	[notifyWhenURLLoadedList removeAllObjects];
	[notifyWhenURLLoadedList release];
	[super dealloc];
}

@end
