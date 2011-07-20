@isTest


Private class PicasaFeedItemTest{

    static testMethod void testPicasa(){
    
        //Create two Picasa Custom Settings records with different keywords
        picasa__c p = new picasa__c(Name='MyPicasaTestCustomSetting',keyword__c='[mypicasakeyword]',Active__c=true,Picasa_Email_Address__c='someone@email.com',Allow_Album_Loading__c = true);
        insert p;
        picasa__c q = new picasa__c(Name='My2ndPicasaTestCustomSetting',keyword__c='[my2ndpicasakeyword]',Active__c=true,Picasa_Email_Address__c='someoneelse@email.com');
        insert q;
        
        //Crate and account
        Account a = new Account(Name='Test Account');
        insert a;
        
        //Create some blob data that "Mimics" image data
        List<Blob> bloblist = new List<Blob>();
        for(Integer i=1000; i<1003; i++){
            bloblist.add(Blob.valueof('i'));
        }
        
        //Create a list of the file types we are checking for
        List<String> fileTypeList = new List<String>();
        fileTypeList.add('jpg');
        fileTypeList.add('gif');
        fileTypeList.add('png');
        
        //Create 2 feeditems with "images" and keywords for the first account with a specific album
        List<FeedItem> lfi = new List<FeedItem>();
        for(integer i=1; i<=2; i++){
            lfi.add( new FeedItem(ParentId=a.id,
                                  Title='This is subject ' + i,
                                  ContentData=bloblist[i-1],
                                  ContentDescription='[mypicasakeyword]:[Some Album]',
                                  ContentFileName='test.'+fileTypeList[i-1])
              
            );
        }
        //Create 1 more feeditem with "images" and keywords for the second account, but no album
        lfi.add( new FeedItem(ParentId=a.id,
                              Title='This is subject ' + 3,
                              ContentData=bloblist[2],
                              ContentDescription='[my2ndpicasakeyword]',
                              ContentFileName='test.'+fileTypeList[2])
          
        );
        
        //insert the FeedItems which will set off our trigger.
        insert lfi;
        
        //Now create some comments and insert them
        List<FeedComment> fcList = new List<FeedComment>();
        for(integer i=0; i<3; i++){
            FeedComment f = new FeedComment();
            f.FeedItemId = lfi[i].id;
            fcList.add(f);
        }
        fcList[0].CommentBody = '[mypicasakeyword]';
        fcList[1].CommentBody = '[mypicasakeyword]:[album]';
        fcList[2].CommentBody = '[my2ndpicasakeyword]';
        
        insert fcList;
    }

}