module ManageIQ::Providers
  class Inventory::Persister
    class Builder
      class StorageManager < ::ManageIQ::Providers::Inventory::Persister::Builder
        def cloud_volumes
          add_common_default_values
        end

        def cloud_volume_snapshots
          add_common_default_values
        end

        def cloud_volume_backups
          add_common_default_values
        end

        def backup_schedules
          add_common_default_values
        end

        def cloud_object_store_objects
          add_common_default_values
        end

        def cloud_object_store_containers
          add_common_default_values
        end
      end
    end
  end
end
