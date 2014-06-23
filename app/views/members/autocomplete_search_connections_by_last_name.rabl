collection @members
attributes :id, :first_name, :last_name, :phone
node(:label) {|m| [m.full_name, " | ", number_to_phone(m.phone)].join }
node(:value) {|m| m.last_name }
