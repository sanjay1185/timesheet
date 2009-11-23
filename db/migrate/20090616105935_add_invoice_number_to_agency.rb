class AddInvoiceNumberToAgency < ActiveRecord::Migration
  def self.up
    add_column :agencies, :nextInvoiceNumber, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :agencies, :nextInvoiceNumber
  end
end
