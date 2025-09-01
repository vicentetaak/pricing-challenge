public class FreightTriggerHelper {
    public static void handleBeforeInsertFreight(List<freight__c> newFreights) {
        Set<String> cities = new Set<String>();
        Set<String> states = new Set<String>();
        Set<String> countries = new Set<String>();
        Set<String> products = new Set<String>();
        Set<String> productHierarchies = new Set<String>();
        Map<String, freight__c> uniqueFreightsMap = new Map<String, freight__c>();
        for(freight__c freight : newFreights) {
            String key = freight.city__c + '' + freight.state__c + freight.country__c +
                        freight.product__c + freight.productHierarchy__c;
            if(uniqueFreightsMap.get(key) != null){
                freight.addError('Um Frete com o mesma Cidade, Estado, País, Produto e Hierarquia de Produto já existe.');
            }else{
                uniqueFreightsMap.put(key, freight);
                cities.add(freight.city__c);
                states.add(freight.state__c);
                countries.add(freight.country__c);
                products.add(freight.product__c);
                productHierarchies.add(freight.productHierarchy__c);
            }
        }

        List<freight__c> freightsList = [SELECT city__c, state__c, country__c, product__c, productHierarchy__c 
                                        FROM freight__c
                                        WHERE city__c IN :cities
                                            AND state__c IN :states
                                            AND country__c IN :countries
                                            AND product__c IN :products
                                            AND productHierarchy__c IN :productHierarchies];

        if(!freightsList.isEmpty()){
            Map<String, freight__c> freightsMap = new Map<String, freight__c>();
            for(freight__c freight : freightsList) {
                freightsMap.put(freight.city__c + '' + freight.state__c + freight.country__c +
                        freight.product__c + freight.productHierarchy__c, freight);
            }

            for(freight__c freight : uniqueFreightsMap.values()) {
                String key = freight.city__c + '' + freight.state__c + freight.country__c +
                        freight.product__c + freight.productHierarchy__c;
                if(freightsMap.get(key) != null) {
                    freight.addError('Um Frete com o mesma Cidade, Estado, País, Conta, Grupo de Conta, Produto e Hierarquia de Produto já existe.');
                }
            }
        }
    }
}