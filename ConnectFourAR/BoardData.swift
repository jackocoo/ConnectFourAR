//
//  BoardData.swift
//  ConnectFohre
//
//  Created by joconnor on 6/17/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import Foundation

class BoardData {
    
    private var board: [[Player]]
    private var currentPlayer: Player
    private var gameOver: Bool
    private var redMoves: Int
    private var blackMoves: Int
    
    init() {
        self.board = Array(repeating: Array(repeating: Player.empty, count: 6), count: 7)
        self.currentPlayer = Player.red
        self.gameOver = false
        self.redMoves = 0
        self.blackMoves = 0
        //print("Value in (6,0) is \(self.board[6][0])")
        //self.resetBoard() //mark all spaces in board as Player.Empty
    }
    
    /*
     checks if move can be made in column, edits the array if possible
     returns the row where the next move can be made in the given column
     */
    func makeMove(column: Int) -> Int{
        for j in 0..<6 {
            if(self.board[column][j] == Player.empty) {
                self.board[column][j] = self.currentPlayer
                if(self.currentPlayer == Player.black) {
                    self.blackMoves += 1
                } else {
                    self.redMoves += 1
                }
                return j //if there was space to make the move
            }
        }
        return -1 //if the target column is filled completely
    }
    
    
    func resetBoard() {
        for i in 0..<7 {
            for j in 0..<6 {
                self.board[i][j] = Player.empty
            }
        }
    }
    
    
    func getCurrentPlayer() -> Player {
        return self.currentPlayer
    }
    
    
    func getPlayerAtPos(column: Int, row: Int) -> Player {
        if(column < 0 || column > 6) {
            return Player.empty
        }
        if(row < 0 || row > 5) {
            return Player.empty
        }
        return self.board[column][row]
    }
    
    
    func changeCurrentPlayer() {
        if(self.currentPlayer == Player.black) {
            self.currentPlayer = Player.red
        } else {
            self.currentPlayer = Player.black
        }
    }
    
    
    func getGameOver() -> Bool {
        return self.gameOver
    }
    
    
    func changeGameOver() {
        if(self.gameOver == false) {
            self.gameOver = true
        } else {
            self.gameOver = false
        }
    }
    
    
    func getBoard() -> [[Player]] {
        return self.board
    }
    
    
    //large function that checks generally for a win from a particular position on the board
    //checks for vertical, horizontal wins recursively, then compares booleans to see
    //if any possible win direction is satisfied from this point
    func checkWin(column: Int, row: Int) -> Bool {
        if (self.blackMoves < 4 && self.redMoves < 4) { //need to play at least 4 turns to possibly win
            return false
        }
        
        let count = 0
        
        let playerNow: Player = self.board[column][row]
        //check below (cannot be one directly above)
        var vertWin = false //works as is just checking for 4 down
        var horzWin = false //whether left and right add to at least 4
        var diagWinR = false //whether y = x adds to at least 4
        var diagWinL = false //whether y = -x adds to at least 4
        
        //horizontal win
        var horzCountL = 0
        var horzCountR = 0
        
        // y = x win
        var diagCountTopR = 0
        var diagCountBotL = 0
        
        //y = -x win
        var diagCountTopL = 0
        var diagCountBotR = 0
        
        
        if (getPlayerAtPos(column: column, row: row - 1) == playerNow) { //checks if the adjacent pos is same color
            vertWin = checkVertWin(column: column, row: row - 1, count: count + 1, player: playerNow)
        }
        print("vertical win is \(vertWin)")
        
        //checks for win horizontally
        if (getPlayerAtPos(column: column - 1, row: row) == playerNow) {//checks if the adjacent pos is same color
            horzCountL = checkHorzWinL(column: column - 1, row: row, count: count + 1, player: playerNow)
        }
        if (getPlayerAtPos(column: column + 1, row: row) == playerNow) { //checks if the adjacent pos is same color
            horzCountR = checkHorzWinR(column: column + 1, row: row, count: count + 1, player: playerNow)
        }
        horzWin = (horzCountL + horzCountR) >= 3
        print("horizontal win is \(horzWin) ... \(horzCountL) and \(horzCountR)")
        
        
        //checks for win along y = x
        if (getPlayerAtPos(column: column + 1, row: row + 1) == playerNow) {
            diagCountTopR = checkDiagTopR(column: column + 1, row: row + 1, count: count + 1, player: playerNow)
        }
        if (getPlayerAtPos(column: column - 1, row: row - 1) == playerNow) {
            diagCountBotL = checkDiagBelowL(column: column - 1, row: row - 1, count: count + 1, player: playerNow)
        }
        diagWinR = (diagCountTopR + diagCountBotL) >= 3
        print("diagonal right win is \(diagWinR) ... \(diagCountTopR) and \(diagCountBotL)")
        
        
        //checks for win along y = -x
        if (getPlayerAtPos(column: column - 1, row: row + 1) == playerNow) {
            diagCountTopL = checkDiagTopL(column: column - 1, row: row + 1, count: count + 1, player: playerNow)
        }
        if (getPlayerAtPos(column: column + 1, row: row - 1) == playerNow) {
            diagCountBotR = checkDiagBelowR(column: column + 1, row: row - 1, count: count + 1, player: playerNow)
        }
        diagWinL = (diagCountTopL + diagCountBotR) >= 3
        print("diagonal left win is \(diagWinL) ... \(diagCountTopL) and \(diagCountBotR)")
        
        
        
        return vertWin || horzWin || diagWinL || diagWinR
    }
    
    
    //checks for win below the given position (will always start from new move,
    //so it is impossible for there to be a board piece above)
    func checkVertWin(column: Int, row: Int, count: Int, player: Player) -> Bool {
        if (count == 3) {
            return true
        }
        if (getPlayerAtPos(column: column, row: row - 1) == player) {
            return checkVertWin(column: column, row: row - 1, count: count + 1, player: player)
        } else {
            return false
        }
    }
    
    //check for win horizontally to the left
    func checkHorzWinL(column: Int, row: Int, count: Int, player: Player) -> Int {
        if (getPlayerAtPos(column: column - 1, row: row) != player) {
            return count
        } else {
            return checkHorzWinL(column: column - 1, row: row, count: count + 1, player: player)
        }
    }
    
    //check for win horizontally to the right
    func checkHorzWinR(column: Int, row: Int, count: Int, player: Player) -> Int {
        if (getPlayerAtPos(column: column + 1, row: row) != player) {
            return count
        } else {
            return checkHorzWinR(column: column + 1, row: row, count: count + 1, player: player)
        }
    }
    
    //check for win diagonally along y = x to the right
    func checkDiagTopR(column: Int, row: Int, count: Int, player: Player) -> Int  {
        if (getPlayerAtPos(column: column + 1, row: row + 1) != player) {
            return count
        } else {
            return checkDiagTopR(column: column + 1, row: row + 1, count: count + 1, player: player)
        }
    }
    
    
    //checks for win diagonally along y = -x to the left
    func checkDiagTopL(column: Int, row: Int, count: Int, player: Player) -> Int  {
        if (getPlayerAtPos(column: column - 1, row: row + 1) != player) {
            return count
        } else {
            return checkDiagTopL(column: column - 1, row: row + 1, count: count + 1, player: player)
        }
    }
    
    
    //checks for win diagonally along y = -x to the right
    func checkDiagBelowR(column: Int, row: Int, count: Int, player: Player) -> Int  {
        if (getPlayerAtPos(column: column + 1, row: row - 1) != player) {
            return count
        } else {
            return checkDiagBelowR(column: column + 1, row: row - 1, count: count + 1, player: player)
        }
    }
    
    
    //checks for win diagonally along y = x to the left
    func checkDiagBelowL(column: Int, row: Int, count: Int, player: Player) -> Int  {
        if (getPlayerAtPos(column: column - 1, row: row - 1) != player) {
            return count
        } else {
            return checkDiagBelowL(column: column - 1, row: row - 1, count: count + 1, player: player)
        }
    }
}
