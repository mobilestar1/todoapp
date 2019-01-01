//
//  TodoViewController.m
//  FireList
//
//  Created by Developer on 2/7/15.
//  Copyright (c) 2015 JDare. All rights reserved.
//

#import "TodoViewController.h"
@import Firebase;
#import "AppDelegate.h"
#import "SwipeableCell.h"
#import "EditTodoViewController.h"

#define kCellIdentifier @"todoCell"


@interface TodoViewController () <SwipeableCellDelegate> {
    NSMutableArray *todoList;
    FIRDatabaseReference *todosRef;
    AppDelegate *appDelegate;
    NSManagedObjectContext *context;
}
@property (nonatomic, strong) NSMutableArray *cellsCurrentlyEditing;
@end

@implementation TodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performTask) name:@"appTerminated" object:nil];

    NSLog(@"Init Firebase");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.cellsCurrentlyEditing = [NSMutableArray array];
    
    todoList = [[NSMutableArray alloc] init];
    //NSMutableArray *saveAry = [[NSMutableArray alloc] init];
    
    // Create a reference to a Firebase location
    // since I can connect from multiple devices, we store each connection instance separately
    // any time that connectionsRef's value is null (i.e. has no children) I am offline
    FIRDatabaseReference *myConnectionsRef = [[FIRDatabase database] referenceWithPath:@"users/morgan/connections"];
    
    // stores the timestamp of my last disconnect (the last time I was seen online)
    FIRDatabaseReference *lastOnlineRef = [[FIRDatabase database] referenceWithPath:@"users/morgan/lastOnline"];
    
    FIRDatabaseReference *connectedRef = [[FIRDatabase database] referenceWithPath:@".info/connected"];
    [connectedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if([snapshot.value boolValue]) {
            // connection established (or I've reconnected after a loss of connection)
            
            // add this device to my connections list
            FIRDatabaseReference *con = [myConnectionsRef childByAutoId];
            
            // when this device disconnects, remove it
            [con onDisconnectRemoveValue];
            
            // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
            // where you set the user's presence to true and the client disconnects before the
            // onDisconnect() operation takes effect, leaving a ghost user.
            
            // this value could contain info about the device or a timestamp instead of just true
            [con setValue:@YES];
            
            
            // when I disconnect, update the last time I was seen online
            [lastOnlineRef onDisconnectSetValue:[FIRServerValue timestamp]];
        } else {
            NSArray *savedTodoList = [userDefaults objectForKey:@"todoList"];
            [self->todoList removeAllObjects];
            for (NSDictionary *dic in savedTodoList) {
                TodoItem *saveTodo = [[TodoItem alloc] initWithKey:[dic valueForKey:@"text"] key:[dic valueForKey:@"key"]];
                [self->todoList addObject:saveTodo];
            }
            [self.tableView reloadData];
        }
    }];

    
    todosRef = [[FIRDatabase database] referenceWithPath:@"todos"];
    [todosRef keepSynced:YES];
    
    [todosRef observeEventType:FIRDataEventTypeValue
     withBlock:^(FIRDataSnapshot *snapshot) {
         // Loop over children
         [self->todoList removeAllObjects];
         NSEnumerator *children = [snapshot children];
         FIRDataSnapshot *child;
         while (child = [children nextObject]) {
             NSDictionary *todo = child.value;
             
             NSDate *createdAt = [NSDate dateWithTimeIntervalSince1970:[todo[@"created_at"] doubleValue]];
             
             TodoItem *item = [[TodoItem alloc]initWithText:todo[@"text"] createdAt:createdAt];
             item.key = child.key;
             [self->todoList addObject:item];
         }
         self->todoList = [NSMutableArray arrayWithArray:[self->todoList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
             NSDate *first = [(TodoItem*)obj1 createdAt];
             NSDate *second = [(TodoItem*)obj2 createdAt];
             return [second compare:first];
         }]];

         [self.tableView reloadData];
     }];

    

    self.tableView.allowsSelection = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) performTask {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *saveAry = [NSMutableArray array];
    for (NSDictionary *dic in self->todoList) {
        NSDictionary *saveTodo = @{@"text": [dic valueForKey:@"text"], @"key" : [dic valueForKey:@"key"]};
        [saveAry addObject:saveTodo];
    }
    
    [userDefaults setObject:saveAry forKey:@"todoList"];
    [userDefaults synchronize];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [todoList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    TodoItem *todo = [todoList objectAtIndex: [indexPath row]];
    // Configure the cell...
    cell.itemText = todo.text;
    cell.delegate = self;
    
    if ([self.cellsCurrentlyEditing containsObject:indexPath]) {
        [cell openCell];
    }
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"EditTodoSegue"]) {
        EditTodoViewController *vc = (EditTodoViewController *)[segue.destinationViewController topViewController];
        vc.delegate = self;
    }
    
    
}

#pragma mark - SwipeableCellDelegate
- (void)delBtnClicked:(UITableViewCell *)mycell
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation" message:@"Do you really want to delete this todo?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
     {
         NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:mycell];
         TodoItem *todo = [self->todoList objectAtIndex: [currentEditingIndexPath row]];
         FIRDatabaseReference *reference;
         reference = [self->todosRef child:todo.key];
         
         [reference removeValue];
     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)editBtnClicked:(UITableViewCell *)mycell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:mycell];
    TodoItem *todo = [todoList objectAtIndex: [currentEditingIndexPath row]];
    
    
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EditTodoViewController* myVC = [sb instantiateViewControllerWithIdentifier:@"EditTodoViewController"];
    myVC.todo = todo;
    myVC.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:myVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];

}

- (void)saveUpdatedTodoItem:(TodoItem *)todo {
    FIRDatabaseReference *connectedRef = [[FIRDatabase database] referenceWithPath:@".info/connected"];
    [connectedRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        if([snapshot.value boolValue]) {
            FIRDatabaseReference *reference;
            if (todo.key == nil)
            {
                reference = [self->todosRef childByAutoId];
            } else {
                reference = [self->todosRef child:todo.key];
            }
            [reference setValue: [todo asDict]];
        } else {
            if (todo.key == nil)
            {
                [self->todoList insertObject:todo atIndex:[self->todoList count]];
                [self.tableView reloadData];
            } else {
                NSUInteger i = 0;
                for (NSDictionary *dic in self->todoList) {
                    if ([dic valueForKey:@"key"] == todo.key) {
                        break;
                    }
                    i++;
                }
                [self->todoList removeObjectAtIndex:i];
                [self->todoList addObject:todo];
                [self.tableView reloadData];
            }
        }
    }];
    
}

- (void)cellDidOpen:(UITableViewCell *)cell
{
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
}

- (void)cellDidClose:(UITableViewCell *)cell
{
    [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}


@end

