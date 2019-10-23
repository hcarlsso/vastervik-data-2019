# Time

http://wiki.ros.org/msg#headerSect

Two-integer timestamp that is expressed as:
1. stamp.secs: seconds (stamp_secs) since epoch
2. stamp.nsecs: nanoseconds since stamp_secs


# why is not time increasing in the ROS messages

Messages seems to be duplicated, and two-three new messages are added every 20 samples.


Two messages are received every 0.1 second, and measurements in between seems to be discarded. Cal still calulcate derivative.
