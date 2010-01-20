# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def google_pie_chart(data, options = {})
    options[:width] ||= 250
    options[:height] ||= 100
    options[:colors] = %w(0DB2AC F5DD7E FC8D4D FC694D FABA32 704948 968144 C08FBC ADD97E)
    dt = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-."
    options[:divisor] ||= 1

    while (data.map { |k,v| v }.max / options[:divisor] >= 4096) do
      options[:divisor] *= 10
    end

    opts = {
      :cht => "p",
      :chd => "e:#{data.map{|k,v|v=v/options[:divisor];dt[v/64..v/64]+dt[v%64..v%64]}}",
      :chl => "#{data.map { |k,v| CGI::escape(k + " (#{v})")}.join('|')}",
      :chs => "#{options[:width]}x#{options[:height]}",
      :chco => options[:colors].slice(0, data.length).join(','),
      :chf => "bg,s,#{options[:bgcolor]}"
    }

    image_tag("http://chart.apis.google.com/chart?#{opts.map{|k,v|"#{k}=#{v}"}.join('&')}")
  rescue
  
 end
  
  def simple_banner(text)
    html = ''
    html << "<div class=\"full_width_header_box\">"
    html << "<div class=\"t\"><div class=\"b\"><div class=\"l\"><div class=\"r\">"
    html << "<div class=\"bl_nav_bar\"><div class=\"br_nav_bar\"><div class=\"tl_nav_bar\"><div class=\"tr_nav_bar\">"
    html << "<div class=\"full_width_header_content\">#{text}</div></div></div></div></div></div></div></div></div></div>"
    return html
  end

  def nav_header_text(left_side, right_side)
    html = ''
    html << "<table style=\"position: relative;top: -2px\" cellpadding=\"0\" cellspacing=\"0\"><tr><td style=\"padding-top: 3px\">#{left_side}</td>"
    html << "<td align=\"right\" valign=\"middle\">#{right_side}</td></tr></table>"
    return html
  end

  def sub_header_text(left_side, right_side)
    html = ''
    html << "<table style=\"position: relative; top: -2px\" cellpadding=\"0\" cellspacing=\"0\"><tr><td>#{left_side}</td>"
    html << "<td align=\"right\">#{right_side}</td></tr></table>"
    return html
  end

  def help_link(url, title = 'Help', align = 'middle', width = 400, height = 400)
    return "<a style=\"text-decoration:none\" href=\"#\" onclick=\"open_help('#{url}', '#{title}', '#{width}', '#{height}');\"><span style=\"vertical-align:top;font-size:0.8em;color:blue;font-weight:bold\" title=\"#{title}\">?</span></a>"
  end

  def user_logged_in?
      session[:user_id]
  end

  def fast_link(text, link, html_options='')
    %(<a href="/#{link}" #{html_options}>#{text}</a>)
  end

  def flash_helper

    f_names = [:notice, :warning, :message]
    fl = ''

    for name in f_names
      if flash[name]
        fl = fl + "<div class=\"notice\">#{flash[name]}</div>"
      end
      flash[name] = nil;
    end
    return fl
  end

  def format_address_lines(agency)
    # addr1 is always populated
    address = []
    address << agency.addr1
    address << agency.addr2 unless agency.addr2.blank?
    address << agency.addr3 unless agency.addr3.blank?
    address << agency.city unless agency.city.blank?
    address << agency.region unless agency.region.blank?
    address << agency.postCode unless agency.postCode.blank?
    return address
  end

  def sort_link(title, column, selected_column, options = {})
    condition = options[:unless] if options.has_key?(:unless)
    params[:d] = 'up' if params[:d].blank?
    if selected_column.nil?
      sort_dir = 'up'
    else
      if selected_column == column.to_s
        sort_dir = params[:d] == 'up' ? 'down' : 'up' 
      else
        sort_dir = 'up'
      end
    end

    image = "&nbsp;<img src=\"/images/up_arrow.gif\" style=\"padding-bottom: 3px\" alt=\"\" />"
    if sort_dir == 'up'
      image = "&nbsp;<img src=\"/images/down_arrow.gif\" style=\"padding-bottom: 3px\" alt=\"\" />"
    end

    output = link_to_unless(condition, title, request.parameters.merge( {:c => column, :d => sort_dir } ), :class => 'sort bold')
    
    output += image if column.to_s == selected_column
    return output
  end

  def navigation_bar_simple(text)
    html = ''
    html << "<div class=\"nav_bar_box\"><div class=\"t\"><div class=\"b\"><div class=\"l\"><div class=\"r\">"
    html << "<div class=\"bl_nav_bar\"><div class=\"br_nav_bar\"><div class=\"tl_nav_bar\"><div class=\"tr_nav_bar\">"
    html << "<div class=\"nav_bar_content\">"
    html << text
    html << "</div></div></div></div></div></div></div></div></div></div>"

    return html
  end

  def two_column_nav_bar_layout(left, right)
    html = "<table class=\"nav_header\" cellpadding=\"0\" width=\"100%\" cellspacing=\"0\">"
    html << "<tr><td class=\"nav_header_left\">#{left}</td>"
    html << "<td class=\"nav_header_right\" align=\"right\">#{right}</td></tr></table>"
    return html
  end

  def two_column_nav_bar_layout2(left, right)
    html = "<table cellpadding=\"0\" width=\"100%\" cellspacing=\"0\">"
    html << "<tr><td id=\"nav_header_left\">#{left}</td>"
    html << "<td id=\"nav_header_right\" align=\"left\">#{right}</td></tr></table>"
    return html
  end


  def single_column_layout(left,right)
    html = "<table cellpadding=\"3\" width=\"100%\" cellspacing=\"0\">"
    html << "<tr><td id=\"nav_header_left\">#{left}</td></tr>"
    html << "<tr><td id=\"nav_header_left\">#{right}</td></tr></table>"
  end

  def multi_column_nav_bar_layout(left, right_cells)
    html = "<table cellpadding=\"0\" width=\"100%\" cellspacing=\"0\">"
    html << "<tr><td id=\"nav_header_left\">#{left}</td>"
    html << "#{right_cells}</tr></table>"
    return html
  end

  def navigation_bar(left_html, right_html)
    html = ''
    html << "<div class=\"nav_bar_box\"><div class=\"t\"><div class=\"b\"><div class=\"l\"><div class=\"r\">"
    html << "<div class=\"bl_nav_bar\"><div class=\"br_nav_bar\"><div class=\"tl_nav_bar\"><div class=\"tr_nav_bar\">"
    html << "<div class=\"nav_bar_content\">"
    html << left_html unless left_html.blank?
    html << right_html unless right_html.blank?
    html << "</div></div></div></div></div></div></div></div></div></div>"

    return html
  end
  def right_panel_task_bar(left_html, right_html)
    html=''
    html << "<div class=\"sidebar_form new_task\"><div><div class=\"right_section_header\"><h1>"
    html << left_html unless left_html.blank?    
    html << "</h1></div><div class=\"body\"><div class=\"top_box\">"
    html << right_html unless right_html.blank?
    html << "</div></div></div></div>"                            
  end

def right_panel_bar_with_header(left_html, right_html)
  html=''
  html << "<h1>#{left_html unless left_html.blank?}</h1><div class=\"module\"><div class=\"inner\"><h2></h2><p>#{right_html unless right_html.blank?}<p></div></div>"
  return html
end
              

  def left_panel_footer
   html=''
   html <<  "<div id=\"Footer\"><img src="" width=\"38\" height=\"32\" alt=\"Highrise Logo\" style=\"float: left;\" />"
   html << "<span style=\"padding-top: 10px; line-height: 1.4em;\"><a href="" target=_blank>Terms of service</a></span></div>"  
  end

  

  def delete_link_readonly(readonly, type, caption, msg, url, width)
    
    html = ''
    
    if readonly == true
      
      html << html = image_tag('/images/cross_48.gif', :class => 'small_icon', :title => 'You do have permission to delete ' + type)  
      
    else
      
      html << delete_link(caption, msg, url, width, readonly, type)
      
    end
  end
  
  def delete_link(caption, msg, url, width, readonly, model)
    
    html = ''
    
    if readonly
      
      html = image_tag('/images/lock.gif', :title => 'You do not have permission to delete ' + model)
      
    else
      
      html << "<a href=\"#\" class=\"image\">"
      html << image_tag('/images/cross_48.gif', :title => caption, :class => 'small_icon', :onclick => "Modalbox.show(\"<div class='MB_alert'><p>#{escape_javascript(msg)}</p> <a style='color: red;font-weight:bold' href='#{url}'>Yes</a> or <a style='color: green;font-weight: bold' href='javascript:none' onclick='Modalbox.hide()'>No</a></div>\", {title: (this.title == '' ? 'Confirm' : this.title), width: #{width}, autoFocusing: false});" )
      html << "</a>"
    end
    return html
  end

  # not tested
  def submit_with_confirm(form, text, caption, msg, width)
    html = ''
    html << submit_tag(text, :title => caption, :class => 'generalButton', :onclick => "Modalbox.show(\"<div class='MB_alert'><p>#{escape_javascript(msg)}</p> <a style='color: red;font-weight:bold' href='#' onclick='#{form}.submit(); return true;'>Yes</a> or <a style='color: green;font-weight: bold' href='javascript:none' onclick='Modalbox.hide()'>No</a></div>\", {title: (this.title == '' ? 'Confirm' : this.title), width: #{width}, autoFocusing: false}); return false;" )
  end

  def simple_modal_box(title, href, width = 300)
    html = ''
    html << "Modalbox.show('#{href}'"
    html << "', {title: (this.title == '#{title}', width: #{width}, autoFocusing: false}\');"
    return html
  end

  def show_errors(title, msgs)
    return "<SCRIPT>display_errors('#{title}','#{msgs}');</SCRIPT>"
  end

  def show_notice(text)
    return "<SCRIPT>display_notice('#{text}');</SCRIPT>"
  end
  
  def get_save_image(read_only, target, html_options = {})
    
    html = ''
    
    html_options.merge!(:class => 'small_icon')
    
    if read_only == true
      html_options.merge!(:title => 'You do not have permission to ' + target)
      html = image_tag('/images/lock.gif', html_options)  
    else
      html = image_submit_tag('/images/floppy_disk_48.gif', html_options)
    end
    
    return html
    
  end
  
  def get_delete_image(read_only, model, hide = false, html_options = {})
    
    html = ''
    
    html_options.merge!(:class => 'small_icon')
    
    if read_only == true
      html_options.merge!(:title => 'You do not have permission to delete ' + model)
      html = image_tag('/images/cross_48.gif', html_options) if hide
    else
      html = image_submit_tag('/images/floppy_disk_48.gif', html_options)
    end
    
    return html
    
  end
  
  def link_to_readonly(caption, target, model, read_only, html_options = nil)
    
    html = ''
    
    if read_only == true
      
      html << "<span class=\"readonly_link\" title=\"You do not have permission to #{model}\"><u>#{caption}</u></span>"
        
    else
      
      
      html << link_to(caption, target, html_options)
      
    end
    
    return html
    
  end
  
end