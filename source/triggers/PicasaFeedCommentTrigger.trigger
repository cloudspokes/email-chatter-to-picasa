trigger PicasaFeedCommentTrigger on FeedComment (after insert) {
    
   //Get all of the custom settings for the Picasa Trigger.  There can be multiple albums with various keywords
    //Once we have the custom settings, loop through them and create a new map with the key being the email address
    //configured for the Picasa account.  The value in the map will be the custom setting.
    Map<String, picasa__c> picasa = picasa__c.getAll();
    Map<String, picasa__c> keywords = new Map<String, picasa__c>();
    for(String s: picasa.keySet()){
        if(picasa.get(s).Active__c){
            keywords.put(picasa.get(s).Keyword__c,picasa.get(s));
        }
    }
    
    //create a new instance of the PicasaChatter class
    PicasaChatter pc = new PicasaChatter();
    
    Set<ID> parents = new Set<ID>();
    Map<ID, String> commentMap = new Map<ID,String>();
    
    for(FeedComment f : trigger.new){
        if(f.ParentId <> null){ 
            parents.add(f.FeedItemId); 
            commentMap.put(f.FeedItemId, f.CommentBody);
        }
    }
    
    //Requery for the FeedItem data, there appears to be a bug where the data isn't always passed in the trigger
    List<FeedItem> fiList = [select Title, ContentType, ContentData, ContentFileName, ContentDescription FROM FeedItem where id IN :parents];
    
    //Loop through each of the FeedItems in the fiList (obviously there will usually only be 1
    //but we are writing this to handle bulk inserts of FeedItems as well). Check for the keywords
    //for each custom setting and if there is a match, then email the file to chatter.  Also, check
    //to see if the Album has been added after the keyword (syntax = keyword:[Album Name]) and apply
    //the correct subject.  The subject is used by picasa to either add captions to the photo, or if
    //it matches an album name, insert the picture into the correct picasa album
    for(FeedItem f : fiList){ 
        //check for the file extensions
        if(f.ContentType <> null && 
            ( f.ContentType == 'image/jpeg' || f.ContentFileName.toLowerCase().endsWith('jpg') || f.ContentFileName.toLowerCase().endsWith('jpeg') ||
              f.ContentType == 'image/gif'  || f.ContentFileName.toLowerCase().endsWith('gif') ||
              f.ContentType == 'image/png'  || f.ContentFileName.toLowerCase().endsWith('png') 
            )            
           )
           
         {
            //loop through each of the custom settings and test the description for the keywords, if found
            //create the email and attachment and send it to the picasa account in the custom setting
            for(String s: keywords.keySet()){
                
                //call the send mail method with the feeditem, the comment for that feeditem, the email
                //address, the keyword and whether to allow album loading
                pc.SendEmail(f, 
                             commentMap.get(f.id), 
                             keywords.get(s).Picasa_Email_Address__c, 
                             s, 
                             keywords.get(s).Allow_Album_Loading__c);
                
            }  
        }    
    }
}