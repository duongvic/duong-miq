class BackupSchedule < ApplicationRecord
  include NewWithTypeStiMixin
  include ProviderObjectMixin
  include SupportsFeatureMixin
  include OwnershipMixin

  acts_as_miq_taggable

  belongs_to :user, :foreign_key => :evm_owner_id

  belongs_to :ext_management_system, :foreign_key => :ems_id, :class_name => "ExtManagementSystem"
  belongs_to :cloud_volume, :foreign_key => :volume_id
  belongs_to :tenant

  def self.class_by_ems(ext_management_system)
    ext_management_system && ext_management_system.class::BackupSchedule
  end

  def schedule_create_queue(userid, ext_management_system, options = {})
    task_opts = {
      :action => "creating Backup Schedule for user #{userid}",
      :userid => userid
    }
    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'schedule_create',
      :instance_id => id,
      :role        => 'ems_operations',
      :zone        => ext_management_system.my_zone,
      :args        => [options]
    }
    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def self.schedule_create(ems_id, options = {})
    raise ArgumentError, _("ems_id cannot be nil") if ems_id.nil?
    ext_management_system = ExtManagementSystem.find(ems_id)
    raise ArgumentError, _("ext_management_system cannot be found") if ext_management_system.nil?

    klass = class_by_ems(ext_management_system)
    klass.raw_schedule_create(ext_management_system, options)
  end

  def schedule_delete_queue(userid, ext_management_system)
    task_opts = {
      :action => "deleting Backup Schedule for user #{userid}",
      :userid => userid
    }

    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'schedule_delete',
      :instance_id => id,
      :role        => 'ems_operations',
      :queue_name  => ext_management_system.queue_name_for_ems_operations,
      :zone        => ext_management_system.my_zone,
      :args        => []
    }

    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def schedule_delete
    raw_schedule_delete
  end

  def raw_schedule_delete
    raise NotImplementedError, _("must be implemented in a subclass")
  end

  def schedule_update_queue(userid, options = {})
    task_opts = {
      :action => "updating Backup Schedule for user #{userid}",
      :userid => userid
    }

    queue_opts = {
      :class_name  => self.class.name,
      :method_name => 'schedule_update',
      :instance_id => id,
      :role        => 'ems_operations',
      :queue_name  => ext_management_system.queue_name_for_ems_operations,
      :zone        => ext_management_system.my_zone,
      :args        => [options]
    }

    MiqTask.generic_action_with_callback(task_opts, queue_opts)
  end

  def schedule_update(options = {})
    raw_schedule_update(options)
  end

  def raw_schedule_update(_options = {})
    raise NotImplementedError, _("must be implemented in a subclass")
  end
end
