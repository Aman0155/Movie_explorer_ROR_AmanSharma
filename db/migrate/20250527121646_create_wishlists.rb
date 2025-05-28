class CreateWishlists < ActiveRecord::Migration[7.1]
  def change
    create_table :wishlists, force: :cascade do |t|
      t.bigint :user_id, null: false
      t.bigint :movie_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:movie_id], name: "index_wishlists_on_movie_id"
      t.index [:user_id, :movie_id], name: "index_wishlists_on_user_id_and_movie_id", unique: true
      t.index [:user_id], name: "index_wishlists_on_user_id"
    end

    add_foreign_key :wishlists, :users
    add_foreign_key :wishlists, :movies
  end
end