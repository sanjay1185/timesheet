class Settings < ActiveRecord::Base

  #----------------------------------------------------------------------------
  # Get a setting from the database
  #----------------------------------------------------------------------------
  def self.get_setting(*args)

    # return if no args are supplied
    return nil if args.nil?

    # if we have two ars then we're supplying the name and a date
    if args.length == 2

      find(:first, :conditions => ["name = ? and (effectiveDate <= ? or effectiveDate is null)", args[0], args[1]], :order => 'effectiveDate DESC')

    # if just one arg then just a name (effectivedate must be null)
    elsif args.length == 1

      find(:first, :conditions => ["name = ? and effectiveDate is null", args[0]])

    # any other args supplied, return nil
    else

      return nil

    end

  end

end
