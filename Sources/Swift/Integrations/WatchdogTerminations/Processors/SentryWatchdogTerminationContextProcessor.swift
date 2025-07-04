@_implementationOnly import _SentryPrivate
import Foundation

@objcMembers
@_spi(Private) public class SentryWatchdogTerminationContextProcessor: NSObject {

    private let dispatchQueueWrapper: SentryDispatchQueueWrapper
    private let scopeContextStore: SentryScopeContextPersistentStore

    init(
        withDispatchQueueWrapper dispatchQueueWrapper: SentryDispatchQueueWrapper,
        scopeContextStore: SentryScopeContextPersistentStore
    ) {
        self.dispatchQueueWrapper = dispatchQueueWrapper
        self.scopeContextStore = scopeContextStore

        super.init()

        clear()
    }

    public func setContext(_ context: [String: [String: Any]]?) {
        SentrySDKLog.debug("Setting context in background queue: \(context ?? [:])")
        dispatchQueueWrapper.dispatchAsync { [weak self] in
            guard let strongSelf = self else {
                SentrySDKLog.debug("Can not set context, reason: reference to context processor is nil")
                return
            }
            guard let context = context else {
                SentrySDKLog.debug("Context is nil, deleting active file.")
                strongSelf.scopeContextStore.deleteContextOnDisk()
                return
            }
            strongSelf.scopeContextStore.writeContextToDisk(context: context)
        }
    }
    
    public func clear() {
        SentrySDKLog.debug("Deleting context file in persistent store")
        scopeContextStore.deleteContextOnDisk()
    }
}
