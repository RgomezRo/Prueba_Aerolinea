@RestResource(urlMapping='/ProductShippingManagement/v1/*')
global with sharing class RAUL_InboundProductsWebService {
    
    @HttpPost
    global static void insertShipments(){
        Savepoint sp = Database.setSavepoint();
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        String body = req.requestBody.toString();
        try {
            
            system.debug(body);
            
            RAUL_ShippingParser treatedResponse = RAUL_ShippingParser.parse(body);
            
            //to avoid duplicate products we use a map instead a list
            Map<String,Product2> prodsToUpsert = new Map<String,Product2>();
            
            // as long as we don't have a shipment id we just insert the shipments
            List<RAUL_Shipping__c> shipmentsToInsert = new List<RAUL_Shipping__c>();
            
            RecordType providerProduct = [SELECT Id FROM Recordtype 
                                          WHERE SobjectType = 'Product2'
                                          AND Name ='Producto Proveedor Externo'];
            
            // first iteration to create the prods
            for(RAUL_ShippingParser.cls_envios shipment:treatedResponse.envios){
                Product2 toUpsert = new Product2(recordTypeId=providerProduct.Id,
                                                 Name = shipment.id_producto,
                                                 Description = shipment.descripcion_Producto,
                                                 ProductCode = shipment.id_producto,
                                                 RAUL_Id_externo__c = shipment.id_producto
                                                ); 
                prodsToUpsert.put(shipment.id_producto,toUpsert);
                
            }
            
            List < Response > lstResponse = new List < Response > ();
            
            Schema.SObjectField prodExternalId = Product2.Fields.RAUL_Id_externo__c;
            //upsert products
            for (Database.UpsertResult sr: Database.upsert(prodsToUpsert.values(),prodExternalId, true)) {
                String errorMsg = '';
                if (sr.isSuccess()) {
                    res.statusCode = 200;
                    lstResponse.add(new Response('Successfully Inserted', sr.getId()));
                } else {
                    for (Database.Error err: sr.getErrors()) {
                        errorMsg = err.getStatusCode() + ': ' + err.getMessage();
                    }
                    res.statusCode = 400;
                    lstResponse.add(new Response(errorMsg, null));
                }
            }
            system.debug(prodsToUpsert.values());
            // second iteration to create the shipments
            for(RAUL_ShippingParser.cls_envios shipment:treatedResponse.envios){
                
                RAUL_Shipping__c toInsert = new RAUL_Shipping__c(
                    RAUL_Almacen_de_destino__c=shipment.almacen_Destino,
                    RAUL_Cantidad__c=shipment.cantidad,
                    RAUL_Fecha_de_env_o__c=shipment.fecha_envio,
                    RAUL_Product__c = prodsToUpsert.get(shipment.id_producto).Id
                ) ;
                
                shipmentsToInsert.add(toInsert);
            }
            // Insert shipments
            for (Database.SaveResult sr: Database.insert(shipmentsToInsert, true)) {
                String errorMsg = '';
                if (sr.isSuccess()) {
                    res.statusCode = 200;
                    lstResponse.add(new Response('Successfully Inserted', sr.getId()));
                } else {
                    for (Database.Error err: sr.getErrors()) {
                        errorMsg = err.getStatusCode() + ': ' + err.getMessage();
                    }
                    res.statusCode = 400;
                    lstResponse.add(new Response(errorMsg, null));
                }
            }
            res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));
            
        } catch (Exception e) {
            
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Response(e.getMessage(), null)));
        }
        if(res.statusCode == 500){ Database.rollback( sp );}
        
    }
    
    public class Response {
        public String message;
        public String recordReceived;
        public Response(String message, string recordReceived) {
            this.message = message;
            this.recordReceived = recordReceived;
        }
    }
    
    
}