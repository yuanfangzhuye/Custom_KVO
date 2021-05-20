//
//  NSObject+KVO.m
//  Custom_KVO
//
//  Created by lab team on 2021/5/20.
//

#import "NSObject+KVO.h"
#import <objc/message.h>

static NSString *const kLCKVOPrefix = @"kLCKVONotifying_";
static NSString *const kLCKVOAssociateKey = @"kLCLKVO_AssociateKey";

@interface KVOInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions options;

@property(nonatomic, copy) CustomKVOBlock handleBlock;

// 构造方法
- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options;
- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(CustomKVOBlock)handleBlock;

@end

@implementation KVOInfo

- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _options = options;
    }
    
    return self;
}

- (instancetype)initWithObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath handleBlock:(CustomKVOBlock)handleBlock {
    
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _handleBlock = handleBlock;
    }
    
    return self;
}

@end

@implementation NSObject (KVO)

- (void)lc_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    
    // 1. 验证是否存在 setter 方法
    [self judgeHasSetterMethodForKeyPath:keyPath];
    
    // 2. 保存多个信息
    KVOInfo *info = [[KVOInfo alloc] initWithObserver:observer forKeyPath:keyPath options:options];
    
    NSMutableArray *mArray = objc_getAssociatedObject(self,  (__bridge const void * _Nonnull)kLCKVOAssociateKey);
    if (!mArray) {
        mArray = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)kLCKVOAssociateKey, mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [mArray addObject:info];
    
    // 3. 判断automaticallyNotifiesObserversForKey方法返回的布尔值
    if (![self lc_performSelectorWithMethodName:@"automaticallyNotifiesObserversForKey" keyPath:keyPath]) {
        return;
    }
    
    // 4. 动态生成子类
    Class newClass = [self createChildClassWithKeyPath:keyPath];
    
    // 更新 isa 指向
    object_setClass(self, newClass);
    
    //获取sel
    SEL setterSel = NSSelectorFromString([NSString stringWithFormat:@"set%@", keyPath.capitalizedString]);
    //获取setter实例方法
    Method method = class_getInstanceMethod([self class], setterSel);
    //方法签名
    const char *type = method_getTypeEncoding(method);
    //添加一个setter方法
    class_addMethod(newClass, setterSel, (IMP)lc_setter, type);
}

- (void)lc_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    //清空数组
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kLCKVOAssociateKey));
    if (mArray.count <= 0) {
        return;
    }
    
    for (KVOInfo *info in mArray) {
        if ([info.keyPath isEqualToString:keyPath]) {
            [mArray removeObject:info];
            objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(kLCKVOAssociateKey), mArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    if (mArray.count <= 0) {
        //isa指回父类
        Class superClass = [self class];
        object_setClass(self, superClass);
    }
}


#pragma mark - 验证是否存在 setter 方法
- (void)judgeHasSetterMethodForKeyPath:(NSString *)keypath {
    Class superClass = object_getClass(self);
    SEL setterSelector = NSSelectorFromString([NSString stringWithFormat:@"set%@:", keypath.capitalizedString]);
    Method setterMethod = class_getInstanceMethod(superClass, setterSelector);
    if (!setterMethod) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"KVO - 没有当前%@的setter方法", keypath] userInfo:nil];
    }
}

#pragma mark - 动态生成子类
- (Class)createChildClassWithKeyPath:(NSString *)keyPath {
    
    // 获取原来的类名
    NSString *oldClassName = NSStringFromClass([self class]);
    // 拼接新类名
    NSString *newClassName = [NSString stringWithFormat:@"%@%@", kLCKVOPrefix, oldClassName];
    
    //获取派生类，如果存在直接返回
    Class newClass = NSClassFromString(newClassName);
    if (newClass) return newClass;
    
    //新建子类->申请 -> 注册 -> 添加方法
    newClass = objc_allocateClassPair([self class], newClassName.UTF8String, 0);
    objc_registerClassPair(newClass);
    
    SEL classSel = @selector(class);
    Method classMethod = class_getInstanceMethod([self class], classSel);
    const char *classType = method_getTypeEncoding(classMethod);
    class_addMethod(newClass, classSel, (IMP)lc_class, classType);
    
    SEL deallocSel = NSSelectorFromString(@"dealloc");
    Method deallocMethod = class_getInstanceMethod([self class], deallocSel);
    const char *deallocType = method_getTypeEncoding(deallocMethod);
    class_addMethod(newClass, deallocSel, (IMP)lc_dealloc, deallocType);
    
    return newClass;
}

#pragma mark -  动态调用类方法，返回调用方法的返回值
/**
 * @param methodName 方法名
 *
 * @param keyPath 观察属性
 */
- (BOOL)lc_performSelectorWithMethodName:(NSString *)methodName keyPath:(id)keyPath {

    if ([[self class] respondsToSelector:NSSelectorFromString(methodName)]) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        BOOL i = [[self class] performSelector:NSSelectorFromString(methodName) withObject:keyPath];
        return i;
#pragma clang diagnostic pop
    }
    return NO;
}

#pragma mark - 重写class方法，为了与系统类对外保持一致
Class lc_class(id self, SEL _cmd){
    //在外界调用class返回CJLPerson类
    return class_getSuperclass(object_getClass(self));//通过[self class]获取会造成死循环
}

void lc_dealloc(id self, SEL _cmd){
    Class superClass = [self class];
    object_setClass(self, superClass);
}

static void lc_setter(id self, SEL _cmd, id newValue) {
    NSLog(@"来了:%@",newValue);
    
    void (*lc_msgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
    struct objc_super superStruct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self)),
    };
    
    lc_msgSendSuper(&superStruct, _cmd, newValue);
    
    NSString *keyPath = getterForSetter(NSStringFromSelector(_cmd));
    NSMutableArray *mArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(kLCKVOAssociateKey));
    for (KVOInfo *info in mArray) {
        NSMutableDictionary<NSKeyValueChangeKey, id> *change = [NSMutableDictionary dictionaryWithCapacity:1];
        if ([info.keyPath isEqualToString:keyPath]) {
            
            if (info.options & NSKeyValueObservingOptionNew){
                [change setValue:newValue forKey:NSKeyValueChangeNewKey];
            }else {
                [change setValue:@"旧值" forKey:NSKeyValueChangeOldKey];
                [change setValue:newValue forKey:NSKeyValueChangeNewKey];
            }
            
            //消息发送
            if (info.observer && [info.observer respondsToSelector:@selector(lc_observeValueForKeyPath:ofObject:change:context:)]) {
                [info.observer lc_observeValueForKeyPath:info.keyPath ofObject:self change:change context:NULL];
            }
        }
    }
}

#pragma mark - 从set方法获取getter方法的名称 set<Key>:===> key
static NSString *getterForSetter(NSString *setter){
    
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) { return nil;}
    
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString *getter = [setter substringWithRange:range];
    NSString *firstString = [[getter substringToIndex:1] lowercaseString];
    return  [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
}

@end
