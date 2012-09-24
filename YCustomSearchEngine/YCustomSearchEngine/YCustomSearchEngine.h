#import <Foundation/Foundation.h>
#import "SearchParameters.h"
#import "YSearchError.h"


@protocol YCustomSearchEngineDelegate;
@class YSearchRequest;


@interface YCustomSearchEngine : NSObject<NSURLConnectionDelegate>

@property (nonatomic, readonly) NSObject<YCustomSearchEngineDelegate> *delegate;
- (id)initWithCX:(NSString *)aCx apiKey:(NSString *)anApiKey andDelegate:(NSObject<YCustomSearchEngineDelegate> *) aDelegate;
- (void)search:(NSString *)searchStr startingAt:(NSUInteger)start;
- (void)search:(NSString *)searchStr;
- (void)cancel;
@end


@protocol YCustomSearchEngineDelegate
- (void)customSearchEngine:(YCustomSearchEngine *)engine didFindResultts:(NSArray *)results forRequest:(YSearchRequest *)searchRequest;
- (void)customSearchEngine:(YCustomSearchEngine *)engine didReceiveError:(YSearchError *)results;
@optional
- (YCSEType)searchType4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEImageSize)imageSize4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEResponseType)responseType4customSearchEngine:(YCustomSearchEngine *)engine;
- (NSSet *)fileTypes4customSearchEngine:(YCustomSearchEngine *)engine;          //  should be returned a set of file extensions (like "png", "jpg", "pdf")
@end
