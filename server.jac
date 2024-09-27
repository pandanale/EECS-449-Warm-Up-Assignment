walker interact {
    can return_message with `root entry {
        report {
            "response": "Hello, world!"
        };
    }
}

walker interact_with_body {
    has name: str;

    can return_message with `root entry {
        report {
            "response": "Hello, " + self.name + "!"
        };
    }
}

# New walker that reverses a string
walker reverse_string{
    has input: str;

    can return_message with `root entry{
        reversed = self.input[::-1];
        report {
            "response": "The reverse of '" + self.input + "' is: '" + reversed + "'"
        };
    }
}
# New Walker that calculates the sum of two numbers
walker calculate_sum {
    has num1: int;
    has num2: int;

    can return_message with `root entry {
        result = self.num1 + self.num2;
        report {
            "response": "The sum of " + str(self.num1) + " and " + str(self.num2) + " is: " + str(result)
        };
    }
}