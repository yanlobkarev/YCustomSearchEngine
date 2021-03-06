#import "YCustomSearchEngine.h"
#import "Constants.h"
#import "NSDictionary+Helpers.h"
#import "JSONKit.h"
#import "YSearchResult.h"
#import "YSearchRequest.h"
#import "Reachability_.h"


NSString *const YCustomSearchEngineErrorDomain = @"YCustomSearchEngineErrorDomain";


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

        flags.delegateFileType      = [delegate respondsToSelector:@selector(fileTypes4customSearchEngine:)];
        flags.delegateImageSize     = [delegate respondsToSelector:@selector(imageSize4customSearchEngine:)];
        flags.delegateResponseType  = [delegate respondsToSelector:@selector(responseType4customSearchEngine:)];
        flags.delegateSearchType    = [delegate respondsToSelector:@selector(searchType4customSearchEngine:)];

        connections = [NSMutableSet new];
        data4Connection = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    [self cancel];
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

- (NSString *)_cseResponseType:(YCSEResponseType)type {
    switch (type) {
        case YCSEResponseTypeJSON: return @"json";
        default: return nil;
    }
}

#pragma mark Public

- (BOOL)busy {
    return connections.count != 0;
}

- (void)search:(NSString *)searchStr startingAt:(NSUInteger)start {
    NSMutableDictionary *params = [[self _cseIdentityParams].mutableCopy autorelease];
    [params setValue:searchStr forKey:QUERY];

    if ( start != 0 ) {     //  causes `Invalid Value`-error
        [params setValue:[NSNumber numberWithUnsignedInteger:start] forKey:START_INDEX];
    }

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

    if (flags.delegateFileType) {
        NSSet *fileTypes = [delegate fileTypes4customSearchEngine:self];
        NSString *fileTypesStr = [fileTypes.allObjects componentsJoinedByString:@" "];
        [params setValue:fileTypesStr forKey:FILE_TYPE];
    }


    Reachability_ *reachability = [Reachability_ reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] == NotReachable) {
        YSearchError *error = [YSearchError errorWithMessage:@"Network is not Reachable."];
        [delegate customSearchEngine:self didReceiveError:error];
        return;
    }

    NSString *urlParams = [params urlEncodedString];
    NSString *url = [NSString stringWithFormat:@"%@?%@", [self _host], urlParams];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.f];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connections addObject:connection];
    [connection start];
}

- (void)search:(NSString *)searchStr {
    [self search:searchStr startingAt:0];
}

- (void)cancel {
    [connections makeObjectsPerformSelector:@selector(cancel)];
    [connections removeAllObjects];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate customSearchEngine:self didReceiveError:[YSearchError errorWithError:error]];
    [self _removeConnection:connection];
}

#pragma mark NSURLConnectionDataDelegate

- (void)_removeConnection:(NSURLConnection *)connection {
    [[connection retain] autorelease];
    [data4Connection removeObjectForKey:connection.description];
    [connections removeObject:connection];
}

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
    [self _removeConnection:connection];

    YSearchError *error = [YSearchError errorWithData:[response valueForKey:@"error"]];
    if (error) {
        [delegate customSearchEngine:self didReceiveError:error];
        return;
    }


    NSArray *arr = [response valueForKeyPath:@"queries.request"];
    NSDictionary *requestData = arr.lastObject;
    YSearchRequest *request = [YSearchRequest searchRequestWithData:requestData];

    NSMutableArray *searchResults = [NSMutableArray array];
    NSArray *items = [response valueForKey:@"items"];
    for (NSDictionary *item in items) {
        YSearchResult *result = [YSearchResult searchResultWithData:item searchRequest:request];
        if (result) {
            [searchResults addObject:result];
        }
    }
    [delegate customSearchEngine:self didFindResultts:searchResults forRequest:request];
}

@end
