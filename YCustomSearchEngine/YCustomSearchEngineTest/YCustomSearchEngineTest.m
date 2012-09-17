#import "YCustomSearchEngineTest.h"
#import "YCustomSearchEngine.h"

@implementation YCustomSearchEngineTest {
    YCustomSearchEngine *cse;
}

- (void)dealloc {
    [cse release];
    [super dealloc];
}

- (void)setUp {
    [super setUp];
    cse = [[YCustomSearchEngine alloc] initWithCX:@"007626669963342932099:ipmii45iaw4"
                                           apiKey:@"AIzaSyBle7mv0EUk4cPf-ssphoLiutFTEflndOo"
                                      andDelegate:self];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    [cse search:@"evette suicide"];
}

#pragma mark YCustomSearchEngineDelegate

- (YCSEType)searchType4customSearchEngine:(YCustomSearchEngine *)_ {
    return YCSETypeImage;
}

- (YCSEImageSize)imageSize4customSearchEngine:(YCustomSearchEngine *)_ {
    return YCSEImageSizeMedium;
}

- (YCSEResponseType)responseType4customSearchEngine:(YCustomSearchEngine *)_ {
    return YCSEResponseTypeJSON;
}

@end
