class AddOriginToModels < ActiveRecord::Migration[7.0]
  def change
    add_column :models, :origin, :string
  end
end
