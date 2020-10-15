public class ExceptionUtil {
	public class MyException extends Exception {}
	 @InvocableMethod(label='Invoke ExceptionUtil')
    public static void throwcustomException(List<String> excmessage){
       
            throw new MyException('An internal exception happened during current operation.'+ 
                                  'Please contact system administrator with this exception details:'+excmessage[0]);
        
    }
    //Log Single Exception
    public static void logException(String objname, String processname, String recordID, String exceptiondetails){
        Exception__c exc = new Exception__c();
        exc.Object__c = objname;
        exc.Operation__c = processname;
        exc.Exception_Details__c = exceptiondetails;
        exc.Record_ID__c = recordID;
        insert exc;
    }
    
    //Log Exceptions
    public static void logException(String objname, String processname, List<Database.SaveResult> listSaveResult){
        System.debug(listSaveResult);
        List<Exception__c> exclist = new List<Exception__c>();
        Exception__c exc;
        for(Database.SaveResult res : listSaveResult){
            if(!res.isSuccess()){
                exc = new Exception__c();
                exc.Object__c = objname;
        		exc.Operation__c = processname;
                String excdetail;
                 for(Database.Error err : res.getErrors()) {
                      excdetail+= err.getStatusCode()+':'+err.getMessage(); 
                     System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                    }
                String detail = new dmlException().getStackTraceString();
                exc.Exception_Details__c =excdetail+detail ;
                exc.Record_ID__c = res.getId();
                exclist.add(exc);
            }
        }
        if(exclist.size()>0){
            insert exclist;
        }
    }
    //publish event
    public static void publishException(String objname, String processname, String recordID, String exceptiondetails){
        Exception_Log__e pe = new Exception_Log__e();
        pe.Object__c = objname;
        pe.Operation__c = processname;
        pe.Exception_Details__c = exceptiondetails;
        pe.Record_ID__c = recordID;
        eventBus.publish(pe);
    }
    //publish Events
    public static void publishException(String objname, String processname, List<Database.SaveResult> listSaveResult){
       List<Exception_Log__e> pelist = new List<Exception_Log__e>();
        Exception_Log__e pe;
        for(Database.SaveResult res : listSaveResult){
            if(!res.isSuccess()){
                pe = new Exception_Log__e();
                pe.Object__c = objname;
        		pe.Operation__c = processname;
                String excdetail;
                 for(Database.Error err : res.getErrors()) {
                      excdetail+= err.getStatusCode()+':'+err.getMessage(); 
                     System.debug('Error returned: ' + err.getStatusCode() +' - ' + err.getMessage());
                    }
                String detail = new dmlException().getStackTraceString();
                pe.Exception_Details__c = excdetail+detail;
                System.debug(excdetail);
                //pe.Record_ID__c = res.getId();
                pelist.add(pe);
            }
        }
        if(pelist.size()>0){
            eventBus.publish(pelist);
        }
    }
}