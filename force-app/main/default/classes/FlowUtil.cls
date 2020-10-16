public class FlowUtil {
	//Generic Invocable method
    @InvocableMethod(label='Invoke ApexDML')
    public static List<FlowOutputs> doObjectDMLOperation(List<FlowInputs> request) {
        String resp_success = request[0].ObjectType+' Records Got Inserted Successfully';//Default response
         String resp_fail = request[0].ObjectType+' Records Got Failed';//Default response
        FlowOutputs out = new FlowOutputs();//Initialize response wrapper class
        //Get all sObjects from multiple requests   
        List<sObject> completesObjlist = new List<sObject>(); 
        List<FlowOutputs> output = new List<FlowOutputs>();
        //Store each flowinput object count for response processing
        Map<Integer,Integer> objcntList = new Map<Integer,Integer>();
        for(Integer flwcnt=0;flwcnt<request.size();flwcnt++){
            completesObjlist.addAll(request[flwcnt].sobjs);
            objcntList.put(flwcnt,request[flwcnt].sobjs.size());
        }
        if (completesObjlist.size()> 0){            
            System.debug(completesObjlist);            
            if (request[0].operatonType == 'INSERT'){
                Database.SaveResult[] results = Database.insert(completesObjlist, false);
                ExceptionUtil.publishException(request[0].ObjectType,'FlowException',results );
                Integer reqcnt=0;
                Integer reccount=0;
                for(Integer savcnt =0;savcnt<results.size();savcnt++){
                    reccount++;
                    //If processing result of same FlowInput and it is success
                    if(results[savcnt].isSuccess() && reccount<= objcntList.get(reqcnt)){
                        resp_success+=':'+results[savcnt].getId();                         
                    }
                    //If processing result of same FlowInput and it is failure
                    else if(!results[savcnt].isSuccess() && reccount<= objcntList.get(reqcnt)){
                        resp_fail+=':'+results[savcnt].getId(); 
                    }
                    //If we start to process next listitem of  FlowInputs
                    else if(reccount > objcntList.get(reqcnt) ){
                         FlowOutputs outstr = new FlowOutputs();
                         outstr.DMLResult = resp_success+';'+resp_fail;
                         output.add(outstr);
                        //reset all variables
                        if(results[savcnt].isSuccess()){
                             resp_success = request[0].ObjectType+' Records Got Inserted Successfully:'+results[savcnt].getId();
                             resp_fail = request[0].ObjectType+' Records Got Failed:';
                        }
                        else{
                             resp_success = request[0].ObjectType+' Records Got Inserted Successfully:';
                             resp_fail = request[0].ObjectType+' Records Got Failed:'+results[savcnt].getId();
                        }                        
                        reqcnt++;
                        reccount=1;
                    }
                } 
                //Add last listitem result
                 FlowOutputs outstr = new FlowOutputs();
              	 outstr.DMLResult = resp_success+';'+resp_fail;
                 output.add(outstr);           
               
            }                               
        }
        else {
            return null;
        } 
        System.debug('output:'+output);
        return output;
    }
    
    //Wrapper class to accept variables
    public class FlowInputs{
    
        @InvocableVariable
        public List<sObject> sobjs;
        
        @InvocableVariable
        public String operatonType;
        
         @InvocableVariable
        public String ObjectType;
        
    }
    //output details which goes from apex to flow
    public class FlowOutputs{       
               
        @InvocableVariable
        public String DMLResult;
    }
    
}
