class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :type, null: false
      t.string :title, null: false
      t.string :email, null: false
      t.string :phone, null: false

      t.timestamps
    end
  end
end
