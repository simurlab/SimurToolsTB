fs = 120;                  % Hz

% load         % a_z_raw

[T_valla, info] = estimateHurdleFlightTime(a_z_raw, fs);

fprintf('Tiempo de vuelo sobre la valla: %.3f s\n', T_valla);