//
//  Note+Create.m
//  NotePad
//
//  Created by Thomas Traylor on 5/12/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
//

#import "Note+Create.h"

@implementation Note (Create)

+ (Note*)noteWithText:(NSString*)text inManagedObjectContext:(NSManagedObjectContext*)context
{
    Note *note = nil;
    note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
    
    note.text = text;
    note.timeStamp = [NSDate date];
    
    NSError *saveError;
    [context save:&saveError];
    if(saveError)
    {
        NSLog(@"[%@ %@] Error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [saveError localizedDescription]);
    }

    return note;
    
}

@end
