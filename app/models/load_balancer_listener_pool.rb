class LoadBalancerListenerPool < ApplicationRecord

  after_destroy :destroy_lb_pool

  belongs_to :load_balancer_listener
  belongs_to :load_balancer_pool

  def destroy_lb_pool
    LoadBalancerPool.find(load_balancer_pool_id).destroy
  end
end
