# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Member.create(type: "Provider",
              email: "aconrad@sittercity.com",
              phone: "6174708045",
              password_hash: "$2a$10$M5LLFR0ymNj3U9Xsp9CZ6.H.JATKg8jUWCnuGq3CXp5g.5zAskI3q",
              first_name: "approve_me",
              last_name: "Conrad",
              address: "2044 W Bradley Pl.",
              city: "Chicago",
              state: "IL",
              zip: "60618",
              date_of_birth: "1978-05-23",
              merchant_account_id: "6625a600c378e4fa82efe6cca55f877b"
)

Member.create(type: "Seeker",
              email: "mhickey@sittercity.com",
              phone: "3125551212",
              password_hash: "$2a$10$A.KaPBZdTX2G3ff9mtEIb.TEaPWLnD2WNvsqBjXxOMI...",
              first_name: "Marty",
              last_name: "Hickey",
              address: "20 W Kinzie St.",
              city: "Chicago",
              state: "IL",
              zip: "60654",
              payment_account_id: "25610a179022c345ffdb8cbd8de81a81"
)

