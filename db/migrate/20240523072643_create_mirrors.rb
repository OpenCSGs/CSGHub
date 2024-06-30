class CreateMirrors < ActiveRecord::Migration[7.0]
  def change
    create_table :mirrors do |t|
      t.string :source_url
      t.bigint :mirror_source_id
      t.string :username
      t.string :access_token
      t.string :mirrorable_type
      t.bigint :mirrorable_id
      t.bigint :user_id
      t.timestamps
    end
  end
end
