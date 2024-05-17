@IsTest
public class TestRemoveHtmlTags {
    
    // Test method for normal input with HTML tags
    @IsTest
    static void testTextConversionToPlainText() {
        // Prepare test data
        List<String> richTextList = new List<String>{
            '<p>Hello, <b>world</b>! This is <i>test</i> content.</p>'
                };
                    
                    // Expected output
                    List<String> expectedPlainTextList = new List<String>{
                        'Hello, world! This is test content.'
                            };
                                
                                // Test
                                Test.startTest();
        List<String> actualPlainTextList = RemoveHtmlTags.TextconversionToPlaintext(richTextList);
        Test.stopTest();
        
        // Assert
        System.assertEquals(expectedPlainTextList, actualPlainTextList, 'The HTML tags were not removed correctly.');
    }
    
    // Test method for input with no HTML tags
    @IsTest
    static void testPlainTextInput() {
        List<String> richTextList = new List<String>{
            'Just plain text with new line characters.'
                };
                    
                    List<String> expectedPlainTextList = new List<String>{
                        'Just plain text with new line characters.'
                            };
                                
                                Test.startTest();
        List<String> actualPlainTextList = RemoveHtmlTags.TextconversionToPlaintext(richTextList);
        Test.stopTest();
        
        System.assertEquals(expectedPlainTextList, actualPlainTextList, 'The plain text should remain unchanged.');
    }
    
    // Test method for empty string input
    @IsTest
    static void testEmptyStringInput() {
        List<String> richTextList = new List<String>{
            ''
                };
                    
                    List<String> expectedPlainTextList = new List<String>{
                        ''
                            };
                                
                                Test.startTest();
        List<String> actualPlainTextList = RemoveHtmlTags.TextconversionToPlaintext(richTextList);
        Test.stopTest();
        
        System.assertEquals(expectedPlainTextList, actualPlainTextList, 'The output should be an empty string.');
    }
    
   
   
    
}