function a = get_acceleration(msgStructs)


a_x = cellfun(@(m) m.LinearAcceleration.X, msgStructs);
a_y = cellfun(@(m) m.LinearAcceleration.Y, msgStructs);
a_z = cellfun(@(m) m.LinearAcceleration.Z, msgStructs);

a = [a_x'; a_y'; a_z'];
