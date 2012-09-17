#import "YCustomSearchEngine.h"
#import "Constants.h"
#import "NSDictionary+Helpers.h"


@implementation YCustomSearchEngine {
    NSString *cx;
    NSString *apiKey;
    struct {
        BOOL delegateSearchType;
        BOOL delegateImageSize;
        BOOL delegateFileType;
        BOOL delegateResponseType;
    } flags;
    NSMutableSet *connections;
}

@synthesize delegate;

- (id)initWithCX:(NSString *)aCx apiKey:(NSString *)anApiKey andDelegate:(NSObject<YCustomSearchEngineDelegate> *) aDelegate {

    if (aCx == nil || aDelegate == nil || aDelegate == nil) {
        return nil;
    }

    if (self = [super init]) {
        cx = aCx;
        apiKey = anApiKey;
        delegate = aDelegate;

        flags.delegateFileType = [delegate respondsToSelector:@selector(fileType4customSearchEngine:)];
        flags.delegateImageSize = [delegate respondsToSelector:@selector(imageSize4customSearchEngine:)];
        flags.delegateResponseType = [delegate respondsToSelector:@selector(responseType4customSearchEngine:)];
        flags.delegateSearchType = [delegate respondsToSelector:@selector(searchType4customSearchEngine:)];

        connections = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc {
    for (NSURLConnection *con in connections) {
        [con cancel];
    }
    [connections release];
    [super dealloc];
}

#pragma mark Private

- (NSString *)_host {
    return @"https://www.googleapis.com/customsearch/v1";
}

- (NSDictionary *)_cseIdentityParams {
    return [NSDictionary dictionaryWithObjectsAndKeys:cx, apiKey, CX, API_KEY, nil];
}

- (NSString *)_cseType:(YCSEType)type {
    switch (type) {
        case YCSETypeImage: return @"image";
        default:            return nil;
    }
}

- (NSString *)_cseImageSize:(YCSEImageSize)size {
    switch (size) {
         case YCSEImageSizeIcon       : return @"icon";
         case YCSEImageSizeSmall      : return @"small";
         case YCSEImageSizeMedium     : return @"medium";
         case YCSEImageSizeLarge      : return @"large";
         case YCSEImageSizeXlarge     : return @"xlarge";
         case YCSEImageSizeXxlarge    : return @"xxlarge";
         case YCSEImageSizeHuge       : return @"huge";
         default: return nil;
    }
}

- (NSArray *)_cseFileTypes:(YCSEFileType)type {
    NSMutableArray *fileTypes = [NSMutableArray array];
    if (type | PNG) [fileTypes addObject:@"png"];
    if (type | JPG) [fileTypes addObject:@"jpg"];
    if (type | BMP) [fileTypes addObject:@"bmp"];
    return fileTypes;
}

- (NSString *)_cseResponseType:(YCSEResponseType)type {
    switch (type) {
        case YCSEResponseTypeJSON: return @"json";
        default: return nil;
    }
}

#pragma mark Public

- (void)search:(NSString *)searchStr {
    NSMutableDictionary *params = [self _cseIdentityParams].mutableCopy;
    [params setValue:searchStr forKey:QUERY];

    if (flags.delegateSearchType) {
        NSString *searchType = [self _cseType:[delegate searchType4customSearchEngine:self]];
        if (searchType) {
            [params setValue:searchType forKey:SEARCH_TYPE];
        }
    }

    if (flags.delegateImageSize) {
        NSString *imgSize = [self _cseImageSize:[delegate imageSize4customSearchEngine:self]];
        [params setValue:imgSize forKey:IMAGE_SIZE];
    }

    if (flags.delegateResponseType) {
        NSString *respType = [self _cseResponseType:[delegate responseType4customSearchEngine:self]];
        if (respType) {
            [params setValue:respType forKey:RESPONSE_TYPE];
        }
    }

    //  check with Reachability

    NSString *urlParams = [params urlEncodedString];
    NSString *url = [NSString stringWithFormat:@"%@?%@", [self _host], urlParams];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connections addObject:connection];
    [connection start];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"~ connection:didFailWithError: %@ ~", error);
    //  todo: delegate
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"~ Response: %@ ~", responseString);
    [responseString release];
    //  todo: delegate
}

@end
