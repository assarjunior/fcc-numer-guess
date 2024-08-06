#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( RANDOM % 1001 ))

ASK_USERNAME(){
  while true; do
    echo -e "\nEnter your username:"
    read USERNAME

    USERNAME_LENGTH=$(echo -n $USERNAME | wc -c)
    if [[ $USERNAME_LENGTH -le 22 ]]; 
    then
      break
    else
      echo "$USERNAME is too long. Please enter a username with 22 characters or fewer."
    fi
  done
}

ASK_USERNAME
# Welcome message
RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
# USER doesn't exit
if [[ -z $RETURNING_USER ]]
then
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
# User exists
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
  GAMES=$(if [[ $GAMES_PLAYED -eq 1 ]]; then echo "game"; else echo "games"; fi)
  GUESSES=$(if [[ $BEST_GAME -eq 1 ]]; then echo "guess"; else echo "guesses"; fi)
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Grab user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

TRIES=1
GUESS=0

GUESSING_MACHINE(){
  while true; do
    read GUESS

    # Check if GUESS is a valid integer
    if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
      continue
    fi

    if [[ $GUESS -eq $SECRET_NUMBER ]]; then
      break
    elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
      echo -e "\nIt's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
      echo -e "\nIt's higher than that, guess again:"
    fi

    ((TRIES++))
  done
}

echo -e "\nGuess the secret number between 1 and 1000:"
GUESSING_MACHINE

# Insert data from game
INSERTED_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")

PLURAL_TRIES=$(if [[ $TRIES -eq 1 ]]; then echo "try"; else echo "tries"; fi)

# Final message
echo -e "\nYou guessed it in $TRIES $PLURAL_TRIES. The secret number was $SECRET_NUMBER. Nice job!"
