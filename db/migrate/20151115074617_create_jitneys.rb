class CreateJitneys < ActiveRecord::Migration
  def change
    create_table :jitneys do |t|
      t.string :route
      t.boolean :automatic_map

      t.timestamps null: false
    end
  end
end
