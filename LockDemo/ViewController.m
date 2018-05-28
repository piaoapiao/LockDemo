//
//  ViewController.m
//  LockDemo
//
//  Created by guodong on 2018/5/28.
//  Copyright © 2018年 guodong. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

    @property (nonatomic, strong) NSConditionLock *conditionLock;
    @property (nonatomic, strong) NSLock *lock;
    @property (nonatomic, strong) NSRecursiveLock *recursiveLock;

    @property (nonatomic, assign) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
//    [self start];
    
//    [self lockStart];
    
//    [self recursiveLockStart];
    
    //[self blockLock];
    
//    [self semaphoreTest];
    
    //[self mutexTest];
    
    //[self  nslockTest];
    
//    [self conditionTest];
    
    //self.lock = [[NSLock alloc] init];
    self.lock = [[NSRecursiveLock alloc] init];
    int result = [self sumAdd:5];
    NSLog(@"result:%d",result);
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


//--递归锁场景说明
-(void)blockLock
{
//    NSLock *lock = [[NSLock alloc] init];
    
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
     
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
            static void (^RecursiveMethod)(int);
         
            RecursiveMethod = ^(int value) {
             
                    [lock lock];
                    if (value > 0) {
                 
                            NSLog(@"value = %d", value);
                            sleep(2);
                            RecursiveMethod(value - 1);
                        }
                    [lock unlock];
                };
         
            RecursiveMethod(5);
    });
    
    
}


- (void)start {
    self.conditionLock = [[NSConditionLock alloc] init];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(produce) object:nil];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(consume) object:nil];
    [thread1 start];
    [thread2 start];
}



- (void)produce {
    while (YES) {
//        NSLog(@"self.conditionLock.condition:%d",self.conditionLock.condition);
        [self.conditionLock lockWhenCondition:0];
        NSLog(@"produce");
        self.count++; // count
        NSLog(@"self.count:%d",self.count);
        [self.conditionLock unlockWithCondition:1];
    }
}

- (void)consume {
    while (YES) {
//        NSLog(@"consume.condition:%d",self.conditionLock.condition);
//        [self.conditionLock lockWhenCondition:1];
        
      //tryLock 可获取锁几率大些
//        [self.conditionLock tryLock];
        
        [self.conditionLock tryLockWhenCondition:1];
           NSLog(@"self.count:%d",self.count);
        
//        NSDate *data = [NSDate dateWithTimeIntervalSinceNow:1];
//
//       BOOL rs =   [self.conditionLock lockBeforeDate:data];
        
        NSLog(@"consume");
        NSLog(@"self.count:%d",self.count);
        self.count--;
        [self.conditionLock unlockWithCondition:0];
    }
}

-(void)lockStart
{
    self.lock = [[NSLock alloc] init];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(lockProduce) object:nil];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(lockConsume) object:nil];
    [thread1 start];
    [thread2 start];
    
}


- (void)lockProduce {
    while (YES) {
        //        NSLog(@"self.conditionLock.condition:%d",self.conditionLock.condition);
        [self.lock lock];
        NSLog(@"produce");
        self.count++; // count
        NSLog(@"self.count:%d",self.count);
        [self.lock unlock];
    }
}

- (void)lockConsume {
    while (YES) {
        [self.lock lock];
        NSLog(@"consume");
        self.count--;
        NSLog(@"self.count:%d",self.count);
        [self.lock unlock];
    }
}

-(void)recursiveLockStart
{
    self.recursiveLock = [[NSRecursiveLock alloc] init];
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(recursiveLockProduce) object:nil];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(recursiveLockConsume) object:nil];
    [thread1 start];
    [thread2 start];
}


- (void)recursiveLockProduce {
    while (YES) {
        //        NSLog(@"self.conditionLock.condition:%d",self.conditionLock.condition);
        [self.recursiveLock lock];
        NSLog(@"produce");
        self.count++; // count
        NSLog(@"self.count:%d",self.count);
        [self.recursiveLock unlock];
    }
}

- (void)recursiveLockConsume {
    while (YES) {
        [self.recursiveLock lock];
        NSLog(@"consume");
        self.count--;
        NSLog(@"self.count:%d",self.count);
        [self.recursiveLock unlock];
    }
}



- (void)executeLock {
    NSCondition* lock = [[NSCondition alloc] init];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSUInteger i=0; i<3; i++) {
            sleep(2);
            if (i == 2) {
                NSLog(@"here1");
                [lock lock];
//[lock signal];
                [lock unlock];
            }
            
        }
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        NSLog(@"here2");
        [self threadMethod:lock];
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        NSLog(@"here3");
        [self threadMethod:lock];
    });
    
    
}

-(void)threadMethod:(NSCondition*)lock{
    [lock lock];
    [lock wait];
    [lock unlock];
    
}


#pragma mark--semaphore 信号量测试
- (void)semaphoreTest{
    dispatch_semaphore_t lock =  dispatch_semaphore_create(5);
    int  count = 1000;

    for (int i = 0; i < count; i++) {
        dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        NSLog(@"dispatch_semaphore_wait:%d",i);
// dispatch_semaphore_signal(lock);
    }
}


#pragma mark--mutex 互斥测试
- (void)mutexTest
{
    pthread_mutex_t lock;
    pthread_mutex_init(&lock, NULL);
    int count = 100;
    for (int i = 0; i < count; i++) {
        pthread_mutex_lock(&lock);
        NSLog(@"mutex excuteing:%d",i);
        pthread_mutex_unlock(&lock);
    }
}

#pragma mark--lock 测试   sleep  也持有锁
-(void)nslockTest
{
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[lock lock];
            [lock lockBeforeDate:[NSDate date]];
            NSLog(@"需要线程同步的操作1 开始");
            sleep(4);
            NSLog(@"需要线程同步的操作1 结束");
            [lock unlock];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(1);
            if ([lock tryLock]) {//尝试获取锁，如果获取不到返回NO，不会阻塞该线程
                    NSLog(@"锁可用的操作");
                    [lock unlock];
                }else{
                        NSLog(@"锁不可用的操作");
                    }
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:3];
            if ([lock lockBeforeDate:date]) {//尝试在未来的3s内获取锁，并阻塞该线程，如果3s内获取不到恢复线程, 返回NO,不会阻塞该线程
                    NSLog(@"没有超时，获得锁");
                    [lock unlock];
                }else{
                        NSLog(@"超时，没有获得锁");
                    }
    });
}

-(void)conditionTest
{
    NSCondition *condition = [[NSCondition alloc] init];
    NSMutableArray *products = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [condition lock];
            if ([products count] == 0) {
                NSLog(@"wait for product");
                [condition wait];  //需要先 lock
            }
            [products removeObjectAtIndex:0];
            NSLog(@"custome a product");
            [condition unlock];
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            [condition lock];
            [products addObject:[[NSObject alloc] init]];
            NSLog(@"produce a product,总量:%zi",products.count);
            [condition signal];
            [condition unlock];
            sleep(1);
        }
    });
    
}

#pragma mark --递归锁

-(int)sumAdd:(int)count
{
    [self.lock lock];
    if(count == 0)
    {
        return 0;
    }
//    [self.lock lock];
    return  [self sumAdd:count - 1] + count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
