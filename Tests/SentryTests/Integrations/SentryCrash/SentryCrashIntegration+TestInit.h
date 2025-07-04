#import "SentryCrashIntegration.h"

NS_ASSUME_NONNULL_BEGIN

@interface SentryCrashIntegration (TestInit)

- (instancetype)initWithCrashAdapter:(SentryCrashWrapper *)crashWrapper
             andDispatchQueueWrapper:(SentryDispatchQueueWrapper *)dispatchQueueWrapper;

@end

NS_ASSUME_NONNULL_END
