#import "YSearchResult.h"
#import "YSearchRequest.h"


@implementation YSearchResult
@synthesize link;
@synthesize snippet;
@synthesize title;
@synthesize displayLink;
@synthesize htmlTitle;
@synthesize pageMap;
@synthesize image;
@synthesize searchRequest;

+ (id)searchResultWithData:(NSDictionary *)data searchRequest:(YSearchRequest *)searchRequest {
    return [[[YSearchResult alloc] initWithData:data searchRequest:searchRequest] autorelease];
}

- (id)initWithData:(NSDictionary *)data searchRequest:(YSearchRequest *)aSearchRequest {
    if (data == nil) {
        return nil;
    }
    if (self = [super init]) {
        #define SET(key) self->key = [[data valueForKey:@#key] retain];
        SET(link)
        SET(snippet)
        SET(title)
        SET(displayLink)
        SET(htmlTitle)

        NSDictionary *pageMapData = [data valueForKey:@"pagemap"];
        pageMap = [[YPageMap alloc] initWithData:pageMapData];

        NSDictionary *imageData = [data valueForKey:@"image"];
        image = [[YImage alloc] initWithData:imageData];

        searchRequest = [aSearchRequest retain];
    }
    return self;
}

- (void)dealloc {
    [link release];
    [snippet release];
    [title release];
    [displayLink release];
    [htmlTitle release];
    [pageMap release];
    [image release];
    [searchRequest release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ title:`%@`; pageMap:%@; image:%@>", NSStringFromClass([self class]), title, pageMap, image];
}

@end


@implementation YPageMap
@synthesize cse_thumbnail;
@synthesize cse_image;
- (NSString *)_src4Key:(NSString *)key data:(NSDictionary *)data {
    NSArray *srcArr = [data valueForKey:key];
    NSDictionary *srcDic = srcArr.lastObject;
    return [srcDic valueForKey:@"src"];
}

- (id)initWithData:(NSDictionary *)data {
    if (data == nil) {
        return nil;
    }
    if (self = [super init]) {
        cse_thumbnail = [self _src4Key:@"cse_thumbnail" data:data];
        cse_image = [self _src4Key:@"cse_image" data:data];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ thumbnail:%@; image:%@ >", NSStringFromClass([self class]), cse_thumbnail, cse_image];
}

@end


@implementation YImage
@synthesize contextLink;
@synthesize height;
@synthesize width;
@synthesize byteSize;
@synthesize thumbnailLink;
@synthesize thumbnailHeight;
@synthesize thumbnailWidth;
- (id)initWithData:(NSDictionary *)data {
    if (data == nil) {
        return nil;
    }
    #define SETN(key) key = ((NSNumber *)[data valueForKey:@#key]).unsignedIntegerValue;
    if (self = [super init]) {
        SET(contextLink)
        SET(thumbnailLink)
        SETN(height)
        SETN(width)
        SETN(byteSize)
        SETN(thumbnailHeight)
        SETN(thumbnailWidth)
    }
    return self;
}

- (void)dealloc {
    [contextLink release];
    [thumbnailLink release];
    [super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ thumbnailLink:%@; height:%d; width:%d>", NSStringFromClass([self class]), thumbnailLink, width, height];
}

@end