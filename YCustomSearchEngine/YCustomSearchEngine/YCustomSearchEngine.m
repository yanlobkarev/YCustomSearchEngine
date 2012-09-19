#import "YCustomSearchEngine.h"
#import "Constants.h"
#import "NSDictionary+Helpers.h"
#import "JSONKit.h"
#import "YSearchResult.h"


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
    NSMutableDictionary *data4Connection;
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
        data4Connection = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    for (NSURLConnection *con in connections) {
        [con cancel];
    }
    [connections release];
    [data4Connection release];
    [super dealloc];
}

#pragma mark Private

- (NSString *)_host {
    return @"https://www.googleapis.com/customsearch/v1";
}

- (NSDictionary *)_cseIdentityParams {
    return [NSDictionary dictionaryWithObjectsAndKeys:cx, CX, apiKey, API_KEY, nil];
}

- (NSString *)_cseType:(YCSEType)type {
    switch (type) {
        case YCSETypeImage: return @"image";
        default:            return nil;
    }
}

- (YCSEType)_cseType4Str:(NSString *)typeString {
    if ([typeString isEqualToString:@"image"]) {
        return YCSETypeImage;
    }
    return YCSETypeRegular;
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

    //  todo: check with Reachability

    NSString *urlParams = [params urlEncodedString];
    NSString *url = [NSString stringWithFormat:@"%@?%@", [self _host], urlParams];
    NSLog(@"~ search url: %@ ~", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.f];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connections addObject:connection];
    [connection start];
}

- (void)cancel {
    for (NSURLConnection *con in connections) {
        [con cancel];
    }
    [connections removeAllObjects];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"~ connection:didFailWithError: %@ ~", error);
    //  todo: delegate
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *key = connection.description;
    NSMutableData *dataChunks = [data4Connection objectForKey:key];
    if (dataChunks == nil) {
        dataChunks = [NSMutableData data];
        [data4Connection setObject:dataChunks forKey:key];
    }
    [dataChunks appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *key = connection.description;
    NSMutableData *dataChunks = [data4Connection objectForKey:key];
    NSDictionary *response = [dataChunks objectFromJSONData];
    [data4Connection removeObjectForKey:key];

    YSearchError *error = [YSearchError errorWithData:[response valueForKey:@"error"]];
    if (error) {
        [delegate customSearchEngine:self didReceiveError:error];
        return;
    }

    YCSEType searchType = [self _cseType4Str:[[response valueForKeyPath:@"queries.request.searchType"] lastObject]];

    NSMutableArray *searchResults = [NSMutableArray array];
    NSArray *items = [response valueForKey:@"items"];
    for (NSDictionary *item in items) {
        YSearchResult *result = [YSearchResult searchResultWithData:item searchType:searchType];
        if (result) {
            [searchResults addObject:result];
        }
    }
    [delegate customSearchEngine:self didFindResultts:searchResults];
}

@end
