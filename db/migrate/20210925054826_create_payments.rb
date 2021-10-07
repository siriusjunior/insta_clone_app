class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.references :contract, foreign_key: true
      t.string :charge_id
      t.date :current_period_start, null: false
      t.date :current_period_end, null: false

      t.timestamps
    end
  end
end
