# 🔮 Higher or Lower Number Game

A fun and interactive blockchain game built on Ethereum where players guess if the next number will be higher or lower! Perfect for beginners learning about smart contracts and Web3 gaming.

![Higher or Lower Game](https://img.shields.io/badge/Game-Higher%20or%20Lower-brightgreen)
![Solidity](https://img.shields.io/badge/Solidity-0.8.0-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 🎯 What It Does

Guess the future! This simple yet addictive game presents you with a random number between 1-100. Your mission: predict whether the NEXT random number will be **Higher** or **Lower** than the current one. Test your intuition and see if you can beat the odds!

## ✨ Features

- 🎮 **Simple Gameplay**: Easy-to-understand Higher or Lower mechanics
- 🔒 **Fully On-Chain**: All game logic lives on the blockchain
- 💰 **Risk-Free**: No real money involved - perfect for learning
- 📊 **Game Tracking**: Monitor your wins and game history
- 🎯 **Beginner Friendly**: Clean, well-commented Solidity code
- 📡 **Event Emitters**: Perfect for frontend integration

## 🚀 Quick Start

### Prerequisites
- MetaMask or any Web3 wallet
- Test ETH (on Sepolia, Goerli, or any testnet)
- Basic understanding of smart contracts

### How to Play
1. **Start Game**: Initialize with a random starting number
2. **Make Your Guess**: Choose HIGHER (0) or LOWER (1)
3. **Reveal Result**: Discover if your prediction was correct!
4. **Play Again**: Start a new game and keep the streak going!

## 📜 Smart Contract
https://celo-sepolia.blockscout.com/tx/0xb5f205b22ab9b91586e7462d22dd10843d4e779c1de416a7228a15b8c3d89430


<img width="1276" height="978" alt="image" src="https://github.com/user-attachments/assets/f7debb3f-7e25-4b0b-a764-10972574f89e" />

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HigherLowerGame {
    // Game states
    enum GameState { WAITING_FOR_GUESS, RESULT_READY }
    
    // Player's guess options
    enum Guess { HIGHER, LOWER }
    
    // Game structure to store game data
    struct Game {
        uint256 currentNumber;
        uint256 nextNumber;
        Guess playerGuess;
        GameState state;
        bool hasWon;
        address player;
    }
    
    // Store the last game for each player
    mapping(address => Game) public games;
    
    // Events to track game actions
    event GameStarted(address indexed player, uint256 currentNumber);
    event GuessMade(address indexed player, Guess guess);
    event ResultRevealed(address indexed player, bool hasWon, uint256 currentNumber, uint256 nextNumber);
    
    // Start a new game with a random current number
    function startGame() external {
        // Generate a pseudo-random number between 1-100
        uint256 randomNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 100) + 1;
        
        games[msg.sender] = Game({
            currentNumber: randomNumber,
            nextNumber: 0,
            playerGuess: Guess.HIGHER, // default value
            state: GameState.WAITING_FOR_GUESS,
            hasWon: false,
            player: msg.sender
        });
        
        emit GameStarted(msg.sender, randomNumber);
    }
    
    // Make a guess (higher or lower)
    function makeGuess(Guess _guess) external {
        Game storage game = games[msg.sender];
        require(game.state == GameState.WAITING_FOR_GUESS, "No active game or already guessed");
        require(game.player != address(0), "Start a game first");
        
        game.playerGuess = _guess;
        game.state = GameState.RESULT_READY;
        
        // Generate the next number (1-100)
        game.nextNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 100) + 1;
        
        // Check if the player won
        if (_guess == Guess.HIGHER) {
            game.hasWon = game.nextNumber > game.currentNumber;
        } else {
            game.hasWon = game.nextNumber < game.currentNumber;
        }
        
        emit GuessMade(msg.sender, _guess);
        emit ResultRevealed(msg.sender, game.hasWon, game.currentNumber, game.nextNumber);
    }
    
    // Get current game state for the player
    function getCurrentGame() external view returns (
        uint256 currentNumber,
        uint256 nextNumber,
        Guess playerGuess,
        GameState state,
        bool hasWon
    ) {
        Game storage game = games[msg.sender];
        return (
            game.currentNumber,
            game.nextNumber,
            game.playerGuess,
            game.state,
            game.hasWon
        );
    }
    
    // Check if player won their last game
    function didIWin() external view returns (bool) {
        return games[msg.sender].hasWon;
    }
    
    // Get the current number (for display purposes)
    function getCurrentNumber() external view returns (uint256) {
        return games[msg.sender].currentNumber;
    }
}
