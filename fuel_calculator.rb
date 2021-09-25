require 'pry'

print 'To calculate the amount of fuel required, please type the following command: ' \
	"calculate_fuel(14606, [[:launch, 9.807], [:land, 3.711], [:launch, 3.711], [:land, 9.807]])\n"

def calculate_fuel(mass, directive_values)
	# Calculate the amount of fuel for every directive, starting from the last one
	# as all of the fuel for preceding directives will be spent, thus reducing the mass
	directive_values.reverse.each_with_index do |directive_data, index|
		directive_values[index] =
			if index.zero?
				# The last directive will always require only baseline amounts of fuel
				calculate_iterative_fuel(*directive_data, mass)
			else
				# All of the preceding directives also require fuel for future directives
				# which increases the mass as well as the amount of fuel
				other_directives_fuel = directive_values[0..index - 1].inject(0, :+)

				calculate_iterative_fuel(
					*directive_data,
					mass + other_directives_fuel
				) + other_directives_fuel
			end
	end

	"This mission requires #{directive_values.last} kg of fuel"
end

private

def calculate_iterative_fuel(directive_type, gravity, mass)
	additional_mass = calculate_base_fuel(directive_type, gravity, mass)

	# Combining fuel requirements linearly would be incorrect, as fuel requirements for
	# two separate masses (9278 and 2960 for example) does NOT equal the fuel requirements
	# for the sum of these directives
	while additional_mass.to_i.positive?
		mass += additional_mass
		additional_mass = calculate_base_fuel(directive_type, gravity, additional_mass)
	end

	calculate_base_fuel(directive_type, gravity, mass)
end

def calculate_base_fuel(directive_type, gravity, mass)
	case directive_type
	when :launch then mass * gravity * 0.042 - 33
	when :land then mass * gravity * 0.033 - 42
	end.floor
end

pry
