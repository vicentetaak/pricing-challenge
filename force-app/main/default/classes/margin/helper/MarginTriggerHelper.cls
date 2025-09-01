public class MarginTriggerHelper {
    public static void handleBeforeInsertMargin(List<margin__c> newMargins) {
        Set<String> cities = new Set<String>();
        Set<String> states = new Set<String>();
        Set<String> countries = new Set<String>();
        Set<String> accounts = new Set<String>();
        Set<String> accountGroups = new Set<String>();
        Set<String> products = new Set<String>();
        Set<String> productHierarchies = new Set<String>();
        Map<String, margin__c> uniqueMarginsMap = new Map<String, margin__c>();
        for(margin__c margin : newMargins) {
            String key = margin.city__c + '-' + margin.state__c + '-' + margin.country__c + '-' + margin.account__c + '-' + margin.accountGroup__c + '-' +
                        margin.product__c + '-' + margin.productHierarchy__c;
            if(uniqueMarginsMap.get(key) != null){
                margin.addError('Uma margin com o mesma Cidade, Estado, País, Conta, Grupo de Conta, Produto e Hierarquia de Produto já existe.');
            }else{
                uniqueMarginsMap.put(key, margin);
                cities.add(margin.city__c);
                states.add(margin.state__c);
                countries.add(margin.country__c);
                accounts.add(margin.account__c);
                accountGroups.add(margin.accountGroup__c);
                products.add(margin.product__c);
                productHierarchies.add(margin.productHierarchy__c);
            }
        }

        List<margin__c> marginsList = [SELECT city__c, state__c, country__c,
                                     account__c, accountGroup__c, product__c, productHierarchy__c
                                     FROM margin__c
                                     WHERE city__c IN :cities
                                     AND state__c IN :states
                                     AND country__c IN :countries
                                     AND account__c IN :accounts
                                     AND accountGroup__c IN :accountGroups
                                     AND product__c IN :products
                                     AND productHierarchy__c IN :productHierarchies];

        if(!marginsList.isEmpty()) {
            Map<String, margin__c> marginsMap = new Map<String, margin__c>();
            for(margin__c margin : marginsList) {
                marginsMap.put(margin.city__c + '-' + margin.state__c + '-' + margin.country__c + '-' + 
                                        margin.account__c + '-' + margin.accountGroup__c + '-' + margin.product__c + '-' + margin.productHierarchy__c, margin);
            }

            for(margin__c margin : uniqueMarginsMap.values()) {
            String key = margin.city__c + '-' + margin.state__c + '-' + margin.country__c + '-' + margin.account__c + '-' + margin.accountGroup__c + '-' +
                        margin.product__c + '-' + margin.productHierarchy__c;
                if(marginsMap.get(key) != null) {
                    margin.addError('Uma margin com o mesma Cidade, Estado, País, Conta, Grupo de Conta, Produto e Hierarquia de Produto já existe.');
                }
            }
        }
    }
}
