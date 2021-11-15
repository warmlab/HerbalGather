//
//  encrypt.c
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#include <string.h>
#include <stdlib.h>

#include "encrypt.h"

unsigned char encrypt_char(const int type, const unsigned char c) {
	unsigned char p1, p2;
	unsigned char v = c << (type & 3);
	if (type & 1) {
		p1 = (v & 0xf0) >> 4;
		p2 = (v & 0xf) << 4;
		v = p1 | p2;
	}

	return v;
}

unsigned char decrypt_char(const int type, const unsigned char c) {
	unsigned char p1, p2;
unsigned char v;
	if (type & 1) {
		p1 = c >> 4;
		p2 = c << 4;
		v = p1 | p2;
	}

	v = v >> (type & 3);
	return v;
}

unsigned char decrypt_char2(const int type, const unsigned char c) {
	return c ^ 67 ^ (0xff & type);
}

unsigned short encrypt_short(const int type, const unsigned short v) {
	union {
		unsigned short s;
		unsigned char c[2];
	} u;
	u.s = v << (type & 3);
	if (type & 1) {
		char c = u.c[1];
		u.c[1] = u.c[0];
		u.c[0] = c;
	}

	return u.s;
}

unsigned short decrypt_short(const int type, const unsigned short v) {
	union {
		unsigned short s;
		unsigned char c[2];
	} u;

	u.s = v;
	if (type & 1) {
		char c = u.c[1];
		u.c[1] = u.c[0];
		u.c[0] = c;
	}
	u.s = u.s >> (type & 3);

	return u.s;
}

unsigned short decrypt_short2(const int type, const unsigned short s) {
	return s ^ 67 ^ (0xffff & type);
}

unsigned char *decrypt_string(unsigned char *s, const unsigned char key) {
    int i;
    unsigned char p1, p2, b1, b2;
    unsigned char *result;
    int len = strlen((char *)s);
    if (len & 1)
        return NULL;
    result = malloc((len >> 1) + 1);
    memset(result, 0, (len >> 1) + 1);
    for (i = 0; i < len; i += 4) {
        if (i + 3 < len) {
            b2 = ((s[i] - 97) << 4) | (s[i + 1] - 97);
            b1 = ((s[i + 2] - 97) << 4) | (s[i + 3] - 97);
            b1 = b1 ^ key;
            p1 = (key >> 4) & 0x0f;
            p2 = (key << 4) & 0xf0;
            b2 = b2 ^ (p1 | p2);
            result[i >> 1] = b1;
            result[(i >> 1) + 1] = b2;
        } else{
            b1 = (((s[i] - 97) << 4) | (s[i + 1] - 97)) ^ key;
            result[i >> 1] = b1;
        }
    }
    
    return result;
}
