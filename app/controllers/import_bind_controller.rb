class ImportBindController < ApplicationController
  def new
  end

  def create
    zone = DNS::Zonefile.load(params[:import][:filename].read)
    ActiveRecord::Base.transaction do
      domain_name = zone.soa.origin.gsub(/\.*$/,'')
      domain = Domain.create!(
        name: domain_name,
        type: "MASTER",
        ttl:3600,
        primary_ns: "master.ns.verschooten.be",
        contact: zone.soa.responsible_party.chomp("."),
        refresh: zone.soa.refresh_time,
        retry: zone.soa.retry_time,
        expire: zone.soa.expiry_time,
        minimum: zone.soa.ttl,
        user: current_user
        )
      %w{master.ns.verschooten.be ns.verschooten.be ns2.verschooten.be}.each do |ns|
         NS.create!(
           domain: domain, 
           name: domain_name,
           content: ns,
           ttl: 3600
           )
      end
      zone.records.each do |record|
        record.host.gsub!(/\.*$/,'') if record.respond_to?(:host)
        case record
        when DNS::Zonefile::NS
          next if record.host == domain_name
         NS.create!(
           domain: domain, 
           name: record.host,
           content: record.domainname.chomp("."),
           ttl: record.ttl
           )
        when DNS::Zonefile::MX
          MX.create!(
            domain: domain, 
            name: record.host,
            content: record.domainname.chomp("."),
            prio: record.priority,
            ttl: record.ttl
            )
        when DNS::Zonefile::A
          A.create!(
            domain: domain,
            name: record.host,
            content: record.address,
            ttl: record.ttl
            )
        when DNS::Zonefile::CNAME
          CNAME.create!(
            domain: domain,
            name: record.host,
            content: record.domainname.chomp("."),
            ttl: record.ttl
            )
        end
      end
      redirect_to domain
    end
  end
end
