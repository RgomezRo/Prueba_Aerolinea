public class Product2TriggerHandler extends TriggerHandlerBase{
	 protected override void afterInsert(List<Sobject> newRecords) {
        List<Product2> newAccounts = (List<Product2>) newRecords;
        RAUL_ProductsApprovalService.sendToApproveProvidersProducts(newRecords);
    }

    
    

}