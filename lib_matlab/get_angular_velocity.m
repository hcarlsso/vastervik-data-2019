function w = get_angular_velocity(msgStructs)

w_x = cellfun(@(m) m.AngularVelocity.X, msgStructs);
w_y = cellfun(@(m) m.AngularVelocity.Y, msgStructs);
w_z = cellfun(@(m) m.AngularVelocity.Z, msgStructs);

w = [w_x'; w_y'; w_z'];
