//
//  WLCrypto.m
//  FoodHealth
//
//  Created by 恶狼 on 12-12-13.
//
//

#import <CommonCrypto/CommonCrypto.h>

#import "WLCrypto.h"

#import "GTMBase64.h"

@implementation WLCrypto

const char *before = "gZ7o/GQ0dLgooutRrIzBDT7E7zNIiAtMzLqXXQ+l/RvMGhuv";
const char *keys[] = {"ypta5b8pCFGGCjUi", "VPELRqWLc9vlOTss"};
const char *middle = "v9zFeoRPDZRhVoxbvH7hzbWq0ldrRUo272zSOCGTq4BePi7Aj21ikQGdNy23VGhi";
const char *ivs[] = {"XMD+uff6YwKVIwVG", "ip1oGdxxGAAQP9e+D"};
const char  *end = "3WKFvHDMIzpxp8N9HHGl2bBM6o18hDKe";

+(NSString *)decrypt_by_aes:  (NSString  *) value with: (NSInteger) index
{
	return @"";
}

+(NSString *)base64_decrypt_by_aes: (NSString *) input with: (NSInteger) index
{
	NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	data = [GTMBase64 decodeData:  data];
	
	size_t output_len = data.length + kCCBlockSizeAES128;
	char *output = malloc(output_len);
	memset(output, 0, output_len);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0, keys[0], kCCKeySizeAES128, ivs[0], [data bytes], [data length], output, output_len, &numBytesEncrypted);
	
	if (status == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		//NSData *dt =  [NSData dataWithBytesNoCopy:output length: numBytesEncrypted];
		
		//NSString * s =  [[NSString alloc] initWithData: dt encoding: NSUTF8StringEncoding];
		NSString *s = [NSString stringWithUTF8String: output];
		
		return [s stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
	}
	
	free(output);
	return @"";
}

@end
