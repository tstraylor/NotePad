//
//  MasterViewController.m
//  NotePad
//
//  Created by Thomas Traylor on 5/9/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Note.h"

@interface MasterViewController ()

@property (strong, nonatomic) NSFetchedResultsController *searchedResultsController;

- (void)handleOrientationChangeNotification:(NSNotification *)notification;
- (void)notepadTitle;
- (NSUInteger)titleLength;
- (void)configureCell:(UITableViewCell *)cell forNote:(Note *)note;
- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate;

@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize searchedResultsController = _searchedResultsController;

#pragma mark - Device Orientation Change Notification

- (void)handleOrientationChangeNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - NotePad Title

- (void)notepadTitle
{
    NSFetchedResultsController *fetched = nil;
    
    if([self.searchDisplayController isActive])
        fetched = self.fetchedResultsController;
    else
        fetched = self.searchedResultsController;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [fetched sections][0];
    if([sectionInfo numberOfObjects] > 0)
        self.title = [NSString stringWithFormat:@"NotePad (%d)", [sectionInfo numberOfObjects]];
    else
        self.title = @"NotePad";
}

#pragma mark - ViewController Lifecycle

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    // Do any additional setup after loading the view, typically from a nib.
    
    [self notepadTitle];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    if(self.splitViewController)
        self.detailViewController.managedObjectContext = self.managedObjectContext;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    //if(self.splitViewController)
        [self.tableView reloadData];
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOrientationChangeNotification:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
    //                      atScrollPosition:UITableViewScrollPositionTop
    //                              animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
    //                      atScrollPosition:UITableViewScrollPositionTop
    //                              animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

// get the number of sections in the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSFetchedResultsController *fetched = nil;
    
    if(tableView == self.tableView)
        fetched = self.fetchedResultsController;
    else
        fetched = self.searchedResultsController;
    
    return [[fetched sections] count];
}

// get the number of rows in the table view section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSFetchedResultsController *fetched = nil;
    
    if(tableView == self.tableView)
        fetched = self.fetchedResultsController;
    else
        fetched = self.searchedResultsController;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetched sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NoteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    // get the right fetch controller
    NSFetchedResultsController *fetched = nil;
    if(tableView == self.tableView)
        fetched = self.fetchedResultsController;
    else
        fetched = self.searchedResultsController;

    // configure the cell
    Note *note = [fetched objectAtIndexPath:indexPath];
    [self configureCell:cell forNote:note];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSFetchedResultsController *fetched = nil;
        if(tableView == self.tableView)
            fetched = self.fetchedResultsController;
        else
            fetched = self.searchedResultsController;
        
        NSManagedObjectContext *context = [fetched managedObjectContext];
        [context deleteObject:[fetched objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application,
            // although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.splitViewController)
    {
        NSFetchedResultsController *fetched = nil;
        if(tableView == self.tableView)
            fetched = self.fetchedResultsController;
        else
            fetched = self.searchedResultsController;
        
        Note *note = [fetched objectAtIndexPath:indexPath];
        self.detailViewController.note = note;
    }
    else
    {
        // we only want to do this if the user is doing a search
        if(tableView == self.searchDisplayController.searchResultsTableView)
            [self performSegueWithIdentifier:@"showNote" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if([[segue identifier] isEqualToString:@"showNote"])
    {
        NSLog(@"[%@ %@] showNote", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
        NSFetchedResultsController *fetched = nil;
        NSIndexPath *indexPath = nil;
        if([self.searchDisplayController isActive])
        {
            fetched = self.searchedResultsController;
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        }
        else
        {
            fetched = self.fetchedResultsController;
            indexPath = [self.tableView indexPathForSelectedRow];
        }
        
        Note *note = [fetched objectAtIndexPath:indexPath];
        [[segue destinationViewController] setNote:note];
    }
    else if([[segue identifier] isEqualToString:@"addNote"])
    {
        NSLog(@"[%@ %@] addNote", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller


- (NSFetchedResultsController *)fetchedResultsControllerWithPredicate:(NSPredicate *)predicate
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // set the search predicate
    [fetchRequest setPredicate:predicate];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // cache
    NSString *cacheName = @"Master";
    if( predicate ) cacheName = nil;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil
                                                                                                           cacheName:cacheName];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although
        // it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;

}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController)
    {
        return _fetchedResultsController;
    }
    
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    return _fetchedResultsController;
    
}

- (NSFetchedResultsController *)searchedResultsController
{
    if( _searchedResultsController )
    {
        return _searchedResultsController;
    }
    
    self.searchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    return _searchedResultsController;
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{

    UITableView *tableView = nil;
    
    if(controller == self.fetchedResultsController)
        tableView = self.tableView;
    else
        tableView = self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                     withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = nil;
    
    if(controller == self.fetchedResultsController)
        tableView = self.tableView;
    else
        tableView = self.searchDisplayController.searchResultsTableView;
    
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
        {
            Note *note = [controller objectAtIndexPath:indexPath];
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forNote:note];

        }
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = nil;
    if(controller == self.fetchedResultsController)
        tableView = self.tableView;
    else
        tableView = self.searchDisplayController.searchResultsTableView;
    
    [tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = nil;
    if(controller == self.fetchedResultsController)
        tableView = self.tableView;
    else
        tableView = self.searchDisplayController.searchResultsTableView;
    
    [self notepadTitle];
    [tableView endUpdates];
}

// configure the note table view cell
- (void)configureCell:(UITableViewCell *)cell forNote:(Note *)note
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm"];
    NSRange cr = [note.text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
    
    if(cr.length != NSNotFound)
    {
        if(cr.location > [self titleLength])
        {
            NSUInteger len = MIN([note.text length], [self titleLength]);
            NSRange range = NSMakeRange(0, len);
            cell.textLabel.text = [NSString stringWithFormat:@"%@...",[note.text substringWithRange:range]];
        }
        else
        {
            NSRange range = NSMakeRange(0, cr.location);
            cell.textLabel.text = [note.text substringWithRange:range];
        }
    }
    else
    {
        NSUInteger len = MIN([note.text length], [self titleLength]);
        NSRange range = NSMakeRange(0, len);
        cell.textLabel.text = [NSString stringWithFormat:@"%@...",[note.text substringWithRange:range]];
        
        
        NSLog(@"[%@ %@] label: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), cell.textLabel.text);
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:note.timeStamp];
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:14.0];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
}

#pragma mark - Add Note

- (IBAction)addNoteButtonPressed:(UIBarButtonItem *)sender
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    if(self.splitViewController)
    {
        [self.detailViewController setManagedObjectContext:self.managedObjectContext];
    }
    else
    {
        [self performSegueWithIdentifier:@"addNote" sender:self];
    }
}

#pragma mark - Title Length Method

- (NSUInteger)titleLength
{
    // default table view title length
    NSUInteger titleLen = 24;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        titleLen = 24;
    }
    else
    {
        // if we are a phone and turned landscape we want to give the user a bit more
        // title info
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationIsLandscape(orientation))
            titleLen = 36;
    }
    
    return titleLen;
}

#pragma mark - UISearchDisplayDelegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{

    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"text contains[cd] %@", searchString];
    self.searchedResultsController = [self fetchedResultsControllerWithPredicate:searchPredicate];

    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.searchedResultsController.delegate = nil;
    self.searchedResultsController = nil;
    [controller.searchResultsTableView reloadData];
    
    // Scroll to top
    //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
   //                       atScrollPosition:UITableViewScrollPositionTop
     //                             animated:YES];
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //self.searchedResultsController = nil;
}
@end
