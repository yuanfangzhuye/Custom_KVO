//
//  ViewController.m
//  Custom_KVO
//
//  Created by lab team on 2021/5/19.
//

#import "ViewController.h"
#import "LCPerson.h"
#import <objc/runtime.h>
#import "KVOViewController.h"

static void *countContext = &countContext;

@interface ViewController ()

@property (nonatomic, strong) LCPerson *person;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.person = [[LCPerson alloc] init];
    self.person.writedData = 10;
    self.person.totalData = 100;
//    self.person.count = 0;
    [self.person addObserver:self forKeyPath:@"downloadProgress" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:countContext];
//    [self printSubClass:self.person.class];
//    [self printClassAllMethod:NSClassFromString(@"NSKVONotifying_LCPerson")];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 200, 100, 100);
    [self.view addSubview:btn];

    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == countContext) {
//        NSInteger newCount = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
//        NSInteger oldCount = [[change valueForKey:NSKeyValueChangeOldKey] integerValue];
//
//        NSLog(@"%ld -- %ld", (long)newCount, (long)oldCount);
        NSLog(@"%@ - %@", [change valueForKey:NSKeyValueChangeNewKey], [change valueForKey:NSKeyValueChangeOldKey]);
    }
}

- (void)btnClick {
    NSLog(@"%s", __func__);
//    [self.person removeObserver:self forKeyPath:@"count" context:countContext];
//    [self printSubClass:self.person.class];
    
    KVOViewController *vc = [[KVOViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

// 输出所有子类
- (void)printSubClass:(Class)cls {
    int count = objc_getClassList(NULL, 0);
    NSMutableArray *mArray = [NSMutableArray arrayWithObject:cls];
    Class *classes = (Class *)malloc(sizeof(Class) * count);
    objc_getClassList(classes, count);
    for (int i = 0; i < count; i++) {
        if (cls == class_getSuperclass(classes[i])) {
            [mArray addObject:classes[i]];
        }
    }
    
    free(classes);
    NSLog(@"%@", mArray);
}

// 打印所有方法
- (void)printClassAllMethod:(Class)cls {
    unsigned int count;
    Method *methodList = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"method(%d) : %@", i, NSStringFromSelector(method_getName(method)));
    }
    free(methodList);
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    self.person->age += 1;
//    [self.person setNewAge:10];
    self.person.writedData += 10;
    self.person.totalData += 1;
//    self.person.count += 1;
}


@end
