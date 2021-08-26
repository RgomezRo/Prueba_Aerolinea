public class RAUL_ProductsApprovalService {
    
    public static void sendToApproveProvidersProducts(List<Product2> products){
        RecordType providerProductRT = [SELECT Id FROM Recordtype 
                                        WHERE SobjectType = 'Product2'
                                        AND Name ='Producto Proveedor Externo'];
        
        List<Product2> productsToApprove = new List<Product2>();
        for(Product2 prod:products){
            if(prod.RecordTypeId==providerProductRT.Id){
                productsToApprove.add(prod);
            }
        }
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for (Product2 prod: productsToApprove) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval ');
            req1.setObjectId(prod.Id);
            requests.add(req1);
        }
        
        
        Approval.ProcessResult[] processResults = null;
        
        processResults = Approval.process(requests, true);
    }
}