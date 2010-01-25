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
  def remote_buttons(contract, entries, entry, count, id,status )
    html = ''

      if !entry.manual?
        if contract.rateType == 'Hour'
            html << image_submit_tag('add_green.png', :style => "top: 4px", :onclick => "setEntryDate('#{count}')", :name => 'add_h', :title => "Add hourly rate entry")
        else
          if contract.allowOvertime?
            html << image_submit_tag('add_green.png', :style => "top: 4px", :onclick => "setEntryDate('#{count}')", :name => 'add_h', :title => "Add hourly rate entry")
            html << "&nbsp;"
          end
         if status=='new'
        html << "<a href='#' name = 'add_d' onclick=\"new Ajax.Updater('screen_body', '/timesheets/create?commit=add&selected_date=#{entry.dateValue}&rate_id=#{entry.rate_id}', {asynchronous:true, evalScripts:true,parameters:Form.serialize('new_timesheet')});return false;\""
         else
          html << "<a href='#' name = 'add_d' onclick=\"new Ajax.Updater('screen_body', '/timesheets/update/#{id}?commit=add&selected_date=#{entry.dateValue}&rate_id=#{entry.rate_id}', {asynchronous:true, evalScripts:true,parameters:Form.serialize('edit_timesheet_#{id}')});return false;\""
         end
          html << "><img src=#{path_to_image('add_blue.png')} alt='' class=/'icon_48/' ></a>"
      end
      end

    if entry.manual?
      if status == 'new'
        html << "<a href='#' onclick=\"new Ajax.Updater('screen_body', '/timesheets/create/#{id}?commit=remove&#{entry.id}_remove.x', {asynchronous:true, evalScripts:true,parameters:Form.serialize('new_timesheet')});return false;\""
        html << "><img src='/images/cross_48.gif' class='small_icon' alt='' style='size:16*16'  ></a>"
#        html << delete_shift_button(entries.index(entry).to_s)
      else
        html << "<a href='#' onclick=\"new Ajax.Updater('screen_body', '/timesheets/update/#{id}?commit=remove&#{entry.id}_remove.x', {asynchronous:true, evalScripts:true,parameters:Form.serialize('edit_timesheet_#{id}')});return false;\""
        html << "><img src='/images/cross_48.gif' class='small_icon' alt='' style='size:16*16'  ></a>"
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