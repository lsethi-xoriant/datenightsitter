rails generate model Member first_name:string last_name:string address:string city:string state:string zip:string dob:date email:string phone:string

rails generate model MerchantAccount processor_customer_id:string status:string

rails generate model PaymentAccount processor_customer_id:string processor_payment_token:string status:string

rails generate model Transactions type:string status:string amount:int merchant_account:references payment_account:references processor_transaction_id