from setuptools import find_packages, setup

package_name = 'franka_simple_publishers'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='jin-mirmi',
    maintainer_email='s.bien@tum.de',
    description='TODO: Package description',
    license='Apache-2.0',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'pose_stamped_to_cartesian_impedance_goal = franka_simple_publishers.pose_stamped_to_cartesian_impedance_goal:main',
            'joint_state_to_joint_goal = franka_simple_publishers.joint_to_joing_goal:main',
        ],
    },
)
