pdf.font "Courier"
day_values = { "1.0" => "Full", "0.5" => "Half", "0.25" => "Quarter", "0.0"=> ""}

pdf.image @img_tag ,:at=>[0,735],:scope=>0.3

table_item = [["","#{@timesheet.contract.client.agency.name}"+@addr +"\nPhone:#{@timesheet.contract.client.agency.phone}"+"\nFax:#{@timesheet.contract.client.agency.fax}",
               "Timesheet No:\n" + "Contractor:\n" + "Client:\n" + "Position:\n" + "Ref:\n" + "Week Ending:",
               "#{@timesheet.id.to_s.rjust(10, '0')}\n"+"#{@timesheet.contractor.user.full_name}\n" +"#{@timesheet.contract.client.name}\n"+"#{@timesheet.contract.position}\n"+"#{@timesheet.contract.ref}\n"+"#{(@timesheet.startDate + 6).to_formatted_s(:uk_date)}\n"]              
             ]

pdf.table table_item,:border_style =>:grid,:font_families=>"helvetica",
                     :border_width=>0,
                     :align =>:left,
                     :font_size => 8,
                     :padding=>0,
                     :column_widths=>{0=>210,1=>120,2=>60}

pdf.move_down(20)

count=0
@timesheet.timesheet_entries.map do
count=count+1
end
item = @timesheet.timesheet_entries.map do |entry|
    [
     "#{entry.dateValue.to_formatted_s(:uk_date_with_day)}",
     "#{entry.startTime.blank? ? "     " : entry.startTime}",
     "#{entry.startTime.blank? ? "     " : entry.breakHours}",
     "#{entry.startTime.blank? ? "     " : entry.finishTime}",
     "#{entry.dayValue.nil? ? "     " : day_values[entry.dayValue.to_s]}",
     "#{entry.hours.blank? ? "     " : entry.hours}",
     "#{entry.rate.name unless entry.rate.nil?}",
     
     ]

    end

pdf.table item,:border_style =>:grid,:width=>450,:font=>"Courier",:font_size => 8,:header_color=>"cccccc",
               :headers=>["#{"Date".ljust(17).gsub(" ","")}","#{"Start Time".ljust(11).gsub("","")}",
                          "#{"Break".ljust(11).gsub("","")}","#{"Finish Time".ljust(11).gsub(" ","")}",
                          "#{"Daily Paid".ljust(11).gsub("","")}","#{"Hours".ljust(10).gsub("","")}",
                          "#{"Rate".ljust(15).gsub("","")}"],:padding=>1,:border_width=>0.5

pdf.table [[""]],:width=>400,
                 :border_width=>0,
                 :padding=>6,
                 :font_size =>8

pdf.table [["Totals:","#{@timesheet.totalDays}","#{@timesheet.totalHours}",""]],
          :width=>450,
          :border_width=>0.5,
          :padding=>1,
          :font_size =>8,
          :column_widths=>{0=>253,1=>60,2=>55,3=>82},
          :align=>{1=>:center,2=>:right}

pdf.move_down(20)

pdf.table [[@timesheet.note]],
          :font_size=>8,
          :headers=>["Notes"],
          :padding=>4,
          :border_width=>0.5,
          :header_color=>"cccccc",
          :width=>450

pdf.move_down(40)

table3 = [
          ["Work Signature:" ,"___________________________","Approver Name:","___________________________"],
          ["Date:","___________________________","Approver Signature:","___________________________"], 
          ["","","Date:","___________________________"]       
          ]

pdf.table table3 ,:border_style =>:grid,
                  :font =>"Courier",
                  :font_size =>8,                                                                      :align=>{0=>:right,1=>:left,2=>:right,3=>:left},:border_width=>0,
                  :column_widths => {1=>150,3=>150},
                  :padding=>1,
                  :cellspacing=>0






















