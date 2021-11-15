//
//  WLNetwork.h
//  FoodHealth
//
//  Created by 恶狼 on 12-12-20.
//
//

#import <Foundation/Foundation.h>

#import  <CFNetwork/CFNetwork.h>

@class WLNetwork;

@protocol WLNetworkDelegate

- (void)network:(WLNetwork *)network didFailWithError:(NSError *)error;
- (void)networkDidFinishLoading: (WLNetwork *)connection;
- (void)networkDidReceiveData: (WLNetwork *)connection byteRead: (NSUInteger) byteNumber;
- (void)network:(WLNetwork *)network didReceiveStatusCode:(NSInteger)statusCode contentLength:(NSUInteger)contentLength contentType: (NSString *)contentType;

@end

@interface WLNetwork : NSObject

// Internal
@property (nonatomic, retain) id<WLNetworkDelegate> delegate;
@property (assign) NSInteger tag;
@property (assign) NSString *name;
@property (assign) CFReadStreamRef stream;
@property (assign) BOOL gotHeaders;

// Set by the user
@property (nonatomic, retain) NSMutableData *data;

- (id)initWithURL:(CFURLRef)url
		 delegate:(id<WLNetworkDelegate>)_delegate
			  tag:(NSInteger)_tag
			 name: (NSString*)name;
+ (WLNetwork *)networkURL:(CFURLRef)url
				 delegate:(id<WLNetworkDelegate>)delegate
					  tag:(NSInteger)tag
					 name: (NSString*)name;
- (void)cancel;

@end
