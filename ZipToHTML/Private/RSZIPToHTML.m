//
//  QLZip
//
//  Created by RichS on 7/14/14.
//  Copyright (c) 2014 RichS. All rights reserved.
//

#import "RSZIPToHTML.h"
#import <zipzap/zipzap.h>

@implementation RSZipToHTML

+(NSString*)htmlForItems:(NSString*)items {
    NSString* html = [NSString stringWithFormat:@" \
        <!DOCTYPE html> \
        <html> \
    \
            <head> \
                <link href=\"https://cdn.materialdesignicons.com/2.5.94/css/materialdesignicons.min.css\" rel=\"stylesheet\"> \
                <link href=\"https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900|Material+Icons\" rel=\"stylesheet\"> \
                <link href=\"https://cdn.jsdelivr.net/npm/vuetify/dist/vuetify.min.css\" rel=\"stylesheet\"> \
                <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui\"> \
            </head> \
    \
            <body> \
                <div id=\"app\"> \
                    <v-app> \
                        <v-content> \
                            <v-treeview v-model=\"tree\" :open=\"open\" :items=\"items\" activatable item-key=\"name\" open-on-click> \
                                <template v-slot:prepend=\"{ item, open }\"> \
                                    <v-icon v-if=\"!item.file\"> \
                                        {{ open ? 'mdi-folder-open' : 'mdi-folder' }} \
                                    </v-icon> \
                                    <v-icon v-else> \
                                        {{ files[item.file] }} \
                                    </v-icon> \
                                </template> \
                            </v-treeview> \
                        </v-content> \
                    </v-app> \
                </div> \
    \
                <script src=\"https://cdn.jsdelivr.net/npm/vue/dist/vue.js\"></script> \
                <script src=\"https://cdn.jsdelivr.net/npm/vuetify/dist/vuetify.js\"></script> \
                <script> \
                      function isNullOrWhitespace( value) { \
                      if (value== null) return true; \
                      return value.replace(/\\s/g, '').length == 0; \
                      } \
                      \
                  function convertItems(items) { \
                    items = items.sort(function (a, b) { \
                        return a.name - b.name \
                    }); \
                  \
                    var tree = {}; \
                    items.forEach(function(item) { \
                        item.name = item.name.replace(/^[/]+/g, ''); \
                  \
                        var elements = item.name.split('/'); \
                        var file = elements.pop(); \
\
                      if (isNullOrWhitespace(file)) { \
                          return; \
                      } \
\
                  \
                        var treeElement = tree; \
                        elements.forEach(function(element) { \
                            if (treeElement[element] === undefined) { \
                                treeElement[element] = { \
                                    name: element, \
                                    children: {} \
                                } \
                            } \
                            treeElement = treeElement[element].children; \
                        }); \
                  \
                        treeElement[file] = { \
                            name: file + \" (Compressed: \" + item.compressedSize + \" bytes, Uncompressed: \" + item.uncompressedSize + \" bytes)\", \
                            file: file.replace(/^.*[.]/g, ''), \
                            compressedSize: item.compressedSize, \
                            uncompressedSize: item.uncompressedSize, \
                        }; \
                    }); \
                  \
                    tree = Object.values(tree); \
                    treeElement = tree; \
                    treeElement.forEach(function(element) { \
                        childrenToArray(element); \
                    }); \
                  \
                      return [{ name: 'ZIP Contents:', children: tree }]; \
                  } \
                  \
                  function childrenToArray(element) { \
                    if (element.children != undefined) { \
                      element.children = Object.values(element.children); \
                        element.children.forEach(function(child) { \
                            childrenToArray(child); \
                        }); \
                    } \
                  } \
                  function getItems() { \
                    return convertItems(%@); \
                  } \
    \
                    new Vue({ \
                        el: '#app', \
                        data: () => ({ \
                            open: ['ZIP Contents:'], \
                            \"open-all\": true, \
                            files: { \
                                html: 'mdi-language-html5', \
                                js: 'mdi-nodejs', \
                                json: 'mdi-json', \
                                md: 'mdi-markdown', \
                                pdf: 'mdi-file-pdf', \
                                png: 'mdi-file-image', \
                                txt: 'mdi-file-document-outline', \
                                xls: 'mdi-file-excel' \
                            }, \
                            tree: [], \
                            items: getItems() \
                        }) \
                      }); \
                </script> \
            </body> \
    \
        </html> \
    ", items];
    
    return html;
}

+(NSString*)arrayToJSON:(NSArray*)arrary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return [NSString stringWithFormat:@"<html><body>Error: %@</body></html>", error];
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

+(NSString*)htmlForZIP:(NSURL*)url {
    NSLog(@"FileURL: %@", url);
    NSMutableArray* items = [NSMutableArray array];
    NSError* error;
    ZZArchive* archive = [ZZArchive archiveWithURL:url error:&error];
    if ( nil != archive ) {
        for ( ZZArchiveEntry *entry in archive.entries ) {
            NSDictionary* details = @{
                                      @"name": entry.fileName,
                                      @"compressedSize": [NSNumber numberWithUnsignedLong:entry.compressedSize],
                                      @"uncompressedSize": [NSNumber numberWithUnsignedLong:entry.uncompressedSize]
                                      };
            [items addObject:details];
        }
        
        NSString* json = [self arrayToJSON:items];
        NSString* html = [self htmlForItems:json];
        return html;
    }
    
    if (error != nil) {
        return [NSString stringWithFormat:@"<html><body><h2>Error</h2><p>%@</p></body></html>", error];
    }
    
    return @"<html><body>Empty/Invalid ZIP</body></html>";
}

@end
