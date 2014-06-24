class AddTemplateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :template, :string
  end
end
