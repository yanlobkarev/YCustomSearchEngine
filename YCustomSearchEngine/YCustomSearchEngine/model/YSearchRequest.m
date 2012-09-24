#import "YSearchRequest.h"


@implementation YSearchRequest

@synthesize title;
@synthesize totalResults;
@synthesize searchTerms;
@synthesize count;
@synthesize startIndex;
@synthesize inputEncoding;
@synthesize outputEncoding;
@synthesize safe;
@synthesize searchType;
@synthesize imgSize;

+ (YCSEType)_cseType4Str:(NSString *)typeString {
    if ([typeString isEqualToString:@"image"]) {
        return YCSETypeImage;
    }
    return YCSETypeRegular;
}

+ (YCSEImageSize)_cseImageSize4Str:(NSString *)imageSize {
    if ([imageSize isEqualToString:@"icon"])    { return YCSEImageSizeIcon;      }
    if ([imageSize isEqualToString:@"small"])   { return YCSEImageSizeSmall;     }
    if ([imageSize isEqualToString:@"medium"])  { return YCSEImageSizeMedium;    }
    if ([imageSize isEqualToString:@"large"])   { return YCSEImageSizeLarge;     }
    if ([imageSize isEqualToString:@"xlarge"])  { return YCSEImageSizeXlarge;    }
    if ([imageSize isEqualToString:@"xxlarge"]) { return YCSEImageSizeXxlarge;   }
    if ([imageSize isEqualToString:@"huge"])    { return YCSEImageSizeHuge;      }
    return (YCSEImageSize) -1;
}

+ (id)searchRequestWithData:(NSDictionary *)data {
    if (data == nil) {
        return nil;
    }
    #define SET(key) request->key = [[data valueForKey:@#key] retain];
    #define SETN(key) request->key = ((NSNumber *)[data valueForKey:@#key]).unsignedIntegerValue;

    YSearchRequest *request = [[YSearchRequest new] autorelease];

    NSString *searchType = [data valueForKey:SEARCH_TYPE];
    request->searchType = [YSearchRequest _cseType4Str:searchType];

    NSString *totalResults = [data valueForKey:TOTAL_RESULTS];
    if (totalResults != nil) {
        NSNumberFormatter * f = [[NSNumberFormatter new] autorelease];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        request->totalResults = [f numberFromString:totalResults].unsignedIntegerValue;
    }

    NSString *imageSize = [data valueForKey:IMAGE_SIZE];
    if (imageSize) {
        request->imgSize = [YSearchRequest _cseImageSize4Str:imageSize];
    }

    SET(title)
    SET(searchTerms)
    SETN(count)
    SETN(startIndex)
    SET(inputEncoding)
    SET(outputEncoding)
    SET(safe)
    SET(cx)
    return request;
}

- (void)dealloc {
    [title release];
    [searchTerms release];
    [inputEncoding release];
    [outputEncoding release];
    [safe release];
    [cx release];
    [super dealloc];
}

- (NSUInteger)lastIndex {
    return startIndex + count - 1;
}

@end