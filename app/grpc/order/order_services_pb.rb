# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: order.proto for package 'order'

require 'grpc'
require 'order_pb'

module Order
  module OrderService
    class Service

      include ::GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'order.OrderService'

      rpc :get_order, ::Order::OrderRequest, ::Order::Order
      rpc :approve_order, ::Order::ApprovalRequest, ::Order::Approval
    end

    Stub = Service.rpc_stub_class
  end
end