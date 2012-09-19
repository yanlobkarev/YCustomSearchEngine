#import <Foundation/Foundation.h>
#import "SearchParameters.h"
#import "YSearchError.h"


@protocol YCustomSearchEngineDelegate;


@interface YCustomSearchEngine : NSObject<NSURLConnectionDelegate>

@property (nonatomic, readonly) NSObject<YCustomSearchEngineDelegate> *delegate;
- (id)initWithCX:(NSString *)aCx apiKey:(NSString *)anApiKey andDelegate:(NSObject<YCustomSearchEngineDelegate> *) aDelegate;
- (void)search:(NSString *)searchStr;
- (void)cancel;
@end


@protocol YCustomSearchEngineDelegate
- (void)customSearchEngine:(YCustomSearchEngine *)engine didFindResultts:(NSArray *)results;
- (void)customSearchEngine:(YCustomSearchEngine *)engine didReceiveError:(YSearchError *)results;
@optional
- (YCSEType)searchType4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEImageSize)imageSize4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEFileType)fileType4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEResponseType)responseType4customSearchEngine:(YCustomSearchEngine *)engine;
@end
