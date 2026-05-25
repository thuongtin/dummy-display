#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginItemController : NSObject

@property(nonatomic, readonly, getter=isEnabled) BOOL enabled;
@property(nonatomic, readonly) BOOL requiresApproval;
@property(nonatomic, copy, readonly) NSString *statusText;

- (BOOL)setEnabled:(BOOL)enabled error:(NSError **)error;
- (NSString *)debugStatusText;

@end

NS_ASSUME_NONNULL_END
