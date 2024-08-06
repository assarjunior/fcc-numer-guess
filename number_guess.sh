#!/bin/bash

echo "Enter your username:"
read NAME

# Generate a random number between 0 and 4
RANDOM_NUMBER=$(( RANDOM % 5 ))

# Initialize guess count
guess_count=0

while true; do
  echo "Enter number: "
  read NUMBER
  
  # Increment guess count
  guess_count=$((guess_count + 1))

  if [[ $NUMBER -eq $RANDOM_NUMBER ]]; then
    echo "$NUMBER matches $RANDOM_NUMBER"
    echo "Congratulations! You guessed the number in $guess_count guesses."
    break
  else
    echo "$NUMBER doesn't match $RANDOM_NUMBER"
  fi
done
