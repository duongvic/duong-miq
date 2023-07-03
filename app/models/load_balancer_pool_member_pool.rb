class LoadBalancerPoolMemberPool < ApplicationRecord

  after_destroy :destroy_pool_members

  belongs_to :load_balancer_pool
  belongs_to :load_balancer_pool_member

  def destroy_pool_members
    LoadBalancerPoolMember.find(load_balancer_pool_member_id).destroy
  end
end
