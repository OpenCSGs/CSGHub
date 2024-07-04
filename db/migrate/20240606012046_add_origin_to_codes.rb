class AddOriginToCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :codes, :origin, :string
  end
end
