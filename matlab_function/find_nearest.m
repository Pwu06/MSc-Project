function nearest_number = find_nearest(num_array, target)
  [~, index] = min(abs(num_array - target)); % find index of the smallest difference
  nearest_number = index; % retrieve the nearest number
end

