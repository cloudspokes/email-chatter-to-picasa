public with sharing class PicasaChatter {

    public void SendEmail(FeedItem f, String description, String emailAddr, String keyword, Boolean AllowAlbumLoad){
        
        if(description <> null && description.toLowerCase().contains(keyword.toLowerCase())){                    
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //Set email address
            String[] toAddresses = new String[] {emailAddr};
            mail.setToAddresses(toAddresses);
            mail.setReplyTo('noreply@salesforce.com'); //the reply address doesn't matter
            
            //get the description string and set it to lowercase, we are making this case insensitive
            String lowerDesc = description.toLowerCase();
            
            //Check if the description contains the keyword
            if(lowerDesc.contains(keyword.toLowerCase()+':') && AllowAlbumLoad){
                        
                //figure out where the keyword is
                Integer tagLocation = lowerDesc.indexOf(keyword.toLowerCase()+':');
                        
                //get the remainder of the description string after the keyword
                String album = lowerDesc.substring(tagLocation+keyword.length()+1);

                //if the string is longer than 3 then there is a chance that there is an album
                //name inside of [], check to see if one exists
                if(album.length() > 3){
                    if(album.contains('[') 
                       && album.contains(']')
                       && album.indexOf(']')-album.indexOf('[')>1){
                                  
                          //if we found an album name, set the subject of the email to that album
                          mail.setSubject(album.substring(album.indexOf('[')+1,album.indexOf(']')));
                    }
                }
            }else{
                //if no album name was found, then just set the subject to the feedItem title.
                mail.setSubject(f.Title);
            }
                                                            
            mail.setBccSender(false);  //we don't want to Bcc ourselves on this
            mail.setPlainTextBody('Body Text - This will not be utilized, picasa will not use it.');
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); //create the attachment
            efa.setBody(f.ContentData); //set the body of the attachment to the Content Data
            efa.setFileName(f.ContentFileName); //set the file name appropriately
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});  //attach to the email
            if (!Test.isRunningTest())
              Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); //send the email               
        }
    }  
}