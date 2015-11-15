//
//  ViewController.m
//  Piece
//
//  Created by 金小平 on 15/11/4.
//  Copyright © 2015年 金小平. All rights reserved.
//

#import "ViewController.h"
#import "SimpleHttp.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation ViewController

- (IBAction)unwindToHome:(UIStoryboardSegue *)segue
{
    
}

- (IBAction)login:(id)sender
{
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    
    
    [SimpleHttp requestLogin:username withPassword:password responseBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (dict[@"error"]) {
                NSLog(@"dictionary error : %@", dict[@"error"]);
            } else {
                NSLog(@"%@", dict[@"username"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"noteReview" sender:self];
                });
                
            }
        } else {
            NSLog(@"error : %@", error);
        }
    }];
    
}


@end
