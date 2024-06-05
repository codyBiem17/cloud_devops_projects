import random

def guess_number(x):
    random_no = random.randint(1, x)
    guess = 0
    while guess != random_no:
        guess = int(input(f"Guess a number between 1 and {x}: "))
        if guess < random_no:
            print("Guess is too low. Sorry, try again!")
        elif guess > random_no:
            print("Guess is too high. Sorry, try again!")

    print(f"Yaaayy, you guessed the number {random_no} correctly")


guess_number(10)
