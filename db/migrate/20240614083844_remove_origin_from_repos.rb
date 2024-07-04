class RemoveOriginFromRepos < ActiveRecord::Migration[7.0]
  def change
    remove_column :models, :origin
    remove_column :datasets, :origin
    remove_column :codes, :origin
  end
end
