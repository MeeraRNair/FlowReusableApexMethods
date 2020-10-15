public class FlowUtil {
	//Generic Invocable method
    @InvocableMethod(label='Invoke ApexDML')
    public static List<FlowOutputs> doObjectDMLOperation(List<FlowInputs> request) {
        String resp = request[0].ObjectType+' Record Got Inserted Successfully';//Default response
        FlowOutputs out = new FlowOutputs();//Initialize response wrapper class
        if (request[0].sobjs != null){            
            System.debug(request[0].sobjs);
            if (request[0].operatonType == 'INSERT'){
                Database.SaveResult[] results = Database.insert(request[0].sobjs, false);
                ExceptionUtil.publishException(request[0].ObjectType,'FlowException',results );
                for(Database.SaveResult res : results){
                    if(!res.isSuccess()){
                       resp = 'Record Creation Failed. Please see details in Exception Record.'; 
                    }
                }
            }
            out.DMLResult = resp;                    
        }
        else {
            out.DMLResult = 'No Valid Data';
        }
        System.debug('out:'+out);
        return new List<FlowOutputs>{out};
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