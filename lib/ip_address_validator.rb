class IpAddressValidator < ActiveModel::EachValidator
  include RecordPatterns

  def validate_each( record, attribute, value )
    record.errors[ attribute ] << I18n.t(:message_attribute_must_be_ip) unless valid?( value )
  end

  def valid?( ip )
    ( options[:ipv6] && ipv6?( ip ) ) || ipv4?( ip )
  end
end
