public class FlowUtil {
	//Generic Invocable method
    @InvocableMethod(label='Invoke ApexDML')
    public static List<FlowOutputs> doObjectDMLOperation(List<FlowInputs> request) {
        String resp = request[0].ObjectType+' Record Got Inserted Successfully';//Default response
        FlowOutputs out = new FlowOutputs();//Initialize response wrapper class
        //Get all sObjects from multiple requests   
        List<sObject> completesObjlist = new List<sObject>(); 
        List<FlowOutputs> output = new List<FlowOutputs>();
        for(FlowInputs inputs :request ){
            completesObjlist.addAll(inputs.sobjs);
        }
        if (completesObjlist.size()> 0){            
            System.debug(completesObjlist);            
            if (request[0].operatonType == 'INSERT'){
                Database.SaveResult[] results = Database.insert(completesObjlist, false);
                ExceptionUtil.publishException(request[0].ObjectType,'FlowException',results );
                for(Database.SaveResult res : results){
                    if(!res.isSuccess()){
                       resp = 'Record Creation Failed. Please see details in Exception Record.'; 
                    }
                    else{
                        resp = request[0].ObjectType+' Record Got Inserted Successfully';
                    }
                    FlowOutputs outstr = new FlowOutputs();
                    outstr.DMLResult = resp;
                    output.add(outstr);
                }
            }                               
        }
        else {
            return null;
        }        
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
