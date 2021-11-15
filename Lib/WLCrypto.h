//
//  WLCrypto.h
//  FoodHealth
//
//  Created by 恶狼 on 12-12-13.
//
//

#import <Foundation/Foundation.h>

@interface WLCrypto : NSObject

+(NSString *)decrypt_by_aes:  (NSString  *) value with: (NSInteger) index;
+(NSString *)base64_decrypt_by_aes: (NSString *) value with: (NSInteger) index;

@end
