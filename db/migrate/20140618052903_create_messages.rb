class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :type
      t.references :provider, index: true
      t.references :seeker, index: true
      t.integer :direction
      t.string :subject
      t.text :body
      t.string :reference_url

      t.timestamps
    end
  end
end
