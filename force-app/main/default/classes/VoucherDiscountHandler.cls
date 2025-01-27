public class VoucherDiscountHandler{
    public static void applyVoucherDiscount(List<Order__c> orders){
	    
        Voucher__c voucher = new Voucher__c();
        Set<String> code = new Set<String>();
		
		// Creating Cart Instance and Fetching Cart details        
        Cart__c c = new Cart__c();
        list<Cart__c> cart = [SELECT Id, Name, Product__c, Quantity__c, Line_Total__c FROM Cart__c];
        Decimal Total=0;
        
        // Collect all voucher codes from the orders
        for (Order__c order : orders){
            if (String.isNotBlank(order.Voucher_Code__c)){                
                code.add(order.Voucher_Code__c);
            }
        }
        
        if(code.size()>0){
            try{
                // Fetch Voucher Details
                voucher = [SELECT Id, Code__c, Discount_Amount__c, IsActive__c From Voucher__c WHERE Code__c IN:code ];
            } catch(EXception ex){
                // Handle exceptions
                System.debug('Error fetching voucher details: ' + ex.getMessage());
            }
        }
        
        // Calculating Cart Total
        for(Cart__c car : cart)
            Total = Total + car.Line_Total__c;
        
        // Apply discount or handle errors
        for(Order__c ord : orders){
            if (voucher != null && voucher.IsActive__c){
                ord.Discount_Applied__c = voucher.Discount_Amount__c;
                ord.Order_Total__c = Total;
                ord.Total_Price__c = Total - voucher.Discount_Amount__c;
            } 

            // If no valid voucher, set Total Price equal to Order Total
            else {
                ord.Order_Total__c = Total;
                ord.Total_Price__c = Total;
            }
        
            // Handle invalid or inactive voucher codes
            if(ord.Voucher_Code__c!=NULL && (voucher.ID==NULL || voucher.IsActive__c==false)){    
                ord.addError('Invalid or inactive voucher code.');
            }
        }
        
        // Deactivate the voucher if valid
        if(voucher!=null && voucher.Id!=null){
            voucher.IsActive__c = false;
            update voucher;
        }
	}
}
