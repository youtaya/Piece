//
//  ContactViewController.m
//  Piece
//
//  Created by 金小平 on 16/1/10.
//  Copyright © 2016年 金小平. All rights reserved.
//

#import "ContactViewController.h"
#import "SimpleHttp.h"
@import Contacts;

@interface ContactViewController ()
@property (weak, nonatomic) IBOutlet UITableView *ContactList;

@end

@implementation ContactViewController

extern NSString *userId;
@synthesize list = _list;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContact];
    // Do any additional setup after loading the view.
    self.ContactList.delegate = self;
    self.ContactList.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *ResultTableView = [tableView dequeueReusableCellWithIdentifier:
                                        CellIdentifier];
    if (ResultTableView == nil) {
        ResultTableView = [[UITableViewCell alloc]
                           initWithStyle:UITableViewCellStyleDefault
                           reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    NSLog(@"row text: %@", [self.list objectAtIndex:row]);
    ResultTableView.textLabel.text = [self.list objectAtIndex:row];
    return ResultTableView;
}

#pragma mark - Contact Read
- (void)loadContact
{
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(granted) {
            NSLog(@"ok, permit");
        } else {
            NSLog(@"error in granted");
        }
    }];
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    NSError *fetchError;
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, CNContactPhoneNumbersKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
    
    BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
        [contacts addObject:contact];
    }];
    if (!success) {
        NSLog(@"error = %@", fetchError);
    }
    
    CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    for (CNContact *contact in contacts) {
        NSString *string = [formatter stringFromContact:contact];
        NSArray *phoneNumbs = contact.phoneNumbers;
        NSString *phoneValue;
        for (CNLabeledValue *labeledValue in phoneNumbs) {

            NSString *phoneLabel = labeledValue.label;
            
            CNPhoneNumber *phoneNumer = labeledValue.value;
            phoneValue = phoneNumer.stringValue;
            
            NSLog(@"phone=%@ %@", phoneLabel, phoneValue);
        }
        NSLog(@"contact = %@", string);
        NSDictionary *contactDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                             string, @"contact",
                                             phoneValue, @"number",
                                             nil];
        
        [contactList addObject:contactDictionary];
        
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:contactList options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [SimpleHttp contactSync:userId withContacts:jsonString responseBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"content is %@", dict[@"content"]);
            NSMutableArray *contactList = [[NSMutableArray alloc]init];
            for(NSDictionary *element in dict[@"content"]) {
                NSString *result = [element[@"fullName"] stringByAppendingString:
                                    [NSString stringWithFormat:@"%@",element[@"status"]]];
                [contactList addObject:result];
            }
            self.list = contactList;
            NSLog(@"content is %@", self.list);
            [self.ContactList reloadData];

        } else {
            NSLog(@"error : %@", error);
        }
    }];
    

}

@end