class RemoveDayLengthFromContracts < ActiveRecord::Migration
  def self.up
    remove_column :contracts, :dayLength
  end

  def self.down
  end
end
