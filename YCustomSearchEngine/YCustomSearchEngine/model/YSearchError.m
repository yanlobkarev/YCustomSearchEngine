#import "YSearchError.h"


@implementation YSearchError {

}
@synthesize message;
@synthesize code;

+ (id)errorWithData:(NSDictionary *)data {
    if (data == nil) {
        return nil;
    }
    YSearchError *error = [[YSearchError new] autorelease];
    error->message = [[data valueForKey:@"message"] retain];
    NSNumber *code = [data valueForKey:@"code"];
    error->code = code.unsignedIntegerValue;
    return error;
}

+ (id)errorWithMessage:(NSString *)message {
    if (message == nil) {
        return nil;
    }
    YSearchError *error = [[YSearchError new] autorelease];
    error->message = [message retain];
    return error;
}

- (void)dealloc {
    [message release];
    [super dealloc];
}

@end