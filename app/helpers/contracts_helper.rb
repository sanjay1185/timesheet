module ContractsHelper
  def contract_list_link(client_id,page,status)
    page = "1" if page.blank?
    return fast_link('Contracts', "clients/#{client_id}/contracts?&page=#{page}&status=#{status}")
  end
end
