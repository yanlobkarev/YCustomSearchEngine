#import <Foundation/Foundation.h>
#import "Constants.h"


@interface YSearchRequest : NSObject {
    @private
        NSString *cx;
}
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, readonly) NSUInteger totalResults;
@property(nonatomic, readonly) NSUInteger count;
@property(nonatomic, readonly) NSString *searchTerms;
@property(nonatomic, readonly) NSUInteger startIndex;
@property(nonatomic, readonly) NSString *inputEncoding;
@property(nonatomic, readonly) NSString *outputEncoding;
@property(nonatomic, readonly) NSString *safe;
@property(nonatomic, readonly) YCSEType searchType;
@property(nonatomic, readonly) YCSEImageSize imgSize;
@property(nonatomic, readonly) NSUInteger lastIndex;

+ (id)searchRequestWithData:(NSDictionary *)data;
@end