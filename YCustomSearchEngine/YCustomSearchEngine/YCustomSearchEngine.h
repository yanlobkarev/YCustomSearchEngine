#import <Foundation/Foundation.h>
#import "SearchParameters.h"


@protocol YCustomSearchEngineDelegate;


@interface YCustomSearchEngine : NSObject

@property (nonatomic, readonly) NSObject<YCustomSearchEngineDelegate> *delegate;
- (id)initWithCX:(NSString *)aCx apiKey:(NSString *)anApiKey andDelegate:(NSObject<YCustomSearchEngineDelegate> *) aDelegate;
- (void)search:(NSString *)searchStr;
@end


@protocol YCustomSearchEngineDelegate
@optional
- (YCSEType)searchType4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEImageSize)imageSize4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEFileType)fileType4customSearchEngine:(YCustomSearchEngine *)engine;
- (YCSEResponseType)responseType4customSearchEngine:(YCustomSearchEngine *)engine;
@end
