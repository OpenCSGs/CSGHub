class AddOriginToDatasets < ActiveRecord::Migration[7.0]
  def change
    add_column :datasets, :origin, :string
  end
end
