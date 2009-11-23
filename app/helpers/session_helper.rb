module SessionHelper
  def ajax_login_check
    html = ''
    html << "<div style=\"display: inline;vertical-align: middle\" id=\"answer\"></div>"
    html << "&nbsp;#{link_to_remote("Check", :url => { :controller => 'users', :action => "check_login"}, :update => { :success => "answer", :failure => "answer" }, :loading => "$('indicator').show()", :complete => "$('indicator').hide()", :with => "'login=' + get_login()", :html => {:class => 'norm'})}"
    html << "&nbsp;<img id=\"indicator\" src=\"/images/loading.gif\" class=\"small_icon\" alt=\"\" style=\"display: none\" />"
  end
end