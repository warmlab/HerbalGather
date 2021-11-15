//
//  WLNetwork.m
//  FoodHealth
//
//  Created by 恶狼 on 12-12-20.
//
//

#import "WLNetwork.h"

#import <CFNetwork/CFNetwork.h>

@implementation WLNetwork

@synthesize data;
@synthesize delegate;
@synthesize tag;
@synthesize stream;
@synthesize gotHeaders;

void networkReadCallback(CFReadStreamRef stream, CFStreamEventType eventType, void *arg);
void *CFClientRetain(void *object);
void CFClientRelease(void *object);
CFStringRef CFClientDescribeCopy(void *object);

static int streamCount = 0;

+ (WLNetwork *)networkURL:(CFURLRef)url
		   delegate:(id<WLNetworkDelegate>)delegate tag:(NSInteger)tag name:(NSString *)name
{
	return [[[WLNetwork alloc] initWithURL:url delegate:delegate tag:tag name: name] autorelease];
}

- (id)initWithURL:(CFURLRef)_url
		 delegate:(id<WLNetworkDelegate>)_delegate
			  tag:(NSInteger)_tag name:(NSString *)name
{
	// Copy properties
	self.delegate = _delegate;
	tag = _tag;
	self.name = [name copy];
	data = [NSMutableData new];
	
	CFHTTPMessageRef request = CFHTTPMessageCreateRequest(
														  kCFAllocatorDefault,
														  CFSTR("GET"),
														  (CFURLRef)_url,
														  kCFHTTPVersion1_1);
	if(request != NULL) {
		//CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Keep-Alive"), CFSTR("30"));
		CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Accept"), CFSTR("*/*"));
		CFHTTPMessageSetHeaderFieldValue(request, CFSTR("User-Agent"),  CFSTR("WARMLAB-FoodHealth"));
		//CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Content-Length"),  CFSTR("0"));
		
		stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
		
		if(stream != NULL) {
			CFStreamClientContext context = {
				0, (void *)self,
				CFClientRetain,
				CFClientRelease,
				CFClientDescribeCopy
			};
			CFReadStreamSetClient(stream,
								  kCFStreamEventHasBytesAvailable |
								  kCFStreamEventErrorOccurred |
								  kCFStreamEventEndEncountered,
								  networkReadCallback,
								  &context);
			CFReadStreamScheduleWithRunLoop(stream,
											CFRunLoopGetCurrent(),
											kCFRunLoopCommonModes);
			
			
			CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanTrue);
			CFReadStreamOpen(stream);
			
			streamCount++;
		} else {
			[delegate network:self didFailWithError:NULL];
		}
	} else {
		[delegate network:self didFailWithError:NULL];
	}
	CFRelease(request);
	
	return self;
}

- (void)cancel
{
	CFReadStreamClose(stream);
	// This will release the network object
	CFReadStreamSetClient(stream, kCFStreamEventNone, NULL, NULL);
}

- (void)detach
{
	if(streamCount > 1) {
		CFReadStreamClose(stream);
	} 
	// This will release the network object
	CFReadStreamSetClient(stream, kCFStreamEventNone, NULL, NULL);
}

+ (void)releaseStream:(id)streamObject
{
	CFRelease((CFReadStreamRef)streamObject);
}

- (void)dealloc
{
	// FIXME: This fixes case where retain count for stream is 1 and after returning
	// from this function CFNetwork routines crashes, because stream context is freed.
	//CFRelease(stream);
	[WLNetwork performSelector:@selector(releaseStream:) withObject:(id)stream afterDelay:10];
	
	//[(NSObject *)delegate release];
	[data release];
	
	streamCount--;
	
	[super dealloc];
}

#pragma mark -
#pragma mark CFNetwork management

void *CFClientRetain(void *object)
{
	return (void *)[(id)object retain];
}

void CFClientRelease(void *object)
{
	[(id)object release];
}

CFStringRef CFClientDescribeCopy(void *object)
{
	return (CFStringRef)[[(id)object description] retain];
}

void networkReadCallback(CFReadStreamRef stream, CFStreamEventType eventType, void *arg)
{
	WLNetwork *network = (WLNetwork *)arg;
	if(!network.gotHeaders) {
		network.gotHeaders = YES;
		CFHTTPMessageRef response = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
		if(response == NULL) {
			[network.delegate network:network didFailWithError:NULL];
			[network cancel];
			return;
		}
		CFStringRef contentLengthString = CFHTTPMessageCopyHeaderFieldValue(response, CFSTR("Content-Length"));
		NSUInteger contentLength = NSURLResponseUnknownLength;
		if(contentLengthString != NULL) {
			contentLength = (NSUInteger)CFStringGetIntValue(contentLengthString);
			CFRelease(contentLengthString);
		}
		CFStringRef contentType = CFHTTPMessageCopyHeaderFieldValue(response, CFSTR("Content-Type"));
		NSInteger statusCode = CFHTTPMessageGetResponseStatusCode(response);
		CFRelease(response);
		[network.delegate network:network didReceiveStatusCode:statusCode contentLength:contentLength contentType: (NSString*)contentType];
		if(contentType != NULL) {
			CFRelease(contentType);
		}
	}
	switch(eventType) {
		case kCFStreamEventHasBytesAvailable:
			if(network.data != nil) {
				UInt8 buf[2048];
				CFIndex bytesRead = CFReadStreamRead(stream, buf, sizeof(buf));
				// Returning -1 means an error
				if(bytesRead == -1) {
					[network.delegate network:network didFailWithError:NULL];
					[network cancel];
				} else if(bytesRead > 0) {
					[network.data appendBytes:buf length:bytesRead];
					[network.delegate networkDidReceiveData: network byteRead: bytesRead];
				}
			}
			break;
		case kCFStreamEventErrorOccurred:
			[network.delegate network:network didFailWithError:NULL];
			[network cancel];
			break;
		case kCFStreamEventEndEncountered:
			[network.delegate networkDidFinishLoading:network];
			[network detach];
			break;
		default:
			break;
	}
}

@end
