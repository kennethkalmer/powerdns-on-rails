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
        primary_ns: zone.soa.nameserver.chomp("."),
        contact: zone.soa.responsible_party.chomp("."),
        refresh: zone.soa.refresh_time,
        retry: zone.soa.retry_time,
        expire: zone.soa.expiry_time,
        minimum: zone.soa.ttl,
        user: current_user
        )
      zone.records.each do |record|
        case record
        when DNS::Zonefile::NS
         NS.create!(
           domain: domain, 
           name: record.host.gsub(/\.*$/,''),
           content: record.domainname.chomp("."),
           ttl: record.ttl
           )
        when DNS::Zonefile::MX
          MX.create!(
            domain: domain, 
            name: record.host.gsub(/\.*$/,''),
            content: record.domainname.chomp("."),
            prio: record.priority,
            ttl: record.ttl
            )
        when DNS::Zonefile::A
          A.create!(
            domain: domain,
            name: record.host.gsub(/\.*$/,''),
            content: record.address,
            ttl: record.ttl
            )
        when DNS::Zonefile::CNAME
          CNAME.create!(
            domain: domain,
            name: record.host.gsub(/\.*$/,''),
            content: record.domainname.chomp("."),
            ttl: record.ttl
            )
        end
      end
      redirect_to domain
    end
  end
end
