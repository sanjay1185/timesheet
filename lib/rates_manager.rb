class RatesManager

  attr_accessor :rates, :contract

  def initialize(contract_id)
    @contract = Contract.find(contract_id)
    @rates = @contract.rates.select {|rate| rate.active?}
  end

  def get_valid_rates(start_date, end_date)

    # get the rates
    valid_rates = @rates.select {
      |rate|
        (rate.effectiveDate.nil? && rate.endDate.nil?) ||
        (rate.effectiveDate >= start_date && rate.endDate <= end_date) ||
        (rate.effectiveDate >= start_date && rate.endDate.nil?) ||
        (rate.effectiveDate.nil? && rate.endDate <= end_date) ||
        (['Unpaid', 'Sickness'].include?(rate.category))
    }
    
    # remove bank hol or overtime if necessary
    valid_rates.delete_if {|rate|
      (rate.category.downcase == 'overtime' && @contract.allowOvertime == false) ||
      (rate.category.downcase == 'bank holiday' && @contract.allowBankHolidays == false)
    }

    return valid_rates
    
  end

  def get_valid_rates_by_type(start_date, end_date, rate_type, exclude_zero_rates = false)

    valid_rates = get_valid_rates(start_date, end_date)

    valid_rates.delete_if {|rate| rate.rateType != rate_type && !['Unpaid', 'Sickness'].include?(rate.category)}
    # delete sickness & unpaid if required
    valid_rates.delete_if {|rate| ['Unpaid', 'Sickness'].include?(rate.category) && exclude_zero_rates}

    return valid_rates

  end

  def get_rate(rate_id)

    search = @rates.select {|rate| rate.id == rate_id}
    if !search.length == 1
      return search[0]
    else
      return nil
    end
    
  end

  def get_unpaid_rate

    return @rates.select {|r| r.category == 'Unpaid' && r.default? }[0]

  end

  def get_default_standard_rate

    # prefer getting real default rate, if there is one
    std_rates = @rates.select {|rate| rate.default? && rate.category.downcase == 'standard'}

    if std_rates.length == 1
      return std_rates[0]
    else
      return nil
    end

  end
  
end