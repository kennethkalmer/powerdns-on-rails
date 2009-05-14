# A collection of helper methods to ease the use of Prototip throughout the 
module PrototipHelper
  
  # Insert a help icon that displays the content of +dom_id+ in a tooltip
  def prototip_help_icon( dom_id )
    html = image_tag( 'help.png', :id => 'proto-' + dom_id )
    html << javascript_tag( :defer => 'defer' ) do
      <<-EOF
        new Tip('proto-#{dom_id}', $('#{dom_id}'), {
        title: '#{t(:title_helper_quick_help)}',
        stem: 'leftTop',
        delay: true,
        hideAfter: 2,
        hook: { target: 'middleRight', tip: 'leftTop' },
        hideOn: { element: 'closeButton', event: 'click' },
        offset: { x: 15, y: 0 }
        });
      EOF
    end
  end
  
  def prototip_info_icon( image_name, dom_id )
    html = image_tag( image_name, :id => 'proto-info-' + dom_id )
    html << javascript_tag( :defer => 'defer' ) do
      <<-EOF
        new Tip( 'proto-info-#{dom_id}', $('#{dom_id}'), {
        title: '#{t(:title_helper_quick_info)}',
        delay: false,
        hideAfter: 2,
        hook: { tip: 'leftMiddle', mouse: true },
        hideOn: 'mouseout',
        offset: { x: 15, y: 0 },
        width: 'auto'
        });
      EOF
    end
  end
end

