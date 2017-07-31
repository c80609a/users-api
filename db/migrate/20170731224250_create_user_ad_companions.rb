class CreateUserAdCompanions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_ad_companions do |t|
      t.references :user_ad
      t.string :pos
      t.string :org

      t.timestamps
    end
  end
end
