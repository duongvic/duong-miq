# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: vm_types.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("vm_types.proto", :syntax => :proto3) do
    add_message "grpc_vm.VM" do
      optional :name, :string, 1
      optional :ems_ref, :string, 2
      optional :user_id, :uint32, 3
    end
  end
end

module GrpcVm
  VM = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("grpc_vm.VM").msgclass
end
