//
//  main.m
//  ZipToHTMLCmd
//
//  Created by RichS on 02/05/2019.
//  Copyright © 2019 RichS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZipToHTML/ZipToHTML.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc != 2) {
            
            NSLog(@"Usage: %@ <file>", [NSString stringWithFormat:@"%s", argv[0]]);
        }
        
        NSURL* file = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%s", argv[1]]];
        NSString* html = [RSZipToHTML htmlForZIP:file];
        //NSLog(@"%@", html);
        //printf("%s", [[file absoluteString] UTF8String]);
        printf("%s", [html UTF8String]);
    }
    return 0;
}
