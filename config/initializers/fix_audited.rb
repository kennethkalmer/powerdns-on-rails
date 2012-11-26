Audit = Audited::Adapters::ActiveRecord::Audit
#TODO: potential vulnarability
Audit.attr_accessible :username, :user, :version, :auditable
