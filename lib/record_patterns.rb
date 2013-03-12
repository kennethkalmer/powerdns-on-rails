require 'ipaddr'

module RecordPatterns

  def hostname?( value )
    value =~ /\A\S+\Z/
  end

  def ip?( value )
    ipv4?( value ) || ipv6?( value )
  end

  def ipv4?( value )
    value =~ /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z/
  end

  def ipv6?( value )
    begin
      IPAddr.new( "[#{value}]" ).ipv6?
    rescue ArgumentError
      return false
    end
  end

end
