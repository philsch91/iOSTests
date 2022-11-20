//
//  ViewController.m
//  iOSTests
//
//  Created by Philipp Schunker on 27.02.22.
//

#import "ViewController.h"

@interface ViewController () {
    //NSProgress *memoryAllocationProgress;   // custom instance variable in class extension interface
}

//@property (nonatomic, retain, readwrite) NSProgress *memoryAllocationProgress;

@end

long gSize;
NSProgress *memoryAllocationProgress;

/**
 To change a variable via a function call, the function needs
 to have reference semantics with respect to the arguments.
 In C, it is not possible to pass pointers by reference,
 because C doesn't have native reference semantics.
 A smiliar feature can be used with addresses and pointers, by passing
 a pointer to the pointer.
 */
int malloc_completion(void **pptr) {
    if (*pptr == NULL) {
        return 1;
    }
    printf("ptr: %p\n", pptr);   // pointer to pointer
    printf("*ptr: %p\n", *pptr); // pointer value
    printf("**ptr: %ld\n", **(long**)pptr); // pointer value
    **(long**)pptr = 18;
    printf("**ptr: %ld\n", **(long**)pptr); // pointer value
    long base = pow(2, 10);     // 2^10 = 1024B = 1KB
    long progressBase = pow(2, 15); // 2^15 = 32768 = 32KB
    printf("gSize: %ld\n", gSize);
    printf("sizeof((long**)pptr): %ld B\n", sizeof((long**)pptr));
    gSize /= sizeof((long**)pptr);
    printf("gSize: %ld\n", gSize);
    for (long i = 0;i < gSize;i++) {
        //printf("i: %ld\n", i);
        *((long*)*pptr + i) = 18;
        if (i % base == 0) printf(".");
        if (i % progressBase == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [memoryAllocationProgress setCompletedUnitCount:i];
            });
        }
        usleep(2);
    }
    printf("\n");
    sleep(10);
    //free(*pptr);
    return 0;
}

void extended_malloc(size_t size, int (*callback)(void**)) {
    void *ptr = malloc(size);
    gSize = (long)size;
    int res = callback(&ptr);
    printf("%d\n", res);
    free(ptr);
}

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"iOSTests";
    self.view.backgroundColor = UIColor.whiteColor;

    self.memoryTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 96, 48)];
    self.memoryTextField.center = CGPointMake(self.view.center.x, self.view.center.y - self.memoryTextField.frame.size.height);
    self.memoryTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.memoryTextField.layer.borderColor = UIColor.grayColor.CGColor;
    self.memoryTextField.layer.cornerRadius = 5;
    self.memoryTextField.layer.borderWidth = 1;
    self.memoryTextField.textAlignment = NSTextAlignmentCenter;
    self.memoryTextField.adjustsFontSizeToFitWidth = YES;
    self.memoryTextField.placeholder = @"MegaByte";
    self.memoryTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.memoryTextField.delegate = self;
    [self.view addSubview:self.memoryTextField];

    self.memorybutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.memorybutton.frame = CGRectMake(0, 0, 96, 48);
    self.memorybutton.center = self.view.center;
    [self.memorybutton setTitle:@"Allocate" forState:UIControlStateNormal];
    [self.memorybutton addTarget:self action:@selector(button:event:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.memorybutton];

    self.memoryAllocationProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.memoryAllocationProgressView.frame = CGRectMake(0, 0, self.view.frame.size.width / 2, 0);
    NSLog(@"memoryAllocationProgressView.frame.size.height: %f", self.memoryAllocationProgressView.frame.size.height);
    self.memoryAllocationProgressView.center = CGPointMake(self.view.center.x, self.memorybutton.center.y + self.memoryAllocationProgressView.frame.size.height * 10);
    [self.view addSubview:self.memoryAllocationProgressView];
}

- (void)button:(UIButton *)button event:(UIEvent *)event {
    NSLog(@"%@", button);
    NSLog(@"%@", event);
    float fsize = [self.memoryTextField.text floatValue];
    NSString *memorySize = [NSString stringWithFormat:@"%.2f", fsize];
    fsize = [memorySize floatValue];
    NSLog(@"fsize: %.2f MB", fsize);
    long size = (long)(fsize * pow(2, 20)); // 1024 * 1024 = 2^20
    NSLog(@"size: %ld B", size);

    long progressTotalUnitCount = (size / sizeof(long));
    NSLog(@"progressTotalUnitCount: %ld", progressTotalUnitCount);
    memoryAllocationProgress = [NSProgress progressWithTotalUnitCount:progressTotalUnitCount];
    self.memoryAllocationProgressView.observedProgress = memoryAllocationProgress;

    dispatch_queue_global_t dispatchQueueGlobalDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueueGlobalDefault, ^{
        extended_malloc(size, malloc_completion);
    });
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
