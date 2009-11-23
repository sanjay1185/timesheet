module TimesheetsHelper

  def buttons(contract, entries, entry, count, status = 'new')
    html = ''

      if !entry.manual?
        if contract.rateType == 'Hour'
            html << image_submit_tag('add_green.png', :style => "top: 4px", :onclick => "setEntryDate('#{count}')", :name => 'add_h', :title => "Add hourly rate entry")
        else
          if contract.allowOvertime?
            html << image_submit_tag('add_green.png', :style => "top: 4px", :onclick => "setEntryDate('#{count}')", :name => 'add_h', :title => "Add hourly rate entry")
            html << "&nbsp;"
          end
          html << image_submit_tag('add_blue.png', :style => "top: 4px", :onclick => "setEntryDate('#{count}')", :name => 'add_d', :title => 'Add daily rate entry')
        end
      end
    

    if entry.manual?
      if status == 'new'
        html << delete_shift_button(entries.index(entry).to_s)
      else
        html << delete_shift_button(entry.id.to_s)
      end
    end

    return html
    
  end

  def delete_shift_button(name)
    return image_submit_tag('cross_48.gif', :style => "top: 4px", :name => "#{name}_remove", :title => "Delete entry", :class => 'small_icon')
  end

  def select_day_values
    return { 'Quarter' => 0.25, 'Half' => 0.5, 'Full' => 1, '[Select]' => 0 }.sort
  end
  
end