thrustRatio = (gravity + deceleration) * (mass / Max_thrust)
1 = (gravity + max_deceleration) * (mass / Max_thrust)
max_thrust = (gravity + max_deceleration) * mass
(gravity + max_deceleration) = max_thrust / mass
max_deceleration = (max_thrust / mass) - gravity.

thrustRatio = (gravity + target_deceleration) * (mass / Max_thrust)
thrustRatio * max_thrust = (gravity + target_deceleration) * mass
thrustRatio * (max_thrust / mass) = gravity + target_deceleration
thrustRatio * (max_thrust / mass) - gravity = target_deceleration
thrustRatio * max_deceleration = target_deceleration
thrustRatio = target_deceleration / max_deceleration


altitude = alt1 + alt2

1 - find time until altitude

altitude = (velocity * time) + (acceleration * time * time)

altitude1 = (velocity * time)
time1 = altitude / velocity.

altitude2 = (acceleration * time * time)
time2^2 = (altitude2 / acceleration)
time2 = sqrt(altitude2 / acceleration)

time = time1 + time2

time = altitude1 / velocity + sqrt(altitude2 / acceleration)

f(velocity) = current_velocity + (acceleration * time)
time = (f(velocity) - current_velocity) / acceleration

f(distance) = f(velocity) * time.
f(velocity) = f(distance) / time

time = (f(distance) / time - current_velocity) / acceleration
time * acceleration = f(distance) / time - current_velocity
time^2 * acceleration = f(distance) - current_velocity * time
f(distance) = time^2 * acceleration + current_velocity * time

quadratic equation:
acceleration * time^2 + current_velocity * time - distance = 0


calculate the distance needed to reach a specific velocity at a specific deceleration.

Step 1: find out how much time the deceleration will need, given maximum deceleration.
end_velocity = initial_velocity + acceleration * time
end_velocity - initial_velocity = acceleration * time

time = (end_velocity - initial_velocity) / acceleration

Step 2: find out how far the vessel has traveled in that time.
distance = (current_velocity*time) + (acceleration^time2)

Trigger when that distance is sufficiently close.



solving for acceleration, attempt 3:
