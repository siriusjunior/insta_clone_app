class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.references :plan, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
