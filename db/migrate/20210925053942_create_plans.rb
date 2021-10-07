class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.integer :price, null: false
      t.integer :interval, null: false

      t.timestamps
    end
  end
end
