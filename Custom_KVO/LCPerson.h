//
//  LCPerson.h
//  Custom_KVO
//
//  Created by lab team on 2021/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCPerson : NSObject
//{
//  @public NSInteger _age;
//}
//@property (nonatomic, assign) NSInteger count;
//
//- (void)setNewAge:(NSInteger)age;

@property (nonatomic, copy) NSString *downloadProgress;
@property (nonatomic, assign) double writedData;
@property (nonatomic, assign) double totalData;

@end

NS_ASSUME_NONNULL_END
