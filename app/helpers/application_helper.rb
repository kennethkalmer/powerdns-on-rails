# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Outputs a page title with +@page_title+ appended
  def page_title
    title = "BIND DLZ on Rails"
    title << ' - ' + @page_title unless @page_title.nil?
    title
  end
  
  # Output the flashes if the exist
  def show_flash
    html = ''
    [ :info, :warning, :error ].each do |f|
      unless flash[f].nil?
        html << content_tag( 'div', :class => "flash-#{f}") { flash[f] }
      end
    end
    html
  end
  
  # Link to Zytrax
  def dns_book( text, link )
    link_to text, "http://www.zytrax.com/books/dns/#{link}", :target => '_blank'
  end
end
