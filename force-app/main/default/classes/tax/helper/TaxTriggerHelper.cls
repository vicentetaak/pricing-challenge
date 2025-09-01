public class TaxTriggerHelper {
    public static void handleBeforeInsertTax(List<tax__c> newTaxes) {
        Set<String> states = new Set<String>();
        Set<String> products = new Set<String>();
        Map<String, tax__c> uniqueTaxesMap = new Map<String, tax__c>();
        for(tax__c tax : newTaxes) {
            String key = tax.state__c + '' + tax.product__c;
            if(uniqueTaxesMap.get(key) != null){
                tax.addError('Um Imposto com o mesmo Produto e Estado já existe.');
            }else{
                uniqueTaxesMap.put(key, tax);
                states.add(tax.state__c);
                products.add(tax.product__c);
            }
        }

        List<tax__c> taxesList = [SELECT state__c, product__c FROM tax__c WHERE state__c IN :states AND product__c IN :products];

        if(!taxesList.isEmpty()) {
            Map<String, tax__c> taxesMap = new Map<String, tax__c>();
            for(tax__c tax : taxesList) {
                taxesMap.put(tax.state__c + '' + tax.product__c, tax);
            }

            for(tax__c tax : uniqueTaxesMap.values()) {
            String key = tax.state__c + '' + tax.product__c;
                if(taxesMap.get(key) != null) {
                    tax.addError('Um Imposto com o mesmo Produto e Estado já existe.');
                }
            }
        }
    }
}