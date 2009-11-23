class Navigator

  def self.set_position(current_session, *values)
    key = values[0]

    clear_position(current_session, key)
    
    if values.length > 2
      val = ''
      for v in 1..values.length
        val += ",#{values[v]}"
      end
      val.slice!(0,1)

      current_session[:nav_store][key] = val
    else
      current_session[:nav_store][key] = values[1]
    end
  end

  def self._load(s)
    return self
  end

  def self.get_position(current_session, key)
    
    if current_session[:nav_store].nil?
      current_session[:nav_store] = {:client_list => ["*", "1"], :contract_list => "1"}
    end

    if !current_session[:nav_store].key?(key)
      return nil
    end
    
    val = current_session[:nav_store][key]

    if !val.nil? && val.include?(",")
      return val.split(",")
    end

    return val
  end

  def self.clear_position(current_session, key)
    if current_session[:nav_store].nil?
      current_session[:nav_store] = {:client_list => ["*", "1"], :contract_list => "1"}
    end

    store = current_session[:nav_store]
    
    if key == :all
      store.clear
    elsif key == :client_list
      store.delete_if {|k,v| k.to_s =~ /^client/ || k.to_s =~ /^contract/ }
    elsif key == :client_id
      store.delete_if {|k,v| k.to_s == "client_id" || k.to_s =~ /^contract/ }
    elsif key == :contract_list
      store.delete_if {|k,v| k.to_s =~ /contract/ }
    elsif key == :contract_id
      store.delete(:contract_id)
    end
    current_session[:nav_store] = store
  end
end