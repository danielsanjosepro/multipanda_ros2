#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from geometry_msgs.msg import PoseStamped
from multi_mode_control_msgs.msg import CartesianImpedanceGoal
import numpy as np


class PoseStampedToCartesianImpedanceGoal(Node):

    def __init__(self):
        super().__init__('pose_stamped_to_cartesian_impedance_goal')

        self.subscription = self.create_subscription(
            PoseStamped,
            'target_pose',
            self.pose_callback,
            10)

        self.publisher = self.create_publisher(
            CartesianImpedanceGoal,
            '/panda/panda_cartesian_impedance_controller/desired_pose',
            10)

        self.get_logger().info('PoseStamped to CartesianImpedanceGoal translator started')

    def pose_callback(self, msg):
        goal_msg = CartesianImpedanceGoal()

        goal_msg.pose = msg.pose

        goal_msg.q_n = [0.0] * 7

        self.publisher.publish(goal_msg)
        self.get_logger().debug(f'Translated PoseStamped to CartesianImpedanceGoal')


def main(args=None):
    rclpy.init(args=args)
    node = PoseStampedToCartesianImpedanceGoal()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()