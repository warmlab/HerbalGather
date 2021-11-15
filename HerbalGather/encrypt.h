//
//  encrypt.h
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

unsigned char encrypt_char(const int type, const unsigned char c);
unsigned char decrypt_char(const int type, const unsigned char c);
unsigned char decrypt_char2(const int type, const unsigned char c);
unsigned short encrypt_short(const int type, const unsigned short v);
unsigned short decrypt_short(const int type, const unsigned short v);
unsigned short decrypt_short2(const int type, const unsigned short v);
unsigned char *decrypt_string(unsigned char *s, const unsigned char key);
