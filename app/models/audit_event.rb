class AuditEvent < ApplicationRecord

  include FilterableMixin
  include CustomActionsMixin
  include SupportsFeatureMixin
  include OwnershipMixin

  belongs_to :user, :foreign_key => :evm_owner_id

  validates :event, :status, :message, :severity, :presence => true
  validates :status, :inclusion => { :in => %w(success failure) }
  validates :severity, :inclusion => { :in => %w(fatal error warn info debug) }
  validates :action, :inclusion => { :in => %w(trace create delete) }

  scope :with_creation_date, ->(start_date, end_date) { where('audit_events.created_on between ? and ?', start_date, end_date) }
  scope :with_userid,        ->(userid)     { where(:userid => userid) }
  scope :with_service,       ->(service)    { where(:service => service) }
  scope :with_action,        ->(action)     { where(:action => action) }

  def self.services
    {
      :vm                => "VM",
      :network           => "NETWORK",
      :load_balancer     => "LOAD_BALANCER",
      :snapshot          => "SNAPSHOT",
      :subnet            => "SUBNET",
      :backup            => "BACKUP",
      :firewall          => "FIREWALL",
      :firewall_rule     => "FIREWALL_RULE"
    }
  end

  def self.actions
    {
      :trace      => "trace",
      :create     => "create",
      :delete     => "delete",
    }
  end

  def self.generate(attrs)
    attrs[:evm_owner] = User.find_by(:userid => attrs[:userid])
    attrs = {
      :severity => "info",
      :status   => "success",
      :userid   => "system",
      :action   => "trace",
      :source   => AuditEvent.source(caller)
    }.merge(attrs)

    event = AuditEvent.create(attrs)

    # Cut an Audit log message
    $audit_log.send(attrs[:status], "User: [#{attrs[:userid]}] - #{attrs[:message]}")
    event
  end

  def self.success(attrs)
    AuditEvent.generate(attrs.merge(:status => "success", :source => AuditEvent.source(caller)))
  end

  def self.failure(attrs)
    AuditEvent.generate(attrs.merge(:status => "failure", :severity => "warn", :source => AuditEvent.source(caller)))
  end


  def self.source(source)
    /^([^:]+):[^`]+`([^']+).*$/ =~ source[0]
    "#{File.basename($1, ".*").camelize}.#{$2}"
  end

end
