# Prueba de conocimiento técnico para Aerolínea con base en BCN
Prueba técnica para entrevista salesforce

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#app-provider-shipments">App <i>Provider Shipments</i></a>
      <ul>
        <li><a href="#home-de-la-app">Home de la App</a></li>
        <li><a href="#shippings">Shippings</a></li>
        <li><a href="#products">Products</a></li>
        <li><a href="#shippings">Shippings</a></li>
      </ul>
    </li>
    <li>
      <a href="#interfaz-entre-sistemas">Interfaz entre sistemas</a>
    </li>
    <li><a href="#products-approval">Products Approval</a></li>
  </ol>
</details>


## App *Provider Shipments*
Para poder visualizar correctamente los envíos realizados se ha creado una aplicación lightning independiente. "Provider shipments" aglutina toda la info acerca de dichos envíos.

<img src="https://user-images.githubusercontent.com/34110058/131030324-e8cbfd83-75ee-4689-8b49-7a3168825aaa.png" width="90%"></img>

### Home de la App
Para poder trackear correctamente los envíos, se han creado dos reports cuya representación tiene lugar en el "Home" de la propia aplicación mediante un dashboard:
* Reporte por almacén de destino
* Reporte por fecha de envío


Además se incluye la lista de ítems pendientes de aprovar, de forma que los usuarios que tengan acceso a la app puedan aprobar los productos enviados de forma rápida


<img src="https://user-images.githubusercontent.com/34110058/131030323-6e140cae-4edf-46f0-a3cc-d8ba1d54884a.png" width="90%"></img> 

### Shippings

La tabs de shippings corresponde con los envíos integrados vía webService: 

<img src="https://user-images.githubusercontent.com/34110058/131030318-06f677d3-9b66-4dee-9b91-5ad21460ae86.png" width="90%"></img> 

En la hoja de cada registro se puede ver los atributos propios del envío:
* Fecha de envío (Date)
* Almacen (Picklist)
* Producto (Lookup)
* Cantidad (Number)

<img src="https://user-images.githubusercontent.com/34110058/131030322-30555d66-0974-487a-91c2-f2346237216a.png" width="90%"></img>


### Products

La tabs de products se incluye para poder revisar los productos creados mediante el webService. Como solo disponemos del id del producto y de la descripción mucha información se repite (Product code, Name y External Id corresponden al id del producto):
 
 <img src="https://user-images.githubusercontent.com/34110058/131030312-4ffabfcf-1dca-489f-a1b9-f70d2a61c9fe.png" width="90%"></img>

Por otro lado se ha creado el recordtype "Producto proveedor externo" de forma que podamos discernir entre los productos provenientes de los envíos y otros productos.

Dentro de la vista de un producto, en la sección related, podemos ver el proceso de aprobación que se lanza únicamente en la creación del producto: 

 <img src="https://user-images.githubusercontent.com/34110058/131030306-bcbb26a0-721c-43f1-b366-e45315dca89c.png" width="90%"></img>
 
 ## Interfaz entre sistemas 
 
 Para poder recibir la información de los envíos se ha creado un servicio rest custom que consta de dos clases:
 * [RAUL_InboundProductsWebService ](../main/src/classes/RAUL_InboundProductsWebService.cls) 
    * El servicio en sí. Servicio custom rest de tipo POST que se consume a través del endpoint "/services/apexrest/ProductShippingManagement/v1/"
    * El servicio procesa tanto envíos como productos. Si algo falla en el procesamiento se hace rollback para evitar procesados incompletos 
      * Los envíos se insertan directamente ya que no hay una "id de envío"
      * Los productos se crean o actualizan mediante la operación upsert 
 * [RAUL_ShippingParser](../main/src/classes/RAUL_ShippingParser.cls) 
    * Esta clase se encarga de parsear el json a una clase "wrapper" para que pueda ser leído por el servicio anterior 
 
 En las siguientes imágenes se puede ver como el servicio procesa y devuelve el resultado
 
 ### Request
 <img src="https://user-images.githubusercontent.com/34110058/131030301-f2caecb4-7b86-4f7e-9e20-ee0b9e2b86f3.png" width="90%"></img>
 ### Response
<img src="https://user-images.githubusercontent.com/34110058/131030298-2ef819c6-df4f-4fb8-8061-dde4b7293318.png" width="90%"></img>

 ## Products Approval
Cada vez que se inserta un producto via webService , dicho producto debe ser enviado a aprobación al jefe de logística. Se require, aparte del proceso de aprobación , **un proceso que lance automáticamente dicha aprobación**

En un principio se optó por el uso de un "record-triggered flow" pero tras hacer una prueba de esfuerzo, con cerca de 200 envíos, se comprobó que el rendimiento de los flows para el procesado masivo (recibimos un listado de registros, no registros uno a uno) no es correcto y daba time out.

Por este motivo se ha optado por el uso de un **trigger afterinsert** sobre producto que nos permita lanzar el proceso de aprobación.

Las clases y tiggers involucrados son:

* [TriggerHandlerBase.cls ](../main/src/classes/TriggerHandlerBase.cls) 
  * Interfaz para los handlers 
* [Product2TriggerHandler.cls ](../main/src/classes/Product2TriggerHandler.cls)
  * Trigger Handler de product, encargado de procesar la lógica para cada transacción. 
  * En este caso se usa solo la función after insert ya que necesitamos la id y el proceso de aprobación es únicamente para productos nuevos  
* [ProductTrigger.trigger ](../main/src/triggers/ProductTrigger.trigger) 
  * Trigger de producto   
* [RAUL_ProductsApprovalService.cls ](../main/src/classes/RAUL_ProductsApprovalService.cls) 
  * Servicio para el lanzamiento del proceso de aprobación de forma masiva.

A pesar de haber movido la lógica a los triggers. Se ha comprobado que , con unas pruebas de esfuerzo de 700 registros, también se supera el tiempo máximo de ejecución por lo que cabría considerar mover la lógica de aprobación a un proceso Batch.
 
 
 
