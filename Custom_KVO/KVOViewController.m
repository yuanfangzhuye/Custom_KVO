//
//  KVOViewController.m
//  Custom_KVO
//
//  Created by lab team on 2021/5/20.
//

#import "KVOViewController.h"
#import "NSObject+KVO.h"
#import "LCKVOModel.h"

@interface KVOViewController ()

@property (nonatomic, strong) LCKVOModel *person;

@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
    self.person = [[LCKVOModel alloc] init];
    self.person.name = @"哈哈";
    [self.person lc_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.person.name = [NSString stringWithFormat:@"%@$", self.person.name];
}

- (void)lc_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;{
    NSLog(@"%@", change);
}

- (void)dealloc
{
    NSLog(@"vc 走了");
    [self.person removeObserver:self forKeyPath:@"name"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
