class AddDefaultMarginToClient < ActiveRecord::Migration
  def self.up
    add_column :agencies, :defaultMargin, :decimal, :default => 0, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :agencies, :defaultMargin
  end
  
end
