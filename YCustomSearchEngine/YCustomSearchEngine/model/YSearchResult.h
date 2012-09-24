#import <Foundation/Foundation.h>
#import "Constants.h"
#import "YSearchRequest.h"


@class YPageMap;
@class YImage;



@interface YSearchResult : NSObject
@property (nonatomic, readonly) NSString *link;
@property (nonatomic, readonly) NSString *snippet;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *displayLink;
@property (nonatomic, readonly) NSString *htmlTitle;
@property (nonatomic, readonly) YPageMap *pageMap;
@property (nonatomic, readonly) YSearchRequest *searchRequest;
@property (nonatomic, readonly) YImage   *image;
+ (id)searchResultWithData:(NSDictionary *)data searchRequest:(YSearchRequest *)searchRequest;
@end


@interface YPageMap : NSObject
@property (nonatomic, readonly) NSString *cse_thumbnail;
@property (nonatomic, readonly) NSString *cse_image;
- (id)initWithData:(NSDictionary *)data;
@end


@interface YImage : NSObject
@property (nonatomic, readonly)  NSString   *contextLink;
@property (nonatomic, readonly)  NSUInteger height;
@property (nonatomic, readonly)  NSUInteger width;
@property (nonatomic, readonly)  NSUInteger byteSize;
@property (nonatomic, readonly)  NSString   *thumbnailLink;
@property (nonatomic, readonly)  NSUInteger thumbnailHeight;
@property (nonatomic, readonly)  NSUInteger thumbnailWidth;
- (id)initWithData:(NSDictionary *)data;
@end