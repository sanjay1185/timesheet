class ChangeRateTypeOnRates < ActiveRecord::Migration
  def self.up
    remove_column :rates, :rateType
    add_column :rates, :rateType, :string, :limit => 10, :null => false, :default => 'Hour'
    add_column :rates, :category, :string, :limit => 25, :null => false
  end

  def self.down
    remove_column :rates, rateType
    remove_column :rates, category
    add_column :rates, :rateType, :string, :limit => 25, :null => false
  end
end
