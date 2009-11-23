module ClientsHelper
  def client_list_link(filter, page)
    page = "1" if page.blank?
    return fast_link('Clients',"clients?filter=#{filter}&page=#{page}")
  end
end
