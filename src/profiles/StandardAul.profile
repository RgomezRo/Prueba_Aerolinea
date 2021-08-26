<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>RAUL_Providers_Shipments</application>
        <default>false</default>
        <visible>true</visible>
    </applicationVisibilities>
     <custom>false</custom>
    <fieldPermissions>
        <editable>true</editable>
        <field>RAUL_Shipping__c.RAUL_Almacen_de_destino__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>RAUL_Shipping__c.RAUL_Cantidad__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>RAUL_Shipping__c.RAUL_Fecha_de_env_o__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>RAUL_Shipping__c.RAUL_Product__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>Product2-Product Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>RAUL_Shipping__c-Shipping Layout</layout>
    </layoutAssignments>
   
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>RAUL_Shipping__c</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <tabVisibilities>
        <tab>RAUL_Shipping__c</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
    <userLicense>Salesforce Platform</userLicense>
</Profile>
