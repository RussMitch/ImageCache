//
//  ImageCache.m
//
//  Created by Russell on 11/16/12.
//  Copyright (c) 2012 Russell Research Corporation. All rights reserved.
//
//------------------------------------------------------------------------------

#import "ImageCache.h"

@implementation ImageCache

static ImageCache *instance;

#define kImageDirectory @"ImageCache"

//------------------------------------------------------------------------------
+ (id)sharedInstance
//------------------------------------------------------------------------------
{
    @synchronized( self ) {
        
        if (instance == nil) {
            
            instance = [[ImageCache alloc] init];
            
            NSArray *paths= NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
            NSString *dirPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
        }
    }
    
    return instance;
}

//------------------------------------------------------------------------------
+ (UIImage *)fetchImageNamed:(NSString *)imageName
//------------------------------------------------------------------------------
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    NSString *dirPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    NSString *filePath= [NSString stringWithFormat:@"%@/%@", dirPath, imageName];
    
    if ([ImageCache imageIsCached:imageName]) {
        
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
        
    }
    
    return nil;
}


//------------------------------------------------------------------------------
+ (BOOL)imageIsCached:(NSString *)imageName
//------------------------------------------------------------------------------
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    NSString *dirPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    NSString *filePath= [NSString stringWithFormat:@"%@/%@", dirPath, imageName];
        
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

//------------------------------------------------------------------------------
+ (void)saveImageNamed:(NSString *)imageName withData:(NSData *)data
//------------------------------------------------------------------------------
{
    NSArray *paths= NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    NSString *dirPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    NSString *filePath= [NSString stringWithFormat:@"%@/%@", dirPath, imageName];
    
    [data writeToFile:filePath atomically:YES];
}

//------------------------------------------------------------------------------
+ (void)clearImageCache
//------------------------------------------------------------------------------
{
    // remove all images older than kImageCacheLifetimeMinutes
    
    NSArray *paths= NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    NSString *dirPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if (fabs( [[attrs fileModificationDate] timeIntervalSinceNow] ) > kImageCacheLifetimeMinutes*60 ) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

//------------------------------------------------------------------------------
+ (void)deleteImageCache
//------------------------------------------------------------------------------
{
    // remove all images

    NSArray *paths= NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES );
    NSString *dirPath= [[paths objectAtIndex:0] stringByAppendingPathComponent:kImageDirectory];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
