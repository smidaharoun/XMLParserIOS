	//
//  ViewController.m
//  XMLParser
//
//  Created by ODC on 22/07/16.
//  Copyright © 2016 ODC. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"


@interface ViewController ()
@property NSString * BaseURLString;
@property NSMutableDictionary *mdictXMLPart;   // current section being parsed
@property NSMutableString *mstrXMLString;
@property NSMutableArray *xmlResponse;          // completed parsed xml response

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _BaseURLString = @"http://www.oaca.nat.tn/newapp/hvdynt/xmlios.php?frmauth=permitauth&frmmvtCod=D&frmaeropVil=ORY&frmnumVol=&frmairport=tunis&frmhour=1&frmday=22&frmmonth=07&frmadjust=-1&frmacty=2016";
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:_BaseURLString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSXMLParser *XMLParser = (NSXMLParser *)responseObject;
        XMLParser.delegate = self;
        [XMLParser parse];
        NSLog(@"XML Response: %@", _xmlResponse);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.mdictXMLPart = [NSMutableDictionary dictionary];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"Vols"]) {
        _xmlResponse = [[NSMutableArray alloc] init];
    }
    
    if ([elementName isEqualToString:@"Vol"]) {
        _mdictXMLPart = [[NSMutableDictionary alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if (!_mstrXMLString) {
        _mstrXMLString = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [_mstrXMLString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"Aeroport"]
        || [elementName isEqualToString:@"Destination"]
        || [elementName isEqualToString:@"Heure"]
        || [elementName isEqualToString:@"Compagnie"]
        || [elementName isEqualToString:@"Num_Vol"]
        || [elementName isEqualToString:@"Commentaire"]) {
        NSString *cleanString = [_mstrXMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        cleanString = [cleanString substringFromIndex:4];
        [_mdictXMLPart setObject:cleanString forKey:elementName];
    }
    if ([elementName isEqualToString:@"Vol"]) {
        [_xmlResponse addObject:_mdictXMLPart];
    }
    _mstrXMLString = nil;
}




@end
