public class OrderItemTriggerHelper {
    private static Set<Id> orderIds = new Set<Id>();
    private static Set<Id> productIds = new Set<Id>();
    private static Map<Id, Id> accountsMap = new Map<Id, Id>();
    private static Map<Id, Id> ordersMap = new Map<Id, Id>();
    private static Map<Id, Id> citiesMap = new Map<Id, Id>();
    private static Map<Id, Id> statesMap = new Map<Id, Id>();
    private static Map<Id, Id> productHierarchiesMap = new Map<Id, Id>();

    public static void handleBeforeInsertOrderItem(List<OrderItem> newOrderItems) {
        clearSetAndMap();
        populateOrderIdAndProductIdSets(newOrderItems);
        getCityAndAccountIdByOrder();
        getStateByCity(ordersMap.values());
        obtainTaxRegistration(newOrderItems);
        getCountryByState(citiesMap.values());
        getProductHierarchyByProduct();
        obtainFreightRegistration(newOrderItems);
        obtainMarginRegistration(newOrderItems);
    }

    public static void handleBeforeUpdateOrderItem(List<OrderItem> newOrderItems, Map<Id,OrderItem> oldOrderItemsMap) {
        clearSetAndMap();
    }

    private static void obtainTaxRegistration(List<OrderItem> newOrderItems){
        List<tax__c> taxesList = [SELECT state__c, product__c, taxOnCost__c FROM tax__c WHERE state__c IN :citiesMap.values()
                                    AND product__c IN :productIds 
                                    AND status__c = 'Aprovado'];
        Map<String, tax__c> taxesMap = new Map<String, tax__c>();
        for(tax__c tax : taxesList){
            taxesMap.put(tax.state__c + '-' + tax.product__c, tax);
        }
        
        for(OrderItem orderItem : newOrderItems){
            Id state = citiesMap.get(ordersMap.get(orderItem.OrderId));
            String key = state + '-' + orderItem.Product2Id;
            if(taxesMap.get(key) != null){
                orderItem.taxPercentage__c = taxesMap.get(key).taxOnCost__c;
            }
        }
    }

    private static void obtainFreightRegistration(List<OrderItem> newOrderItems){
        List<freight__c> freightsList = [SELECT product__c, productHierarchy__c, city__c, state__c, country__c, shippingValue__c
                                            FROM freight__c 
                                            WHERE (Product__c IN :productIds OR productHierarchy__c IN :productHierarchiesMap.values()) 
                                                AND (city__c IN :ordersMap.values() OR state__c IN :citiesMap.values() OR country__c IN :statesMap.values())
                                                AND status__c = 'Aprovado'];
        Map<String, freight__c> freightsMap = new Map<String, freight__c>();
        for(freight__c freight : freightsList){
            String key = '';
            if(freight.product__c != null)
                key = freight.product__c;
            else if(freight.productHierarchy__c != null)
                key = freight.productHierarchy__c;
            if(freight.city__c != null)
                key += '-' + freight.city__c;
            else if(freight.state__c != null)
                key += '-' + freight.state__c;
            else if(freight.country__c != null)
                key += '-' + freight.country__c;

            freightsMap.put(key, freight);
        }

        for(OrderItem orderItem : newOrderItems){
            Id city = ordersMap.get(orderItem.OrderId);
            Id state = citiesMap.get(city);
            Id country = statesMap.get(state);
            Id productHierarchy = productHierarchiesMap.get(orderItem.Product2Id);
            String key = '';
            if(freightsMap.get(orderItem.Product2Id + '-' + city) != null)
                key = orderItem.Product2Id + '-' + city;            
            else if(freightsMap.get(orderItem.Product2Id + '-' + state) != null)
                key = orderItem.Product2Id + '-' + state;            
            else if(freightsMap.get(orderItem.Product2Id + '-' + country) != null)
                key = orderItem.Product2Id + '-' + country;
            else if(freightsMap.get(productHierarchy + '-' + city) != null)
                key = productHierarchy + '-' + city;
            else if(freightsMap.get(productHierarchy + '-' + state) != null)
                key = productHierarchy + '-' + state;
            else if(freightsMap.get(productHierarchy + '-' + country) != null)
                key = productHierarchy + '-' + country;

            if(freightsMap.get(key) != null)
                orderItem.shippingValue__c = freightsMap.get(key).shippingValue__c;
        }
    }

    public static void obtainMarginRegistration(List<OrderItem> newOrderItems){
        List<Account> nonMarginAccountsList = [SELECT clientsGroup__c FROM Account WHERE Id IN :accountsMap.values()];
        Map<Id,Id> nonMarginAccountsMap = new Map<Id,Id>();
        for(Account account : nonMarginAccountsList){
            nonMarginAccountsMap.put(account.Id, account.clientsGroup__c);
        }

        List<margin__c> marginsList = [SELECT product__c, productHierarchy__c, account__c, accountGroup__c, city__c, state__c, country__c, marginValue__c
                                        FROM margin__c 
                                        WHERE (Product__c IN :productIds OR productHierarchy__c IN :productHierarchiesMap.values())
                                            AND (Account__c IN :accountsMap.values() OR accountGroup__c IN :nonMarginAccountsMap.values())
                                            AND (city__c IN :ordersMap.values() OR state__c IN :citiesMap.values() OR country__c IN :statesMap.values())
                                            AND status__c = 'Aprovado'];

        Map<String, margin__c> marginsMap = new Map<String, margin__c>();
        for(margin__c margin : marginsList){
            String key = '';
            if(margin.product__c != null)
                key = margin.product__c;
            else if(margin.productHierarchy__c != null)
                key = margin.productHierarchy__c;
            if(margin.account__c != null)
                key += '-' + margin.account__c;
            else if(margin.accountGroup__c != null)
                key += '-' + margin.accountGroup__c;
            if(margin.city__c != null)
                key += '-' + margin.city__c;
            else if(margin.state__c != null)
                key += '-' + margin.state__c;
            else if(margin.country__c != null)
                key += '-' + margin.country__c;

            marginsMap.put(key, margin);
        }

        for(OrderItem orderItem : newOrderItems){
            Id productHierarchy = productHierarchiesMap.get(orderItem.Product2Id);
            Id accountId = accountsMap.get(orderItem.OrderId);
            Id accountGroup = nonMarginAccountsMap.get(accountId);
            Id city = ordersMap.get(orderItem.OrderId);
            Id state = citiesMap.get(city);
            Id country = statesMap.get(state);
            String key = '';
            if(marginsMap.get(orderItem.Product2Id + '-' + accountId + '-' + city) != null)
                key = orderItem.Product2Id + '-' + accountId + '-' + city;            
            else if(marginsMap.get(orderItem.Product2Id + '-' + accountId + '-' + state) != null)
                key = orderItem.Product2Id + '-' + accountId + '-' + state;            
            else if(marginsMap.get(orderItem.Product2Id + '-' + accountId + '-' + country) != null)
                key = orderItem.Product2Id + '-' + accountId + '-' + country;
            else if(marginsMap.get(orderItem.Product2Id + '-' + accountGroup + '-' + city) != null)
                key = orderItem.Product2Id + '-' + accountGroup + '-' + city;
            else if(marginsMap.get(orderItem.Product2Id + '-' + accountGroup + '-' + state) != null)
                key = orderItem.Product2Id + '-' + accountGroup + '-' + state;
            else if(marginsMap.get(productHierarchy + '-' + accountGroup + '-' + country) != null)
                key = productHierarchy + '-' + accountGroup + '-' + country;
            else if(marginsMap.get(productHierarchy + '-' + accountId + '-' + city) != null)
                key = productHierarchy + '-' + accountId + '-' + city;
            else if(marginsMap.get(productHierarchy + '-' + accountId + '-' + state) != null)
                key = productHierarchy + '-' + accountId + '-' + state;
            else if(marginsMap.get(productHierarchy + '-' + accountId + '-' + country) != null)
                key = productHierarchy + '-' + accountId + '-' + country;
            else if(marginsMap.get(productHierarchy + '-' + accountGroup + '-' + city) != null)
                key = productHierarchy + '-' + accountGroup + '-' + city;
            else if(marginsMap.get(productHierarchy + '-' + accountGroup + '-' + state) != null)
                key = productHierarchy + '-' + accountGroup + '-' + state;
            else if(marginsMap.get(productHierarchy + '-' + accountGroup + '-' + country) != null)
                key = productHierarchy + '-' + accountGroup + '-' + country;

            if(marginsMap.get(key) != null)
                orderItem.marginPercentage__c = marginsMap.get(key).marginValue__c;
        }
    }

    private static void populateOrderIdAndProductIdSets(List<OrderItem> newOrderItems){
        for(OrderItem orderItem : newOrderItems){
            orderIds.add(orderItem.OrderId);
            productIds.add(orderItem.Product2Id);
        }
    }

    private static void getCityAndAccountIdByOrder(){
        List<Order> ordersList = [SELECT AccountId, accountAddress__r.city__c FROM Order WHERE Id IN :orderIds];
        for(Order order : ordersList){
            ordersMap.put(order.Id, order.accountAddress__r.city__c);
            accountsMap.put(order.Id, order.AccountId);
        }
    }

    private static void getStateByCity(List<Id> values){
        List<city__c> citiesList = [SELECT state__c FROM city__c WHERE Id IN :values];
        for(city__c city : citiesList){
            citiesMap.put(city.Id, city.state__c);
        }
    }

    private static void getCountryByState(List<Id> values){
        List<state__c> statesList = [SELECT country__c FROM state__c WHERE Id IN :values];
        for(state__c state : statesList){
            statesMap.put(state.Id, state.country__c);
        }
    }

    private static void getProductHierarchyByProduct(){
        List<Product2> productsList = [SELECT productHierarchy__c, Name FROM Product2 WHERE Id IN :productIds];
        for(Product2 product : productsList){
            productHierarchiesMap.put(product.Id, product.productHierarchy__c);
        }
    }

    private static void clearSetAndMap(){
        orderIds.clear();
        productIds.clear();
        ordersMap.clear();
        accountsMap.clear();
        citiesMap.clear();
        statesMap.clear(); 
        productHierarchiesMap.clear();
    }
}