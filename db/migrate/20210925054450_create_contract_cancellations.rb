class CreateContractCancellations < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_cancellations do |t|
      t.references :contract, foreign_key: true
      t.integer :reason, null: false

      t.timestamps
    end
  end
end
