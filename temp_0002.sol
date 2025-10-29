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
