module AuditsHelper
  
  def parenthesize( text )
    "(#{text})"
  end
  
  def link_to_domain_audit( audit )
    caption = "#{audit.version} #{audit.action} by "
    caption << (audit.user ? audit.user.login : audit.username)
    link_to_function caption, "toggleDomainAudit(#{audit.id})"
  end
  
  def link_to_record_audit( audit )
    caption = audit.changes['type']
    caption ||= audit.auditable.type rescue '[UNKNOWN]'
    caption += " (#{audit.changes['name']})" unless audit.changes['name'].nil?
    caption += " #{audit.version} #{audit.action} by "
    caption += (audit.user ? audit.user.login : audit.username)
    link_to_function caption, "toggleRecordAudit(#{audit.id})"
  end
  
  def display_hash( hash )
    hash.map { |k,v| v ? "<em>#{k}</em>: #{v}" : nil }.compact.join('<br />')
  end
  
  def sort_audits_by_date( collection )
    collection.sort_by(&:created_at).reverse
  end
  
end
