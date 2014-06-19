rails generate model Member first_name:string last_name:string address:string city:string state:string zip:string dob:date email:string phone:string

rails generate model Transaction type:string status:string amount:int merchant_account:references payment_account:references processor_transaction_id

rails generate model Message type:string provider:references seeker:references sender:string subject:string body:text