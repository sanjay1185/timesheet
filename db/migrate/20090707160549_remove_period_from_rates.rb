class RemovePeriodFromRates < ActiveRecord::Migration
  def self.up
    remove_column :rates, :period
  end

  def self.down
  end
end
