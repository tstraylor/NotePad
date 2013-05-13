//
//  Note+Create.h
//  NotePad
//
//  Created by Thomas Traylor on 5/12/13.
//  Copyright (c) 2013 Thomas Traylor. All rights reserved.
//

#import "Note.h"

@interface Note (Create)

+ (Note*)noteWithText:(NSString*)text inManagedObjectContext:(NSManagedObjectContext*)context;

@end
