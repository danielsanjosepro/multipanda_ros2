#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import JointState
from multi_mode_control_msgs.msg import JointGoal


class JointStateToJointGoal(Node):
    def __init__(self):
        super().__init__("joint_state_to_joint_goal")

        self.subscription = self.create_subscription(
            JointState, "target_joint", self.joint_callback, 10
        )

        self.publisher = self.create_publisher(
            JointGoal, "/panda/panda_joint_impedance_controller/desired_pose", 10
        )

        self.get_logger().info("JointState to JointGoal translator started")

    def joint_callback(self, msg):
        goal_msg = JointGoal()

        if len(msg.position) >= 7:
            goal_msg.q = list(msg.position[:7])
        else:
            self.get_logger().warn(
                f"JointState has {len(msg.position)} positions, expected at least 7. Padding with zeros."
            )
            goal_msg.q = list(msg.position) + [0.0] * (7 - len(msg.position))

        if len(msg.velocity) >= 7:
            goal_msg.qd = list(msg.velocity[:7])
        else:
            goal_msg.qd = [0.0] * 7

        self.publisher.publish(goal_msg)
        self.get_logger().debug(f"Translated JointState to JointGoal")


def main(args=None):
    rclpy.init(args=args)
    node = JointStateToJointGoal()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    main()

