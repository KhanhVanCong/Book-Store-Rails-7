class CreateOrderBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :order_books do |t|
      t.string :order_id, null: false
      t.references :book, null: false, foreign_key: true
      t.string :book_title
      t.decimal :price_per_unit
      t.integer :quantity

      t.timestamps
    end

    add_foreign_key :order_books, :orders
    add_index :order_books, :order_id
    add_index :order_books, [:order_id, :book_id], unique: true
  end
end
