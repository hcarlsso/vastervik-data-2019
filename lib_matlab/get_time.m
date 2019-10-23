function time = get_time(message)

secs = double(message.Header.Stamp.Sec);
nSec = double(message.Header.Stamp.Nsec);

time = secs + nSec*1.0e-9;

