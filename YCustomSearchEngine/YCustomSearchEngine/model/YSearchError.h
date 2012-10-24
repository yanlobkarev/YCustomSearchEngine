#import <Foundation/Foundation.h>


@interface YSearchError : NSObject
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) NSUInteger code;
+ (id)errorWithData:(NSDictionary *)data;
+ (id)errorWithMessage:(NSString *)message;
@end